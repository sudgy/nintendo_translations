base_directory = "/home/sudgy/programs/emulators/nintendo_translations/"
--dofile(base_directory .. "mesen.lua")
dofile(base_directory .. "fceux.lua")

messages_filename = base_directory .. "yuyuki_messages.bin"
options_filename = base_directory .. "yuyuki_options.bin"

function has_values(t)
    for n in pairs(t) do
        return true
    end
    return false
end

function bitand(a, b)
    local result = 0
    local bitval = 1
    while a > 0 and b > 0 do
      if a % 2 == 1 and b % 2 == 1 then -- test the rightmost bits
          result = result + bitval      -- set the current bit
      end
      bitval = bitval * 2 -- shift left
      a = math.floor(a/2) -- shift right
      b = math.floor(b/2)
    end
    return result
end

function overlap_strs(s1, s2)
    for i=1,#s1 do
        local new_s1 = string.sub(s1, i, #s1 - 1)
        local new_s2 = string.sub(s2, 1, #s1 - i)
        if new_s1 == new_s2 then
            local new_s3 = string.sub(s2, #s1 - i)
            local _, newlines = s1:sub(1, i):gsub("\n", "")
            return newlines, new_s2, new_s3
        end
    end
    return s2, nil
end

function clear_all()
    Messages.current_message = nil
    Messages.current_writing = nil
    Messages.write_lag = 0
    Messages.newlines = 0
    Options.values = {}
    bad_translation = true
    global_x_offset = 0
    last_option_pos = -1
    gx = 0
    gy = 0
end

function draw_text(x, y, text, color, back_color)
    e.draw_text(x + gx, y + gy, text, color, back_color)
end

function draw_rect(x1, y1, x2, y2, color)
    e.draw_rect(x1 + gx, y1 + gy, x2 + gx, y2 + gy, color)
end

function get_pixel2(x, y)
    return e.get_pixel2(x + gx, y + gy)
end

Messages = {}
Messages.need_updating = false
function Messages.load_messages()
    local file = assert(io.open(messages_filename), "rb")
    local data = file:read("*all")
    Messages.translations = {}
    local start_index = 1
    while true do
        local end_index = string.find(data, "\0", start_index)
        if end_index == nil then break end
        local japanese = string.sub(data, start_index, end_index - 1)
        start_index = end_index + 1
        end_index = string.find(data, "\0", start_index)
        local english = string.sub(data, start_index, end_index - 1)
        start_index = end_index + 1
        Messages.translations[japanese] = english
    end
end
Messages.load_messages()
Messages.current_message = nil
Messages.current_writing = nil
Messages.write_lag = 0
Messages.newlines = 0
global_x_offset = 0
function Messages.display()
    local scroll_color = get_pixel2(16, 25)
    local y_offset = 0
    if Messages.current_message == nil then return end
    if Messages.current_writing ~= nil then
        if Messages.write_lag > 0 then
            Messages.write_lag = Messages.write_lag - 1
            y_offset = 9*Messages.newlines * Messages.write_lag / 8
        else
            i = 1
            while string.byte(Messages.current_writing, i) == 92 do i = i + 1 end
            i = i + 1
            Messages.current_message =
                string.sub(Messages.current_message, 1, -2)
                .. string.sub(Messages.current_writing, 1, i)
                .. "\n"
            Messages.current_writing = string.sub(Messages.current_writing, i + 1)
            if Messages.current_writing == "" then
                Messages.current_writing = nil
            end
        end
    end
    local i = 0
    for line in Messages.current_message:gmatch("(.-)\n") do
        local x_offset = 1
        local heart_pos = string.find(line, "<")
        while string.byte(line, x_offset) == 92 do x_offset = x_offset + 1 end
        if heart_pos ~= nil then
            draw_text(
                32 + x_offset + global_x_offset,
                158 + i*9 + y_offset,
                string.sub(line, x_offset, heart_pos),
                e.black,
                e.clear
            )
            if #line > heart_pos then
                draw_text(
                    32 + x_offset + 3 + global_x_offset - 4
                        + string.byte(line, heart_pos + 1),
                    158 + i*9 + y_offset,
                    string.sub(line, heart_pos + 2),
                    e.black,
                    e.clear
                )
            end
            i = i + 1
        else
            draw_text(
                32 + x_offset + global_x_offset,
                158 + i*9 + y_offset,
                string.sub(line, x_offset),
                e.black,
                e.clear
            )
            i = i + 1
        end
    end
    local cursor_color = get_pixel2(35, 119)
    local scroll_pos = e.read(0x6B)
    if get_pixel2(34, 120) ~= cursor_color and scroll_pos == 23 then
        x = 126
        y = 208
        draw_rect(x, y, x + 4, y, cursor_color)
        draw_rect(x+1, y+1, x + 3, y+1, cursor_color)
        draw_rect(x+2, y+2, x + 2, y+2, cursor_color)
    end
end
function Messages.add_message()
    bad_translation = false
    if Messages.current_writing ~= nil then
        Messages.current_message
            = Messages.current_message .. Messages.current_writing
        Messages.current_writing = nil
    end
    local value = {}
    for i=0,0x35 do
        local this_char = e.read(0x0560 + i*2)
        local this_dak = e.read(0x0561 + i*2)
        if this_char ~= 176 then
            table.insert(value, this_char)
            if this_dak ~= 176 then table.insert(value, this_dak) end
        end
    end
    if #value ~= 0 then
        mess = string.char(e.unpack(value))
        local trans = Messages.translations[mess]
        if not trans then
            opt = Options.values[e.read(0x00B0) + 1]
            if opt then
                i = 1
                while string.byte(opt, i) == 92 do i = i + 1 end
                j = opt:find("\n")
                trans = Messages.translations[mess .. opt:sub(i, j-1)]
            end
        end
        if trans then
            if Messages.current_message ~= nil then
                Messages.newlines,
                Messages.current_message,
                Messages.current_writing
                    = overlap_strs(Messages.current_message, trans)
                Messages.write_lag = 8
            else
                Messages.current_message = ""
                Messages.current_writing = trans
            end
            local scroll_pos = e.read(0x6B)
            if scroll_pos < 23 then
                global_x_offset = (25 - scroll_pos) * 8
            else
                global_x_offset = 0
            end
        else
            e.log("Could not find translation for message")
            Messages.current_message = nil
            bad_translation = true
            --for i = 1,#value do
            --    print(string.format("%x", value[i]) .. " " .. tostring(value[i]))
            --end
        end
    end
end
function Messages.on_scroll()
    for i=0,0x6A do
        local this_char = e.read(0x0560 + i)
        if this_char ~= 176 then return end
    end
    Messages.current_message = nil
end

Options = {}
Options.values = {}
Options.need_updating = false
function Options.load_options()
    local file = assert(io.open(options_filename), "rb")
    local data = file:read("*all")
    Options.translations = {}
    local start_index = 1
    while true do
        local end_index = string.find(data, "\0", start_index)
        if end_index == nil then break end
        local japanese = string.sub(data, start_index, end_index - 1)
        start_index = end_index + 1
        end_index = string.find(data, "\0", start_index)
        local english = string.sub(data, start_index, end_index - 1)
        start_index = end_index + 1
        Options.translations[japanese] = english
    end
end
Options.load_options()
function Options.add_value()
    bad_translation = false
    local total = e.read(0x00A0)
    local this = e.read(0x00A1)
    -- The name screen, hopefully it never uses all 12 anywhere else
    if total == 12 then
        Options.values = {}
        return
    end
    local value = {}
    for i=0,7 do
        local this_char = e.read(0x0560 + i*2)
        local this_dak = e.read(0x0561 + i*2)
        if this_char ~= 176 then
            table.insert(value, this_char)
            if this_dak ~= 176 then table.insert(value, this_dak) end
        end
    end
    if #value ~= 0 then
        local trans = Options.translations[string.char(e.unpack(value))]
        if trans then
            Options.values[total - this+1] = trans
        else
            if value[1] ~= 0 then
                e.log("Could not find translation for option")
                Options.values[total - this+1] = "UNKNOWN\n"
                --for i = 1,#value do
                --    print(string.format("%x", value[i]) .. " " .. tostring(value[i]))
                --end
            end
        end
    end
end
function Options.display()
    local scroll_color = get_pixel2(16, 25)
    if not has_values(Options.values) then return end
    for i, option in pairs(Options.values) do
        local num = -1
        for line in option:gmatch("(.-)\n") do
            num = num + 1
        end
        local l = 0
        for line in option:gmatch("(.-)\n") do
            draw_text(
                33,
                28 + i*16 + l*8 - 4*num,
                line,
                e.black,
                e.clear
            )
            l = l + 1
        end
    end
end

function scroll_rect(x1, y1, x2, y2, color, flip)
    if flip then
        draw_rect(y1, x1, y2, x2, color)
    else
        draw_rect(x1, y1, x2, y2, color)
    end
end

function draw_scroll(x, y, length, flip)
    if flip then
        x, y = y, x
    end
    local black = get_pixel2(24, 24)
    local background = get_pixel2(8, 8)
    local scroll_color = get_pixel2(16, 25)
    local dark_scroll = get_pixel2(17, 25)

    scroll_rect(x, y, x, y + length - 1, black, flip)
    scroll_rect(x + 1, y - 7, x + 1, y + length + 6, dark_scroll, flip)
    scroll_rect(x + 2, y - 8, x + 2, y + length + 7, scroll_color, flip)
    scroll_rect(x + 3, y - 7, x + 4, y + length + 6, dark_scroll, flip)
    scroll_rect(x + 5, y - 7, x + 6, y + length + 6, black, flip)
    scroll_rect(x + 7, y - 2, x + 7, y + length + 1, dark_scroll, flip)

    scroll_rect(x, y - 1, x + 7, y - 1, black, flip)
    scroll_rect(x, y - 2, x + 1, y - 2, scroll_color, flip)
    scroll_rect(x + 1, y - 8, x + 3, y - 8, scroll_color, flip)
    scroll_rect(x + 5, y - 2, x + 6, y - 2, background, flip)
    scroll_rect(x + 6, y - 7, x + 6, y - 3, dark_scroll, flip)
    scroll_rect(x + 4, y - 8, x + 6, y - 8, black, flip)

    scroll_rect(x, y + length + 0, x + 7, y + length + 0, black, flip)
    scroll_rect(x, y + length + 1, x + 1, y + length + 1, scroll_color, flip)
    scroll_rect(x + 1, y + length + 7, x + 3, y + length + 7, scroll_color, flip)
    scroll_rect(x + 5, y + length + 1, x + 6, y + length + 1, background, flip)
    scroll_rect(x + 6, y + length + 6, x + 6, y + length + 2, dark_scroll, flip)
    scroll_rect(x + 4, y + length + 7, x + 6, y + length + 7, black, flip)
end

function draw_scrolls()
    if bad_translation then return end
    local background = get_pixel2(8, 8)
    local scroll_color = get_pixel2(16, 25)
    local dark_scroll = get_pixel2(17, 25)

    draw_rect(0, 32, 103, 231, background)
    draw_rect(0, 144, 231, 231, background)

    local message = e.read(0x006B)
    local option = e.read(0x0071)
    if message < 4 then
        Messages.current_message = nil
    end
    while #Options.values > 0 and #Options.values * 2 + 3 > option do
        table.remove(Options.values, #Options.values)
    end
    local message_offset
    local option_offset
    if message < 14 then
        message_offset = 224 - (message - 1) / 13 * 15 * 8
    else
        message_offset = 104 - (message - 14) / 9 * 11 * 8
    end
    if option < 16 then
        option_offset = 32 + (option - 1) / 15 * 13 * 8
    else
        --option_offset = 136 + (option - 16) / 11 * 9 * 8
        option_offset = math.min(136 + (option - 16) * 8, 224)
    end

    function draw_messages()
        if message == 1 then return end
        draw_rect(message_offset, 152, 231, 215, dark_scroll)
        draw_rect(message_offset, 156, 223, 211, scroll_color)
        if message == 23 then
            draw_rect(24, 156, 30, 211, dark_scroll)
        end
        Messages.display()
        draw_rect(0, 156, message_offset - 1, 211, background)
    end
    function draw_options()
        if option == 1 then return end
        draw_rect(24, 32, 95, option_offset - 1, dark_scroll)
        draw_rect(28, 39, 91, option_offset - 1, scroll_color)
        Options.display()
        draw_rect(28, option_offset, 91, 231, background)
        index = e.read(0x00B0)
        if index * 2 + 5 < option then
            cursor_color = get_pixel2(204 - index * 16, 156)
            if cursor_color ~= scroll_color then
                y = 47 + index*16
                draw_rect(28, y-2, 28, y+2, cursor_color)
                draw_rect(29, y-1, 29, y+1, cursor_color)
                draw_rect(30, y, 30, y, cursor_color)
                draw_rect(91, y-2, 91, y+2, cursor_color)
                draw_rect(90, y-1, 90, y+1, cursor_color)
                draw_rect(89, y, 89, y, cursor_color)
            end
        end
    end

    if message <= 14 then
        draw_messages()
        draw_options()
    else
        draw_options()
        draw_messages()
    end

    draw_scroll(message_offset, 152, 64, false)
    draw_scroll(24, option_offset, 72, true)
end

function on_input(input)
    if bad_translation then return input end
    input["up"], input["right"] = input["right"], input["up"]
    input["down"], input["left"] = input["left"], input["down"]
    return input
end

-- 0: Not in game
-- 1: In game
function get_location()
    if get_pixel2(16, 24) ~= get_pixel2(16, 25) then
        return 1
    else
        return 0
    end
end

shake_timer = 0

function update_shaking()
    if shake_timer > 0 then
        shake_timer = shake_timer - 1
        if shake_timer == 3 then
            gx = -8
            gy = -8
        elseif shake_timer == 2 then
            gx = 0
            gy = -8
        elseif shake_timer == 1 then
            gx = -8
            gy = 0
        elseif shake_timer == 0 then
            gx = 0
            gy = 0
        end
    else
        if e.read(0x15) == 0 and e.read(0x17) == 8 then
            shake_timer = 4
            gx = 0
            gy = 0
        end
    end
end

function loop()
    -- This is hopefully only when the BIOS is loading the game
    if e.read(0x0022) == 16 then return end
    update_shaking()
    local location = get_location()
    if location == 1 then
        draw_scrolls()
    else
        clear_all()
        bad_translation = false
    end
end

e.register_exec(0x7951, Messages.add_message) -- Drawing at the beginning
e.register_exec(0x79C9, Messages.add_message) -- Drawing partway through
e.register_exec(0x7997, Messages.add_message) -- After shifting
e.register_exec(0x79B0, Messages.add_message) -- Drawing partway through again?
e.register_exec(0x7E44, Messages.on_scroll)
e.register_exec(0x8FEC, Options.add_value)
e.register_input(on_input)
e.register_frame(loop)
e.register_save(clear_all)

clear_all()
