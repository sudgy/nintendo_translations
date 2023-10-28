base_directory = "FILL THIS IN"
--dofile(base_directory .. "mesen.lua")
dofile(base_directory .. "fceux.lua")

messages_filename = base_directory .. "heir_messages.bin"
options_filename = base_directory .. "heir_options.bin"

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
    Messages.searching = false
    Messages.index = -1
    Messages.current_message = nil
    Messages.finished = true
    Messages.message_timer = 0
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
function Messages.value_changed(value)
    if Messages.current_message ~= nil or Messages.searching then
        return
    end
    local start_byte = e.read(0x01) * 0x100 + e.read(0x00)
    --print(string.format("%x", start_byte))
    local too_much = e.read_range(start_byte, 0x80)
    local end_index = string.find(too_much, string.char(255))
    local message = string.sub(too_much, 1, end_index)
    orig_message = message
    message = string.gsub(message, string.char(134) .. ".....", "")
    message = string.gsub(message, ".", function(d)
        return string.byte(d) ~= 0 and
               string.byte(d) ~= 128 and
               string.byte(d) ~= 130 and
               string.byte(d) ~= 131 and
               (string.byte(d) < 242 or string.byte(d) > 247) and
               string.byte(d) ~= 254 and
               string.byte(d) ~= 255 and d or '' end)
    --if string.byte(message, 1) == 137 then
    --    message = message:sub(3)
    --end
    message = string.gsub(message, ".", function(d)
        return string.byte(d) == 224 and string.char(12, 152, 22, 80) or d end)
    message = string.gsub(message, ".", function(d)
        return string.byte(d) == 225 and string.char(42, 22, 15, 80) or d end)
    message = string.gsub(message, ".", function(d)
        return string.byte(d) == 226 and string.char(12, 17, 35, 80) or d end)
    message = string.gsub(message, ".", function(d)
        return string.byte(d) == 227 and string.char(17, 57, 151, 80) or d end)
    message = string.gsub(message, ".", function(d)
        return string.byte(d) == 228 and string.char(63, 81) or d end)
    message = string.gsub(message, ".", function(d)
        return string.byte(d) == 229 and string.char(148, 57, 23, 57, 80) or d end)
    message = string.gsub(message, ".", function(d)
        return string.byte(d) == 235 and string.char(19, 42, 155, 80) or d end)
    message = string.gsub(message, ".", function(d)
        return string.byte(d) == 236 and string.char(12, 42, 28, 80) or d end)
    message = string.gsub(message, ".", function(d)
        return string.byte(d) == 248 and string.char(80) or d end)
    message = string.gsub(message, ".", function(d)
        return string.byte(d) == 249 and string.char(153, 57, 154, 14, 80) or d end)
    message = string.gsub(message, ".", function(d)
        return string.byte(d) == 250 and string.char(126, 126, 126) or d end)
    message = string.gsub(message, ".", function(d)
        return string.byte(d) == 251 and string.char(12, 47, 23, 54, 20) or d end)
    Messages.searching = false
    Messages.finished = true
    Messages.current_message = Messages.translations[message]
    local _, pause1 = message:sub(1, -2):gsub("[" .. string.char(63, 76, 77) .. "]", "")
    local _, pause2 = message:gsub("[" .. string.char(62) .. "]", "")
    Messages.total_time = #message * 5 + pause1*28 + pause2*4
    Messages.slow_timer = 0
    if Messages.current_message == nil then
        e.log("Unable to find translation for current message")
        e.log(tostring(string.byte(message, 1, 128)))
        e.log(tostring(string.byte(orig_message, 1, 128)))
        Messages.searching = true
    else
        Messages.message_timer = 10
        if Messages.current_message == "DEDUCE1\n" then
            Messages.current_message = nil
            Messages.searching = true
            Messages.message_timer = 10
            in_deduce = 1
        elseif Messages.current_message == "DEDUCE2\n" then
            Messages.current_message = nil
            Messages.searching = true
            Messages.message_timer = 45
            in_deduce = 2
        elseif Messages.current_message == "DEDUCE3\n" then
            Messages.current_message = nil
            Messages.searching = true
            Messages.message_timer = 48
            in_deduce = 3
        end
    end
