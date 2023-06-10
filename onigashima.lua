base_directory = "FILL TIHS IN"
--dofile(base_directory .. "mesen.lua")
dofile(base_directory .. "fceux.lua")

messages_filename = base_directory .. "onigashima_messages.bin"
options_filename = base_directory .. "onigashima_options.bin"

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

function clear_all()
    Options.values = {}
    Messages.current_message = nil
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
function Messages.display()
    if Messages.current_message == nil then return end
    local scroll_pos = e.read(0x68)
    if scroll_pos >= 3 then
        e.draw_rect(32, 40, 87, scroll_pos*8 + 23, e.scroll_color)
    end
    local i = 0
    for line in Messages.current_message:gmatch("(.-)\n") do
        local x_offset = 1
        while string.byte(line, x_offset) == 92 do x_offset = x_offset + 1 end
        e.draw_text(
            32 + x_offset,
            44 + i*9,
            string.sub(line, x_offset),
            e.black,
            e.clear
        )
        i = i + 1
    end
    if e.get_pixel2(33, 116) ~= e.get_pixel2(33, 117) and scroll_pos == 22 then
        x = (32 + 87)/2 - 1
        y = 196
        e.draw_rect(x, y, x + 4, y, e.cursor_color)
        e.draw_rect(x+1, y+1, x + 3, y+1, e.cursor_color)
        e.draw_rect(x+2, y+2, x + 2, y+2, e.cursor_color)
    end
end
function Messages.add_message()
    local value = {}
    for i=0,0x35 do
        local this_char = e.read(0x0520 + i*2)
        local this_dak = e.read(0x0521 + i*2)
        if this_char ~= 252 and this_char ~= 249 then
            table.insert(value, this_char)
            if this_dak ~= 252 then table.insert(value, this_dak) end
        end
    end
    if #value ~= 0 then
        local trans = Messages.translations[string.char(e.unpack(value))]
        if trans then
            Messages.current_message = trans
        else
            e.log("Could not find translation for message")
            Messages.current_message = nil
            --for i = 1,#value do
            --    print(string.format("%x", value[i]))
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
            Options.values[total - this+1] = trans
        else
            e.log("Could not find translation for option")
            --for i = 1,#value do
            --    print(string.format("%x", value[i]))
            --end
        end
    end
end
function Options.display()
    if not has_values(Options.values) then return end
    local scroll_pos = e.read(0x6E)
    if scroll_pos >= 3 then
        e.draw_rect(240 - scroll_pos*8, 160, 220, 207, e.scroll_color)
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
    p1 = e.read(0x0068) -- Left scroll
    p2 = e.read(0x006E) -- Bottom scroll
    if p1 == 0 then return end
    -- Fully in: 1 and 1
    -- Fully out: 22 and 27
    -- Middle: 13 and 14
    if p1 > 13 then
        e.draw_rect(32, p1*8 + 32, 87, 240, e.oni_background)
    elseif p2 > 14 then
        e.draw_rect(0, 160, 231 - p2*8, 207, e.oni_background)
    else
        e.draw_rect(32, p1*8 + 32, 87, 240, e.oni_background)
        e.draw_rect(0, 160, 231 - p2*8, 207, e.oni_background)
    end
    if p1 < 13 then
        e.draw_rect(32, p1*8 + 32, 87, 140, e.oni_background)
    end
    if p2 < 14 then
        e.draw_rect(110, 160, 231 - p2*8, 207, e.oni_background)
    end
    function draw_scroll(i, color)
        e.draw_rect(32, p1*8 + 24 + i, 87, p1*8 + 24 + i, color)
        e.draw_rect(232 - p2*8 + i, 160, 232 - p2*8 + i, 207, color)
    end
    draw_scroll(0, e.black)
    draw_scroll(1, e.dark_scroll)
    draw_scroll(2, e.scroll_color)
    draw_scroll(3, e.dark_scroll)
    draw_scroll(4, e.dark_scroll)
    draw_scroll(5, e.black)
    draw_scroll(6, e.black)
    draw_scroll(7, e.dark_scroll)
end

function on_write_option()
    if e.read(0x008B) == 0 then
        Options.need_updating = true
    end
end

function on_write_message()
    Messages.need_updating = true
end

e.register_write(0x052F, on_write_option)
e.register_write(0x0547, on_write_message)
e.register_write(0x0569, on_write_message)
e.register_write(0x058B, on_write_message)
e.register_save(clear_all)

function loop()
    if Messages.need_updating then
        Messages.add_message()
        Messages.need_updating = false
    end
    if Options.need_updating then
        Options.add_value()
        Options.need_updating = false
    end
    if e.get_pixel(16, 16) ~= 0 then
        Messages.display()
        Options.display()
        if e.read(0x0068) == 1 then
            Messages.current_message = nil
        end
        if e.read(0x006E) == 1 then
            Options.values = {}
        end
        draw_scrolls()
    end
end

e.register_frame(loop)
