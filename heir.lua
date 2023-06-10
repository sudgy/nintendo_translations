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
end

Messages = {}
Messages.searching = false
Messages.index = -1
Messages.start_search = -1
Messages.end_search = -1
Messages.current_message = nil
Messages.finished = true
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
        table.insert(Messages.translations, {japanese, english})
    end
end
Messages.load_messages()
function Messages.display()
    e.draw_rect(16, 148, 239, 216, e.black)
    local i = 0
    for line in Messages.current_message:gmatch("(.-)\n") do
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
        Messages.index = 1
        Messages.start_search = 1
        Messages.end_search = #Messages.translations
    end
end
function Messages.update_waiting()
    if not Messages.finished then
        Messages.finished = true
        local current = Messages.translations[Messages.start_search]
        if #current[1] == Messages.index - 1 then
            Messages.current_message = current[2]
        else
            if Messages.get(Messages.start_search) ~= value then
                if Messages.current_message == nil then
                    e.log("Unable to find translation for current message")
                else
                    e.log("Sorry, false positive, this translation doesn't exist")
                    Messages.current_message = nil
                end
                Messages.searching = false
                return
            end
        end
    end
    Messages.searching = false
    -- This can happen if a translation wasn't found
    if Messages.current_message ~= nil then Messages.display() end
end
function Messages.update_blank()
    Messages.searching = false
    Messages.current_message = nil
    Messages.index = -1
    Messages.finished = false
end
function Messages.get(index)
    return string.byte(Messages.translations[index][1], Messages.index)
end
function Messages.value_changed(value)
    if value == 0 then return end
    if bitand(e.read(0x0059), 0x7F) ~= 4 then return end
    if Messages.finished then return end
    if Messages.searching then
        local temp_end = Messages.end_search
        while Messages.get(Messages.start_search) ~= value do
            local temp_index = math.floor((Messages.start_search + temp_end)/2)
            if temp_index == Messages.start_search then
                Messages.start_search = temp_end
                break
            end
            if Messages.get(temp_index) < value then
                Messages.start_search = temp_index
            else
                temp_end = temp_index
            end
        end

        if Messages.get(Messages.start_search) ~= value then
            e.log("Unable to find translation for current message")
            Messages.searching = false
            Messages.finished = true
            return
        end

        local temp_start = Messages.start_search
        while Messages.get(Messages.end_search) ~= value do
            local temp_index = math.floor((temp_start + Messages.end_search)/2)
            if temp_index == temp_start then
                Messages.end_search = temp_start
            end
            if Messages.get(temp_index) == value then
                temp_start = temp_index
            else
                Messages.end_search = temp_index
            end
        end

        if Messages.start_search == Messages.end_search then
            Messages.searching = false
            Messages.current_message = Messages.translations[Messages.end_search][2]
        end
    else
        if Messages.get(Messages.start_search) ~= value then
            e.log("Sorry, false positive, this translation doesn't exist")
            Messages.current_message = nil
            Messages.finished = true
        end
    end

    Messages.index = Messages.index + 1
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
function Options.reset_values()
    Options.values = {}
end
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
function Options.display_values()
    if Options.changed then
        Options.add_value()
    end
    Options.changed = false
    if e.read(0x0405) == 15 and not Options.in_maze then
        Options.values = {}
    end
    if e.read(0x0337) == 8 then
        Options.values = {}
    end
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

function at_loading()
    return e.read(0x0004) >= 196 and
           e.read(0x00FE) ~= 6
end

function at_switch()
    return e.read(0x0100) == 128
end

function at_save()
    return e.read(0x0001) == 218
end

function at_name()
    return e.read(0x0059) == 3 and
           e.read(0x005A) == 6 and
           e.read(0x005B) == 17
end

function at_prologue_cutscene()
    return e.read(0x0030) == 130
end

function display_title()
    e.draw_rect(96, 130, 160, 180, e.title_color)
    e.draw_text(97, 137, "Start Investigation", e.white, e.clear)
    e.draw_text(97, 153, "Continue Investigation", e.white, e.clear)
    e.draw_text(20, 96, "Famicom", e.title_color2, e.clear)
    e.draw_text(4, 108, "Detective Club", e.title_color2, e.clear)
end

function display_loading()
    e.draw_rect(16, 148, 239, 216, e.black)
    e.draw_text(76, 180, "Please wait a moment.", e.white, e.black)
end

function display_switch()
    if e.get_pixel(68, 179, true) == 0 then return end
    e.draw_rect(16, 148, 239, 216, e.black)
    local to_b = e.get_pixel(94, 177, true) ~= 0
    local to_volume_1 = e.get_pixel(71, 175, true) ~= 0
    if to_b and to_volume_1 then
        e.draw_text(68, 175, "Please insert the B side", e.white, e.black)
        e.draw_text(78, 185, "of the first volume.", e.white, e.black)
    elseif to_volume_1 then
        e.draw_text(68, 175, "Please insert the A side", e.white, e.black)
        e.draw_text(78, 185, "of the first volume.", e.white, e.black)
    elseif to_b then
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
    e.draw_rect(16, 168, 239, 216, e.black)
    e.draw_rect(16, 148, 70, 168, e.black)
    e.draw_rect(99, 148, 239, 168, e.black)
    e.draw_text(26, 153, "Shmoby: \"", e.white, e.black)
    e.draw_text(98, 153, "!\"", e.white, e.black)
    e.draw_text(34, 177, "- Please enter what you have deduced -", e.white, e.black)
    e.draw_text(26, 193, "- D-Pad to select   - A button to confirm", e.white, e.black)