end

Options = {}
Options.changed = false
Options.values = {}
Options.in_maze = false
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
    if not Options.changed then
        Options.values = {}
    end
    Options.changed = true
    local value = {}
    for i=0,7 do
        local this_char = e.read(0x060D + i)
        local this_dak = e.read(0x0605 + i)
        if this_char == 0 then break end
        table.insert(value, this_char)
        if this_dak ~= 0 then table.insert(value, this_dak) end
    end
    if #value == 0 then value = {0} end
    table.insert(Options.values, string.char(e.unpack(value)))
    if #Options.values > 7 then
        table.remove(Options.values, 1)
    end
end
Options.clear_timer = 0
function Options.display_values()
    if Options.changed then
        Options.add_value()
    end
    Options.changed = false
    local black = e.get_pixel2(176, 16)
    local found = false
    for i = 1,16 do
        if black ~= e.get_pixel2(188, 31 + i) then
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
    --if e.read(0x0405) == 15 and not Options.in_maze then
    --    Options.values = {}
    --end
    --if e.read(0x0337) == 8 then
    --    Options.values = {}
    --end
    if #Options.values == 0 then return end
    for i=1,7 do
        if Options.values[i] == nil then return end
        if string.byte(Options.values[i]) ~= 0 and string.byte(Options.values[i]) ~= 123 then
            local trans = Options.translations[Options.values[i]]
            if trans then
                e.draw_rect(184, 5 + i*16, 239, math.min(23 + i*16, 127), e.black)
                if trans.find(trans, "\n") then
                    trans = trans .. "\n"
                    local j = 0
                    for line in trans:gmatch("(.-)\n") do
                        e.draw_text(185, 5+j*8 + i*16, line, e.white, e.clear)
                        j = j+1
                    end
                else
                    e.draw_text(185, 9 + i*16, trans, e.white, e.clear)
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
    return bitand(e.read(0x0059), 0x7F) == 5
end

function at_title()
    return e.read(0x0400) == 18 and
           e.read(0x0405) == 22
end

in_loading = false
first_loading = false
function at_loading()
    if in_loading then
        if e.get_pixel2(82, 176) == e.get_pixel2(81, 176) then
            if first_loading then
                first_loading = false
            else
                in_loading = false
            end
        end
    end
    return in_loading
end
function set_loading()
    in_loading = true
    first_loading = true
    display_loading()
end

in_switch = 0
first_switch = false
function at_switch()
    if in_switch ~= 0 then
        if e.get_pixel2(153, 176) == e.get_pixel2(154, 176) then
            if first_switch then
                first_switch = false
            else
                in_switch = 0
            end
        end
    end
    return in_switch ~= 0
end
function set_zenpen_a()
    in_switch = 1
    first_switch = true
    display_switch()
end
function set_zenpen_b()
    in_switch = 2
    first_switch = true
    display_switch()
end
function set_kouhen_a()
    in_switch = 3
    first_switch = true
    display_switch()
end
function set_kouhen_b()
    in_switch = 4
    first_switch = true
    display_switch()
end

in_save = false
just_in_save = false
function at_save()
    if just_in_save then
        just_in_save = false
        return true
    end
    if in_save then
        if e.get_pixel2(67, 191) == e.get_pixel2(68, 191) then
            in_save = false
        end
    end
    return in_save
end
function set_save()
    in_save = true
    just_in_save = true
    display_save()
end

in_name = false
function at_name()
    if e.read(0x005A) == 6 and e.read(0x005B) == 17 then
        if e.read(0x0059) == 3 then
            in_name = true
        end
    else
        if e.read(0x005A) == 12 then
            in_name = false
        end
    end
    return in_name
end

function at_prologue_cutscene()
    return e.read(0x0030) == 130
end

