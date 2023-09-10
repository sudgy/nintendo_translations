base_directory = "FILL THIS IN"
--dofile(base_directory .. "mesen.lua")
dofile(base_directory .. "fceux.lua")

messages_filename = base_directory .. "onigashima_messages.bin"
options_filename = base_directory .. "onigashima_options.bin"

credits_d = -1

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
    Options.values = {}
    Messages.current_message = nil
    Messages.current_writing = nil
    Messages.write_lag = 0
    Messages.newlines = 0
    credits_d = -1
    Messages.need_updating = false
    Options.need_updating = false
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
function Messages.display()
    local scroll_color = e.get_pixel2(16, 25)
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
    local scroll_pos = e.read(0x68)
    if scroll_pos >= 3 then
        e.draw_rect(32, 40, 87, scroll_pos*8 + 23, scroll_color)
    end
    local i = 0
    for line in Messages.current_message:gmatch("(.-)\n") do
        local x_offset = 1
        local heart = false
        while string.byte(line, x_offset) == 92 do x_offset = x_offset + 1 end
        if string.byte(line, x_offset) == 60 then
            heart = true
        end
        if heart then
            e.draw_text(
                32 + x_offset + 1,
                44 + i*9 + y_offset,
                "<",
                e.black,
                e.clear
            )
            e.draw_text(
                32 + x_offset + 3,
                44 + i*9 + y_offset,
                string.sub(line, x_offset + 1),
                e.black,
                e.clear
            )
            i = i + 1
        else
            e.draw_text(
                32 + x_offset,
                44 + i*9 + y_offset,
                string.sub(line, x_offset),
                e.black,
                e.clear
            )
            i = i + 1
        end
    end
    local cursor_color = e.get_pixel2(33, 117)
    if e.get_pixel2(33, 116) ~= cursor_color and scroll_pos == 22 then
        x = (32 + 87)/2 - 1
        y = 196
        e.draw_rect(x, y, x + 4, y, cursor_color)
        e.draw_rect(x+1, y+1, x + 3, y+1, cursor_color)
        e.draw_rect(x+2, y+2, x + 2, y+2, cursor_color)
    end
end
function Messages.add_message()
    if Messages.current_writing ~= nil then
        Messages.current_message
            = Messages.current_message .. Messages.current_writing
        Messages.current_writing = nil
    end
    local value = {}
    for i=0,0x35 do
        local this_char = e.read(0x0520 + i*2)
        local this_dak = e.read(0x0521 + i*2)
        if this_char ~= 252 and this_char ~= 249 and this_char ~= 251 then
            table.insert(value, this_char)
            if this_dak ~= 252 then table.insert(value, this_dak) end
        end
    end
    if #value ~= 0 then
        mess = string.char(e.unpack(value))
        local trans = Messages.translations[mess]
        if not trans then
            opt = Options.values[4]
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
        else
            e.log("Could not find translation for message")
            Messages.current_message = nil
            --for i = 1,#value do
            --    print(string.format("%x", value[i]) .. " " .. tostring(value[i]))
            --end
        end
    end
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
    local total = e.read(0x00A6)
    local this = e.read(0x00A7)
    -- The name screen, hopefully it never uses all 12 anywhere else
    if total == 12 then
        Options.values = {}
        return
    end
    local value = {}
    for i=0,7 do
        local this_char = e.read(0x0520 + i*2)
        local this_dak = e.read(0x0521 + i*2)
        if this_char ~= 252 then
            table.insert(value, this_char)
            if this_dak ~= 252 then table.insert(value, this_dak) end
        end
    end
    if #value ~= 0 then
        local trans = Options.translations[string.char(e.unpack(value))]
        if trans then
            if trans == "\\\\\\\\\\\\\\\\\\\\\\\\\\Place\n" and (total - this + 1 == 1 or total - this + 1 == 2) then
                Options.values[total - this+1] = "\\\\\\\\\\\\\\\\\\\\Deeper\n"
            else
                Options.values[total - this+1] = trans
            end
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
    local scroll_color = e.get_pixel2(16, 25)
    if not has_values(Options.values) then return end
    local scroll_pos = e.read(0x6E)
    if scroll_pos >= 3 then
        e.draw_rect(240 - scroll_pos*8, 160, 220, 207, scroll_color)
    end
    for i, option in pairs(Options.values) do
        local height = (i - 1) % 3
        local l = 0
        local num = -1
        for line in option:gmatch("(.-)\n") do
            num = num + 1
        end
        for line in option:gmatch("(.-)\n") do
            local x_offset = 1
            while string.byte(line, x_offset) == 92 do x_offset = x_offset + 1 end
            e.draw_text(
                195 + x_offset - 16*i,
                164 + height*16 + l*8 - 4*num,
                string.sub(line, x_offset),
                e.black,
                e.clear
            )
            l = l + 1
        end
    end
end