end

function display_deduce2()
    e.draw_rect(16, 168, 239, 216, e.black)
    e.draw_rect(16, 148, 70, 168, e.black)
    e.draw_rect(99, 148, 239, 168, e.black)
    e.draw_text(26, 153, "Shmoby: \"", e.white, e.black)
    e.draw_text(98, 153, "!\"", e.white, e.black)
end

function display_deduce3()
    e.draw_rect(16, 148, 239, 148 + 16, e.black)
    e.draw_rect(100, 148 + 16, 239, 148 + 32, e.black)
    e.draw_text(31, 153, "Shmoby: That place is...inside the", e.white, e.black)
end

prologue_count = 0
prologue_start = 0

function display_prologue()
    if prologue_start == 0 then
        prologue_start = e.get_framecount()
    end
    prologue_count = e.get_framecount() - prologue_start + e.prologue_offset
    function draw_message(color)
        e.draw_text(81, 73, "If anyone does a wrong", color, e.clear)
        e.draw_text(81, 89, "to the Ayashiro house,", color, e.clear)
        e.draw_text(81, 105, "I,", color, e.clear)
        e.draw_text(81, 121, "from the world of the dead,", color, e.clear)
        e.draw_text(81, 137, "will come back to life", color, e.clear)
        e.draw_text(81, 153, "and bring about", color, e.clear)
        e.draw_text(81, 169, "the same disaster to them...", color, e.clear)
    end
    if prologue_count < 44 then
    elseif prologue_count < 50 then
        e.draw_rect(16, 116, 239, 216, e.black)
        e.draw_text(96, 120, "Made in 1988", e.gray, e.clear)
    elseif prologue_count < 284 then
        e.draw_rect(16, 116, 239, 216, e.black)
        e.draw_text(96, 120, "Made in 1988", e.white, e.clear)
    elseif prologue_count < 290 then
        e.draw_rect(16, 116, 239, 216, e.black)
        e.draw_text(96, 120, "Made in 1988", e.gray, e.clear)
    elseif prologue_count < 384 then
    elseif prologue_count < 390 then
        e.draw_rect(0, 0, 239, 216, e.black)
        draw_message(e.gray)
    elseif prologue_count < 978 then
        e.draw_rect(0, 0, 239, 216, e.black)
        draw_message(e.white)
    elseif prologue_count < 984 then
        e.draw_rect(0, 0, 239, 216, e.dark_sky)
        draw_message(e.white)
    elseif prologue_count < 1038 then
        e.draw_rect(0, 0, 239, 216, e.bright_sky)
        draw_message(e.white)
    elseif prologue_count < 1044 then
        e.draw_rect(0, 0, 239, 216, e.bright_sky)
        draw_message(e.gray)
    elseif prologue_count < 1700 then
    elseif prologue_count < 1706 then
        e.draw_text(114, 124, "Famicom", e.title1_color, e.clear)
        e.draw_text(100, 136, "Detective Club", e.title1_color, e.clear)
    elseif prologue_count < 1880 then
        e.draw_text(114, 124, "Famicom", e.title2_color, e.clear)
        e.draw_text(100, 136, "Detective Club", e.title2_color, e.clear)
    elseif prologue_count < 1886 then
        e.draw_text(114, 124, "Famicom", e.title2_color, e.clear)
        e.draw_text(100, 136, "Detective Club", e.title2_color, e.clear)
        e.draw_text(94, 188, "The Missing Heir", e.subtitle1_color, e.clear)
    elseif prologue_count < 2492 then
        e.draw_text(114, 124, "Famicom", e.title2_color, e.clear)
        e.draw_text(100, 136, "Detective Club", e.title2_color, e.clear)
        e.draw_text(94, 188, "The Missing Heir", e.subtitle2_color, e.clear)
    else
        prologue_count = 0
    end
end

e.register_write(0x0614, Options.add_value)
e.register_save(clear_all)

for i=0,63 do
    e.register_write(0x0303 + i*4, Messages.value_changed)
end

previous_action = 0

function loop()
    local action = bitand(e.read(0x0059), 0x7f)
    if action == 4 then Messages.update_writing()
    elseif action == 5 then Messages.update_waiting()
    elseif action == 2 and previous_action == 2 and e.read(0x005A) == 16 and e.read(0x005B) == 6 then display_deduce()
    elseif action == 2 and previous_action == 2 and e.read(0x005A) == 68 and e.read(0x005B) == 6 then display_deduce2()
    elseif action == 2 and previous_action == 2 and e.read(0x005A) == 14 and e.read(0x005B) == 6 then display_deduce3()
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