function display_title()
    local title_color = e.get_pixel2(0, 8)
    local title_color2 = e.get_pixel2(72, 64)
    e.draw_rect(96, 130, 160, 180, title_color)
    e.draw_text(97, 137, "Start Investigation", e.white, e.clear)
    e.draw_text(97, 153, "Continue Investigation", e.white, e.clear)
    e.draw_text(20, 96, "Famicom", title_color2, e.clear)
    e.draw_text(4, 108, "Detective Club", title_color2, e.clear)
end

function display_loading()
    e.draw_rect(16, 148, 239, 216, e.black)
    e.draw_text(76, 180, "Please wait a moment.", e.white, e.black)
end

function display_switch()
    e.draw_rect(16, 148, 239, 216, e.black)
    if in_switch == 2 then
        e.draw_text(68, 175, "Please insert the B side", e.white, e.black)
        e.draw_text(78, 185, "of the first volume.", e.white, e.black)
    elseif in_switch == 1 then
        e.draw_text(68, 175, "Please insert the A side", e.white, e.black)
        e.draw_text(78, 185, "of the first volume.", e.white, e.black)
    elseif in_switch == 4 then
        e.draw_text(68, 175, "Please insert the B side", e.white, e.black)
        e.draw_text(78, 185, "of the second volume.", e.white, e.black)
    else
        e.draw_text(68, 175, "Please insert the A side", e.white, e.black)
        e.draw_text(78, 185, "of the second volume.", e.white, e.black)
    end
end

function display_save()
    e.draw_rect(16, 148, 239, 216, e.black)
    e.draw_text(86, 172, "Save - Start Button", e.white, e.black)
    e.draw_text(79, 188, "Cancel - B Button", e.white, e.black)
end

function display_name()
    e.draw_rect(16, 148, 158, 164, e.black)
    e.draw_rect(209, 177, 239, 216, e.black)
    e.draw_text(26, 153, "Please enter your name.", e.white, e.black)
    e.draw_text(209, 177, "Next", e.white, e.black)
    e.draw_text(209, 193, "Back", e.white, e.black)
    e.draw_text(209, 209, "End", e.white, e.black)
end

function display_deduce()
    local action = bitand(e.read(0x0059), 0x7f)
    if Messages.slow_timer < Messages.total_time then
        Messages.slow_timer = Messages.slow_timer + 1
    end
    if in_deduce == 1 then
        e.draw_rect(16, 168, 239, 216, e.black)
        e.draw_rect(16, 148, 70, 168, e.black)
        e.draw_rect(99, 148, 239, 168, e.black)
        local str1 = "Shmoby: \""
        local str2 = "!\""
        local str3 = "- Please enter what you have deduced -"
        local str4 = "- D-Pad to select   - A button to confirm"
        local len1 = #str1
        local len2 = #str2
        local len3 = #str3
        local len4 = #str4
        local total_len = len1 + len2 + len3 + len4
        local this_len = math.floor(
            total_len * Messages.slow_timer / Messages.total_time) + 1
        local fstr1 = str1:sub(1, this_len)
        local fstr2 = str2:sub(1, math.max(this_len - len1, 0))
        local fstr3 = str3:sub(1, math.max(this_len - len1 - len2, 0))
        local fstr4 = str4:sub(1, math.max(this_len - len1 - len2 - len3, 0))
        e.draw_text(26, 153, fstr1, e.white, e.black)
        e.draw_text(98, 153, fstr2, e.white, e.black)
        e.draw_text(34, 177, fstr3, e.white, e.black)
        e.draw_text(26, 193, fstr4, e.white, e.black)
    elseif in_deduce == 2 then
        e.draw_rect(16, 168, 239, 216, e.black)
        e.draw_rect(16, 148, 70, 168, e.black)
        e.draw_rect(99, 148, 239, 168, e.black)
        local str1 = "Shmoby: \""
        local str2 = "!\""
        local len1 = #str1
        local len2 = #str2
        local total_len = len1 + len2
        local this_len = math.floor(
            total_len * Messages.slow_timer / Messages.total_time) + 1
        local fstr1 = str1:sub(1, this_len)
        local fstr2 = str2:sub(1, math.max(this_len - len1, 0))
        e.draw_text(26, 153, fstr1, e.white, e.black)
        e.draw_text(98, 153, fstr2, e.white, e.black)
    elseif in_deduce == 3 then
        e.draw_rect(16, 148, 239, 148 + 16, e.black)
        e.draw_rect(100, 148 + 16, 239, 148 + 32, e.black)
        local str = "Shmoby: That place is...inside the"
        local len = #str
        local this_len = math.floor(
            len * Messages.slow_timer / Messages.total_time) + 1
        local fstr = str:sub(1, this_len)
        e.draw_text(31, 153, fstr, e.white, e.black)
    end
    if Messages.slow_timer == Messages.total_time then
        if action ~= 2 then
            Messages.message_timer = Messages.message_timer - 1
            if Messages.message_timer == 0 then
                Messages.searching = false
                Messages.current_message = nil
                Messages.index = -1
                Messages.finished = false
                in_deduce = 0
            end
        end
    end
