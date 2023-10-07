base_directory = "FILL THIS IN"
--dofile(base_directory .. "mesen.lua")
dofile(base_directory .. "fceux.lua")

messages_filename = base_directory .. "girl_messages.bin"
options_filename = base_directory .. "girl_options.bin"

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
    Options.last_index = 255
    Messages.searching = false
    Messages.index = -1
    Messages.current_message = nil
    Messages.finished = true
    Messages.message_timer = 0
end

function read_last_message(length)
    local last_index = e.read(0x2D)
    local first_index = last_index - length
    if first_index >= 0 then
        return e.read_range(0x300 + first_index, length)
    else
        first_index = first_index + 256
        first_string = e.read_range(0x300 + first_index, 0x100 - first_index)
        second_string = e.read_range(0x300, last_index)
        return first_string .. second_string
    end
end

Messages = {}
Messages.searching = false
Messages.index = -1
Messages.start_search = -1
Messages.end_search = -1
Messages.current_message = nil
Messages.finished = true
Messages.message_timer = 0
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
function Messages.display()
    if Messages.slow_timer < Messages.total_time then
        Messages.slow_timer = Messages.slow_timer + 1
    end
    e.draw_rect(16, 148, 239, 216, e.black)
    local modified_message = string.gsub(Messages.current_message, "\\", "")
    local message_length = math.floor(
        #modified_message * Messages.slow_timer / Messages.total_time) + 1
    local index1 = 1
    local index2 = 1
    for c in Messages.current_message:gmatch"." do
        if index1 == message_length then break end
        if c ~= "\\" then index1 = index1 + 1 end
        index2 = index2 + 1
    end
    local current_message = Messages.current_message:sub(1, index2) .. "\n"
    local i = 0
    for line in current_message:gmatch("(.-)\n") do
        local x_offset = 1
        while string.byte(line, x_offset) == 92 do x_offset = x_offset + 1 end
        e.draw_text(
            23 + x_offset,
            152 + i*11,
            string.sub(line, x_offset),
            e.white,
            e.black
        )
        i = i + 1
    end
end
function Messages.update_writing()
    if Messages.current_message ~= nil then
        Messages.display()
        return
    end
    if Messages.index == -1 then
        Messages.searching = true
    end
end
function Messages.update_waiting()
    if Messages.current_message ~= nil then
        Messages.display()
    end
end
function Messages.update_blank()
    if Messages.message_timer == 0 then
        Messages.searching = false
        Messages.current_message = nil
        Messages.index = -1
        Messages.finished = false
    else
        Messages.message_timer = Messages.message_timer - 1
        Messages.display()
    end
end
function Messages.get(index)
    return string.byte(Messages.translations[index][1], Messages.index)
end
function Messages.value_changed()
    local start_byte = e.read(0x0048) * 0x100 + e.read(0x0047)
    --print(string.format("%x", start_byte))
    local too_much = e.read_range(start_byte, 0x80)
    local end_index = string.find(too_much, string.char(255))
    local message = string.sub(too_much, 1, end_index)
    orig_message = message
    message = string.gsub(message, string.char(138) .. ".", "")
    message = string.gsub(message, ".", function(d)
        return string.byte(d) ~= 0 and
               string.byte(d) ~= 134 and
               string.byte(d) ~= 139 and
               string.byte(d) ~= 140 and
               (string.byte(d) < 198 or string.byte(d) > 207) and
               string.byte(d) ~= 254 and
               string.byte(d) ~= 255 and d or '' end)
    if string.byte(message, 1) == 137 then
        message = message:sub(3)
    end
    message = string.gsub(message, ".", function(d)
        return string.byte(d) == 208 and string.char(12, 21, 52, 34, 84, 85) or d end)
    message = string.gsub(message, ".", function(d)
        return string.byte(d) == 209 and string.char(71, 71, 71) or d end)
    message = string.gsub(message, ".", function(d)
        return string.byte(d) == 210 and string.char(36, 160, 34, 68) or d end)
    message = string.gsub(message, ".", function(d)
        return string.byte(d) == 211 and string.char(10, 46, 41, 68) or d end)
    message = string.gsub(message, ".", function(d)
        return string.byte(d) == 212 and string.char(12, 27, 145, 68) or d end)
    message = string.gsub(message, ".", function(d)
        return string.byte(d) == 213 and string.char(25, 149, 16, 68) or d end)
    message = string.gsub(message, ".", function(d)
        return string.byte(d) == 214 and string.char(19, 40, 154, 68) or d end)
    message = string.gsub(message, ".", function(d)
        return string.byte(d) == 215 and string.char(19, 12, 26, 56, 12) or d end)
    message = string.gsub(message, ".", function(d)
        return string.byte(d) == 216 and string.char(47, 12, 19) or d end)
    message = string.gsub(message, ".", function(d)
        return string.byte(d) == 217 and string.char(23, 55, 23, 11) or d end)
    Messages.searching = false
    Messages.finished = true
    Messages.current_message = Messages.translations[message]
    local _, pause1 = message:gsub("[" .. string.char(63, 66, 67) .. "]", "")
    local _, pause2 = message:gsub("[" .. string.char(62) .. "]", "")
    Messages.total_time = #message * 5 + pause1*28 + pause2*4
    Messages.slow_timer = 0
    if Messages.current_message == nil then
        e.log("Unable to find translation for current message")
        e.log(tostring(string.byte(message, 1, 128)))
        e.log(tostring(string.byte(orig_message, 1, 128)))
    else
        Messages.message_timer = 10
    end
end

Options = {}
Options.changed = false
Options.values = {}
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
Options.last_index = 255
function Options.add_value(this_value)
    local this_index = (e.read(0x042B) + 1) % 256
    if this_index < Options.last_index then
        Options.values = {}
    end
    Options.last_index = this_index
    Options.changed = true
    local value = {}
    for i=0,6 do
        local this_char = e.read(0x0474 + i)
        local this_dak = e.read(0x046C + i)
        if i == 6 and this_value ~= -1 then
            this_char = this_value
        end
        if this_char == 0 then break end
        if this_char == 70 and #Options.values > 0 then return end
        if this_dak ~= 0 then table.insert(value, this_dak) end
        table.insert(value, this_char)
    end
    if #value == 0 then value = {0} end
    table.insert(Options.values, string.char(e.unpack(value)))
end
Options.clear_timer = 0
function Options.display_values()
    local black = e.get_pixel2(0, 0)
    local found = false
    for i = 1,16 do
        if black ~= e.get_pixel2(172, 29 + i) then
            found = true
            break
        end
    end
    if found then
        Options.clear_timer = 0
    else
        Options.clear_timer = Options.clear_timer + 1
        if Options.clear_timer == 1 then Options.values = {} end
    end
    if #Options.values == 0 then return end
    for i=1,7 do
        if Options.values[i] == nil then return end
        if string.byte(Options.values[i]) ~= 0 and string.byte(Options.values[i]) ~= 70 then
            local trans = Options.translations[Options.values[i]]
            if trans then
                e.draw_rect(168, 13 + i*16, 223, math.min(31 + i*16, 138), e.black)
                if trans.find(trans, "\n") then
                    trans = trans .. "\n"
                    local j = 0
                    for line in trans:gmatch("(.-)\n") do
                        e.draw_text(169, 13+j*8 + i*16, line, e.white, e.clear)
                        j = j+1
                    end
                else
                    e.draw_text(169, 17 + i*16, trans, e.white, e.clear)
                end
            else
                e.log("Could not find translation for option "
                    .. tostring(string.byte(Options.values[i], 1, 16)))
                Options.values[i] = string.char(0)
            end
        end
    end
end

function at_start_of_message()
    if e.read(0x0300) == 1 then
        if e.read(0x0301) == 34 then
            if e.read(0x0302) == 98 then
                return true
            end
        end
    end
    return false
end

function at_end_of_message()
    return bitand(e.read(0x004E), 0x7F) == 5
end

function at_title()
    return e.read(0x0400) == 22 and e.get_pixel2(140, 15) ~= e.get_pixel2(140, 16)
    --return e.read(0x0400) == 22 and
           --e.read(0x0405) == 56
end

load_message = string.char(21, 35, 48, 17, 0, 14, 40, 26, 17, 25, 20, 11)
function at_loading()
    return load_message == read_last_message(12) and
        e.get_pixel(80, 170) ~= e.get_pixel(81, 170)
end

save_message = string.char(45, 43, 50, 0, 71, 71, 71, 0, 83, 110, 99, 121)
function at_save()
    return save_message == read_last_message(12)
end

function at_name()
    return e.read(0x0402) == 39 and
           e.read(0x044C) == 4 and
           e.read(0x0023) == 127
end

function at_prologue_cutscene()
    return e.read(0x0023) == 14
    -- Other addresses/values you can use:
    -- 0x0024: 98
    -- 0x0026: 98
    -- 0x00A7: 5
    -- 0x01FC: 12
    -- 0x0493: 2
    -- 0x070E: 5
end

function display_title()
    local title_color = e.get_pixel2(0, 8)
    local title_color2 = e.get_pixel2(54, 86)
    local title_color3 = e.get_pixel2(97, 121)
    e.draw_rect(96, 114, 160, 164, title_color)
    e.draw_text(97, 121, "Start Investigation", title_color3, e.clear)
    e.draw_text(97, 137, "Continue Investigation", title_color3, e.clear)
    e.draw_text(54, 93, "Famicom Detective Club", title_color2, e.clear)
end

function display_loading()
    e.draw_rect(16, 148, 239, 216, e.black)
    e.draw_text(76, 180, "Please wait a moment.", e.white, e.black)
end

zenpen_a = string.char(23, 55, 38, 55, 34, 82, 43, 55, 54, 0, 23, 59, 29, 21, 28, 17, 25, 20, 11)
zenpen_b = string.char(34, 82, 43, 55, 54, 0, 23, 59, 29, 21, 28, 17, 25, 20, 11, 1, 34, 171, 83)
function display_switch()
    message = read_last_message(19)
    --print("Start")
    --for i=1,19 do
    --    print(string.byte(message, i))
    --end
    if message == zenpen_a then
        e.draw_rect(16, 148, 239, 216, e.black)
        e.draw_text(68, 167, "Please insert the A side", e.white, e.black)
        e.draw_text(78, 177, "of the first volume.", e.white, e.black)
    elseif message == zenpen_b then
        e.draw_rect(16, 148, 239, 216, e.black)
        e.draw_text(68, 167, "Please insert the B side", e.white, e.black)
        e.draw_text(78, 177, "of the first volume.", e.white, e.black)
    end
    --    e.draw_text(68, 175, "Please insert the B side", e.white, e.black)
    --    e.draw_text(78, 185, "of the second volume.", e.white, e.black)
    --    e.draw_text(68, 175, "Please insert the A side", e.white, e.black)
    --    e.draw_text(78, 185, "of the second volume.", e.white, e.black)
end

function display_save()
    e.draw_rect(16, 148, 239, 216, e.black)
    e.draw_text(86, 172, "Save - Start Button", e.white, e.black)
    e.draw_text(79, 188, "Cancel - B Button", e.white, e.black)
end

function display_name()
    clear_all()
    e.draw_rect(15, 156, 158, 172, e.black)
    e.draw_rect(32, 176, 230, 196, e.black)
    e.draw_rect(44, 192, 118, 212, e.black)
    e.draw_rect(130, 192, 230, 212, e.black)
    e.draw_text(46, 161, "Please enter your name.", e.white, e.black)
    e.draw_text(33, 184, "Select with D-pad, confirm with A button", e.white, e.black)
    e.draw_text(49, 200, "Space", e.white, e.black)
    e.draw_text(136, 200, "End registration", e.white, e.black)
end

prologue_count = 0
prologue_start = 0

function display_prologue()
    if prologue_start == 0 then
        prologue_start = e.get_framecount()
    end
    prologue_count = e.get_framecount() - prologue_start + e.prologue_offset
    if prologue_count < 300 then
        local text_color = e.get_pixel2(104, 104)
        e.draw_rect(16, 116, 239, 216, e.black)
        e.draw_text(96, 120, "Made in 1989", text_color, e.clear)
    elseif prologue_count < 1400 then
        -- ひとりで　がっこうに　いると
        -- うしろから　だれかのよぶこえがする
        -- ふりむくと　そこには
        -- ひとりの少女が　たっている・・・
        -- なにかを　いいたげな　さみしい少女が
        -- あなたのうしろに　たっている
        -- 一人で学校にいると
        -- 後ろから誰かの呼ぶ声がする
        -- 振り向くとそこには
        -- 一人の少女が立っている・・・
        -- 何かを言いたげな寂しい少女が
        -- あなたの後ろに立っている
        color = e.get_pixel2(56, 72)
        e.draw_rect(0, 0, 400, 400, e.black)
        e.draw_text(57, 73, "When you are alone at school,", color, e.clear)
        e.draw_text(57, 89, "you hear someone calling from behind.", color, e.clear)
        e.draw_text(57, 105, "Turning around, you see", color, e.clear)
        e.draw_text(57, 121, "a lone girl standing there...", color, e.clear)
        e.draw_text(57, 137, "A lonely girl, looking like she wants", color, e.clear)
        e.draw_text(57, 153, "to say something, standing behind you.", color, e.clear)
    else
        title_color = e.get_pixel2(56, 72)
        subtitle_color = e.get_pixel2(60, 145)
        e.draw_text(58, 89, "Famicom Detective Club", title_color, e.clear)
        e.draw_text(66, 174, "The Girl Who Stands Behind", subtitle_color, e.clear)
    end
end

e.register_save(clear_all)
e.register_write(0x047A, Options.add_value)
e.register_exec(0x89E7, Messages.value_changed)

previous_action = 0

function loop()
    local action = bitand(e.read(0x004E), 0x7f)
    if action == 3 then Messages.update_writing()
    elseif action == 4 then Messages.update_waiting()
    else Messages.update_blank()
    end
    previous_action = action
    Options.display_values()
    if at_title() then display_title() end
    if at_loading() then display_loading() end
    display_switch()
    if at_save() then display_save() end
    if at_name() then display_name() end
    if at_prologue_cutscene() then display_prologue() end
end

e.register_frame(loop)
