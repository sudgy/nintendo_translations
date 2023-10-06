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
function Messages.value_changed0(value)
    if e.read(0x002D) % 4 == 1 then Messages.value_changed(value) end
end
function Messages.value_changed1(value)
    if e.read(0x002D) % 4 == 2 then Messages.value_changed(value) end
end
function Messages.value_changed2(value)
    if e.read(0x002D) % 4 == 3 then Messages.value_changed(value) end
end
function Messages.value_changed3(value)
    if e.read(0x002D) % 4 == 0 then Messages.value_changed(value) end
end
function Messages.value_changed(value)
    if value == 0 then return end
    if bitand(e.read(0x004E), 0x7F) ~= 3 then return end
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
    for i=0,6 do
        local this_char = e.read(0x0474 + i)
        local this_dak = e.read(0x046C + i)
        if this_char == 0 then break end
        if this_char == 70 and #Options.values > 0 then return end
        if this_dak ~= 0 then table.insert(value, this_dak) end
        table.insert(value, this_char)
    end
    if #value == 0 then value = {0} end
    table.insert(Options.values, string.char(e.unpack(value)))
end
function Options.display_values()
    if Options.changed then
        Options.add_value()
    end
    Options.changed = false
    if at_loading() then
        Options.values = {}
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
    return e.read(0x0400) == 22 and
           e.read(0x0405) == 56
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
    e.draw_rect(96, 114, 160, 164, title_color)
    e.draw_text(97, 121, "Start Investigation", e.white, e.clear)
    e.draw_text(97, 137, "Continue Investigation", e.white, e.clear)
    e.draw_text(54, 93, "Famicom Detective Club", title_color2, e.clear)
end

function display_loading()
    e.draw_rect(16, 148, 239, 216, e.black)
    e.draw_text(76, 180, "Please wait a moment.", e.white, e.black)
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

e.register_write(0x047A, Options.add_value)
e.register_save(clear_all)

for i=0,63 do
    e.register_write(0x0300 + i*4, Messages.value_changed0)
    e.register_write(0x0301 + i*4, Messages.value_changed1)
    e.register_write(0x0302 + i*4, Messages.value_changed2)
    e.register_write(0x0303 + i*4, Messages.value_changed3)
end

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
    if at_name() then display_name() end
    if at_prologue_cutscene() then display_prologue() end
end

e.register_frame(loop)