end

prologue_count = 0
prologue_start = 0

function display_prologue()
    if prologue_start == 0 then
        prologue_start = e.get_framecount()
    end
    prologue_count = e.get_framecount() - prologue_start + e.prologue_offset
    function draw_message(color)
        e.draw_text(81, 73, "If anyone does wrong", color, e.clear)
        e.draw_text(81, 89, "to the Ayashiro house,", color, e.clear)
        e.draw_text(81, 105, "I,", color, e.clear)
        e.draw_text(81, 121, "from the world of the dead,", color, e.clear)
        e.draw_text(81, 137, "will come back to life", color, e.clear)
        e.draw_text(81, 153, "and bring about", color, e.clear)
        e.draw_text(81, 169, "the same disaster to them...", color, e.clear)
    end
    if prologue_count < 44 then
    elseif prologue_count < 290 then
        local text_color = e.get_pixel2(104, 104)
        e.draw_rect(16, 116, 239, 216, e.black)
        e.draw_text(96, 120, "Made in 1988", text_color, e.clear)
    elseif prologue_count < 384 then
    elseif prologue_count < 1044 then
        local background_color = e.get_pixel2(0, 8)
        local text_color = e.get_pixel2(81, 73)
        e.draw_rect(0, 0, 239, 216, background_color)
        draw_message(text_color)
    elseif prologue_count < 1700 then
    elseif prologue_count < 2492 then
        local title2_color = e.get_pixel2(72, 64)
        local subtitle1_color = e.get_pixel2(80, 160)
        e.draw_text(114, 124, "Famicom", title2_color, e.clear)
        e.draw_text(100, 136, "Detective Club", title2_color, e.clear)
        e.draw_text(94, 188, "The Missing Heir", subtitle1_color, e.clear)
    else
        prologue_count = 0
    end
end

e.register_write(0x0614, Options.add_value)
e.register_save(clear_all)
e.register_exec(0xC66E, Messages.value_changed)

e.register_read(0xA3D3, set_loading)
e.register_read(0xA3ED, set_zenpen_a)
e.register_read(0xA40F, set_zenpen_b)
e.register_read(0xA42B, set_kouhen_a)
e.register_read(0xA447, set_kouhen_b)
e.register_read(0x9DB0, set_save)

previous_action = 0
in_deduce = 0

function loop()
    local action = bitand(e.read(0x0059), 0x7f)
    if in_deduce ~= 0 then display_deduce()
    elseif action == 4 then Messages.update_writing()
    elseif action == 5 then Messages.update_waiting()
    else Messages.update_blank()
    end
    previous_action = action
    if e.read(0x00A3) == 255 and e.read(0x0415) == 15 and e.read(0x041D) == 15
        and e.read(0x041E) == 15 and e.read(0x0442) == 6 then
        Options.in_maze = true
    else
        Options.in_maze = false
    end
    Options.display_values()
    if at_title() then display_title() end
    if at_loading() then display_loading() end
    if at_switch() then display_switch() end
    if at_save() then display_save() end
    if at_name() then display_name() end
    if at_prologue_cutscene() or prologue_count ~= 0 then display_prologue() end
end

e.register_frame(loop)