function draw_scrolls()
    local black = e.get_pixel2(24, 24)
    local background = e.get_pixel2(0, 0)
    local scroll_color = e.get_pixel2(16, 25)
    local dark_scroll = e.get_pixel2(17, 25)
    p1 = e.read(0x0068) -- Left scroll
    p2 = e.read(0x006E) -- Bottom scroll
    if p1 == 0 then return end
    -- Fully in: 1 and 1
    -- Fully out: 22 and 27
    -- Middle: 13 and 14
    if p1 > 13 then
        e.draw_rect(32, p1*8 + 32, 87, 240, background)
    elseif p2 > 14 then
        e.draw_rect(0, 160, 231 - p2*8, 207, background)
    else
        e.draw_rect(32, p1*8 + 32, 87, 240, background)
        e.draw_rect(0, 160, 231 - p2*8, 207, background)
    end
    if p1 < 13 then
        e.draw_rect(32, p1*8 + 32, 87, 140, background)
    end
    if p2 < 14 then
        e.draw_rect(110, 160, 231 - p2*8, 207, background)
    end
    function draw_scroll(i, color)
        e.draw_rect(32, p1*8 + 24 + i, 87, p1*8 + 24 + i, color)
        e.draw_rect(232 - p2*8 + i, 160, 232 - p2*8 + i, 207, color)
    end
    draw_scroll(0, black)
    draw_scroll(1, dark_scroll)
    draw_scroll(2, scroll_color)
    draw_scroll(3, dark_scroll)
    draw_scroll(4, dark_scroll)
    draw_scroll(5, black)
    draw_scroll(6, black)
    draw_scroll(7, dark_scroll)
end

function on_write_option()
    if e.read(0x008B) == 0 then
        Options.need_updating = true
    end
end

function on_write_message()
    Messages.need_updating = true
end

function finished_writing()
    if Messages.need_updating then
        Messages.add_message()
        Messages.need_updating = false
    end
    if Options.need_updating then
        Options.add_value()
        Options.need_updating = false
    end
end

e.register_exec(0x8F78, finished_writing)
e.register_write(0x052F, on_write_option)
e.register_write(0x0547, on_write_message)
e.register_write(0x0569, on_write_message)
e.register_write(0x058B, on_write_message)
e.register_save(clear_all)

-- 0: Loading screen
-- 1: In game
-- 2: Title screen
-- 3: Zenpen credits
function get_location()
    local colors = {}
    for i = 1,8 do
        colors[i] = e.get_pixel2(16 + i, 238)
    end
    local bland = true
    for i = 2,8 do
        if colors[1] ~= colors[i] then
            bland = false
            break
        end
    end
    if bland then
        if e.get_pixel2(150, 23) == e.get_pixel2(150, 24) then
            return 0
        else
            return 1
        end
    end
    if colors[1] == e.get_pixel2(17 + 8, 238) and
       colors[2] == e.get_pixel2(18 + 8, 238)
    then
        return 3
    else
        return 2
    end
end

function update_credits()
    local scroll_color = e.get_pixel2(16, 24)
    if e.read(0x0331) == 211 then
        credits_d = e.read(0x0333)
    elseif credits_d ~= -1 then
        credits_d = credits_d + 1
    end
    if credits_d ~= -1 then
        e.draw_rect(0, 32, 256, 128, scroll_color)
        x = credits_d - 64
        e.draw_text(
            x,
            64,
            "There are three sources",
            e.black,
            e.clear
        )
        e.draw_text(
            x,
            73,
            "of heavenly water in the",
            e.black,
            e.clear
        )
        e.draw_text(
            x,
            82,
            "capital. Uncover! The",
            e.black,
            e.clear
        )
        e.draw_text(
            x,
            91,
            "secret of your birth!",
            e.black,
            e.clear
        )
        if credits_d == 320 then
            credits_d = -1
        end
    end
    local blue = e.get_pixel2(0, 231)
    if e.get_pixel2(0, 220) == blue and e.get_pixel2(1, 220) == blue then
        local sand = e.get_pixel2(255, 219)
        local i1 = 0
        local i2 = 255
        while i2 > i1 + 1 do
            local mid = math.floor((i1 + i2) / 2)
            if e.get_pixel2(mid, 219) == sand then
                i2 = mid
            else
                i1 = mid
            end
        end
        local x = i1 - 128
        local sky = e.get_pixel2(0, 0)
        e.draw_rect(x, 0, x + 48, 184, sky)
        e.draw_text(
            x,
            128,
            "To be continued",
            e.white,
            e.clear
        )
        e.draw_text(
            x + 11,
            137,
            "in volume 2",
            e.white,
            e.clear
        )
    end
end

function loop()
    -- This is hopefully only when the BIOS is loading the game
    if e.read(0x0022) == 16 then return end
    location = get_location()
    if location == 0 then
        --print("Loading")
    elseif location == 1 then
        --print("In game")
        Messages.display()
        Options.display()
        if e.read(0x0068) == 1 then
            Messages.current_message = nil
        end
        if e.read(0x006E) == 1 then
            Options.values = {}
        end
        draw_scrolls()
    elseif location == 2 then
        clear_all()
        --print("Title")
    elseif location == 3 then
        --print("Zenpen credits")
        update_credits()
    end
end

e.register_frame(loop)
