base_directory = "/home/sudgy/programs/emulators/nintendo_translations/"
--dofile(base_directory .. "mesen.lua")
dofile(base_directory .. "fceux.lua")

messages_filename = base_directory .. "time_twist_messages.bin"
options_filename = base_directory .. "time_twist_options.bin"

space_code = 172

function split(str, sep)
    local result = {}
    for s in string.gmatch(str, "(.-)" .. sep .. "()") do
        table.insert(result, s)
    end
    return result
end

function english_squash(lines_lines)
    local base_result = {}
    for _, lines in ipairs(lines_lines) do
        table.insert(base_result, table.concat(lines, "\n") .. "\n")
    end
    return table.concat(base_result)
end

function print_byte_string(string)
    e.log({string.byte(string, 1, #string)})
end

-- 8747-8806: Message, each one is 24 characters long (so 48 bytes, or 0x30)
--
--
-- 7FBA: New message written
-- 7FED: Message scrolled
-- 8032: 2nd line written
-- 8019: 3rd line written
-- 804B: 4th line written
-- 8000: 4th line written after message scrolled

function clear_all()
    japanese_lines = {}
    message_start_i = 1
    message_end_i = 0
    english_lines = nil
    current_english_lines = nil
    current_message_squashed_old = ""
    current_message_squashed_new = nil
    current_japanese_length = nil
    current_english_length = nil
    writing_time = 0
    current_drawing = nil
    scroll_time = 0
    scroll_amount = 1
    border_pos = 0
    gy = 0
    option_values = {}
    option_border_pos = 0
    option_window_visible = false
    message_window_visible = false
    bad_translation = true
end
clear_all()

function load_messages()
    local file = assert(io.open(messages_filename, "rb"))
    local data = file:read("*all")
    message_translations = {}
    local sections = split(data, "\1")
    for i=1,#sections/2 do
        local japanese_data = sections[2*i-1]
        local english_data = sections[2*i]
        local japanese_lines = split(japanese_data, "\2")
        local english_lines_base = split(english_data, "\2")
        local english_lines = {}
        for _, e in ipairs(english_lines_base) do
            table.insert(english_lines, split(e, "\3"))
        end
        if message_translations[japanese_lines[1]] == nil then
            message_translations[japanese_lines[1]] = {}
        end
        table.insert(
            message_translations[japanese_lines[1]],
            {
                japanese = japanese_lines,
                english = english_lines
            }
        )
    end
end
load_messages()

function load_options()
    local file = assert(io.open(options_filename), "rb")
    local data = file:read("*all")
    options_translations = {}
    local start_index = 1
    while true do
        local end_index = string.find(data, "\0", start_index)
        if end_index == nil then break end
        local japanese = string.sub(data, start_index, end_index - 1)
        start_index = end_index + 1
        end_index = string.find(data, "\0", start_index)
        local english = string.sub(data, start_index, end_index - 1)
        start_index = end_index + 1
        options_translations[japanese] = english
    end
end
load_options()

function add_line(line)
    table.insert(japanese_lines, string.char(e.unpack(line)))
end

function commit_message()
    if current_message_squashed_new ~= nil then
        e.log("Warning: previous message didn't finish writing")
    end

    while #japanese_lines[#japanese_lines] == 0 do
        table.remove(japanese_lines)
    end
    local old_end_i = message_end_i
    message_end_i = #japanese_lines

    if english_lines ~= nil then
        current_english_lines = english_lines
    else
        local possible_translations = message_translations[japanese_lines[1]]
        if possible_translations == nil then
            e.log("Unable to find translation for message")
            clear_all()
            return
        elseif #possible_translations == 1 then
            english_lines = possible_translations[1].english
            current_english_lines = english_lines
        else
            local actually_possible_translations = {}
            for _, translation in ipairs(possible_translations) do
                if #translation.japanese >= message_end_i then
                    local good = true
                    for i=1,message_end_i do
                        if translation.japanese[i] ~= japanese_lines[i] then
                            good = false
                            break
                        end
                    end
                    if good then
                        table.insert(actually_possible_translations,translation)
                    end
                end
            end
            possible_messages = {}
            for _, translation in ipairs(actually_possible_translations) do
                table.insert(
                    possible_messages,
                    english_squash({e.unpack(
                        translation.english,
                        message_start_i,
                        message_end_i
                    )})
                )
            end
            for i=2,#possible_messages do
                if possible_messages[1] ~= possible_messages[i] then
                    e.log("Translation conflict found")
                    clear_all()
                    return
                end
            end
            current_english_lines = actually_possible_translations[1].english
        end
    end

    local new_japanese_lines =
        table.concat({e.unpack(japanese_lines, old_end_i+1, message_end_i)})
    local new_english_lines_base =
        {e.unpack(current_english_lines, old_end_i+1, message_end_i)}
    local new_english_lines = english_squash(new_english_lines_base)
    current_message_squashed_new = new_english_lines
    current_japanese_length = #new_japanese_lines
    current_english_length = #current_message_squashed_new
    current_drawing = ""
    writing_time = 0
end

function read_line(line_num)
    local address = 0x8747 + 0x30*line_num
    local result = {}
    for i=0,47 do
        local byte = e.read(address + i)
        if (byte ~= space_code) then
            table.insert(result, byte)
        end
    end
    return result
end

function line1_written()
    --e.log("Line 1")
    if #japanese_lines < 1 then add_line(read_line(0)) end
    if #japanese_lines < 2 then add_line(read_line(1)) end
    if #japanese_lines < 3 then add_line(read_line(2)) end
    if #japanese_lines < 4 then add_line(read_line(3)) end
    commit_message()
end

function line2_written()
    --e.log("Line 2")
    add_line(read_line(1))
    add_line(read_line(2))
    add_line(read_line(3))
    commit_message()
end

function line3_written()
    --e.log("Line 3")
    add_line(read_line(2))
    add_line(read_line(3))
    commit_message()
end

function line4_written()
    --e.log("Line 4")
    add_line(read_line(3))
    commit_message()
end

function scroll_message()
    --e.log("Scrolled")
    message_start_i = message_start_i + 1
    current_message_squashed_old = english_squash({
        e.unpack(current_english_lines, message_start_i, message_end_i)})
    current_drawing = current_message_squashed_old
    scroll_time = 16
    scroll_amount = #current_english_lines[message_start_i - 1]
end

function option_added()
    -- I know now that this is a terrible name but it basically was just forcing
    -- the option window to be drawn when there were no options
    option_window_visible = false
    local value = {}
    for i=0,5 do
        local this_char = e.read(0x8747 + i*2)
        local this_dak = e.read(0x8748 + i*2)
        if this_char ~= space_code then
            table.insert(value, this_char)
            if this_dak ~= space_code then
                table.insert(value, this_dak)
            end
        end
    end
    if #value ~= 0 then
        local trans = options_translations[string.char(e.unpack(value))]
        if trans then
            table.insert(option_values, trans)
        else
            e.log("Could not find translation for option")
            table.insert(option_values, "UNKNOWN\n")
        end
    end
end

function draw_window(x, y, w, h)
    local x1 = x
    local y1 = y + gy
    local x2 = x + w
    local y2 = y + h + gy

    local border_color = e.get_pixel2(22, 140)
    local black = e.get_pixel2(23, 140)
    local background_color = e.get_pixel2(24, 140)
    if background_color == black then
        background_color = e.get_pixel2(56, 140)
        if background_color == black then
            background_color = e.get_pixel2(24, 148)
            -- Is this ever possible?
            if background_color == black then
                background_color = e.get_pixel2(56, 148)
            end
        end
    end

    -- Inside
    e.draw_rect(x1+8, y1+8, x2-9, y2-9, background_color)

    -- Left edge
    e.draw_rect(x1, y1, x1, y2 - 1, black)
    e.draw_rect(x1+1, y1+2, x1+1, y2 - 3, border_color)
    e.draw_rect(x1+2, y1+2, x1+2, y2 - 3, black)
    e.draw_rect(x1+3, y1+4, x1+3, y2 - 5, border_color)
    e.draw_rect(x1+4, y1+5, x1+4, y2 - 6, border_color)
    e.draw_rect(x1+5, y1+5, x1+5, y2 - 6, black)
    e.draw_rect(x1+6, y1+7, x1+6, y2 - 8, border_color)
    e.draw_rect(x1+7, y1+7, x1+7, y2 - 8, black)

    -- Right edge
    e.draw_rect(x2-1, y1, x2-1, y2 - 1, black)
    e.draw_rect(x2-2, y1+2, x2-2, y2 - 3, border_color)
    e.draw_rect(x2-3, y1+2, x2-3, y2 - 3, black)
    e.draw_rect(x2-4, y1+4, x2-4, y2 - 5, border_color)
    e.draw_rect(x2-5, y1+5, x2-5, y2 - 6, border_color)
    e.draw_rect(x2-6, y1+5, x2-6, y2 - 6, black)
    e.draw_rect(x2-7, y1+7, x2-7, y2 - 8, border_color)
    e.draw_rect(x2-8, y1+7, x2-8, y2 - 8, black)

    -- Top edge
    e.draw_rect(x1+1, y1, x2-2, y1, black)
    e.draw_rect(x1+2, y1+1, x2-3, y1+1, border_color)
    e.draw_rect(x1+3, y1+2, x2-4, y1+2, black)
    e.draw_rect(x1+4, y1+3, x2-5, y1+3, border_color)
    e.draw_rect(x1+5, y1+4, x2-6, y1+4, border_color)
    e.draw_rect(x1+6, y1+5, x2-7, y1+5, black)
    e.draw_rect(x1+7, y1+6, x2-8, y1+6, border_color)
    e.draw_rect(x1+8, y1+7, x2-9, y1+7, black)

    -- Bottom edge
    e.draw_rect(x1+1, y2-1, x2-2, y2-1, black)
    e.draw_rect(x1+2, y2-2, x2-3, y2-2, border_color)
    e.draw_rect(x1+3, y2-3, x2-4, y2-3, black)
    e.draw_rect(x1+4, y2-4, x2-5, y2-4, border_color)
    e.draw_rect(x1+5, y2-5, x2-6, y2-5, border_color)
    e.draw_rect(x1+6, y2-6, x2-7, y2-6, black)
    e.draw_rect(x1+7, y2-7, x2-8, y2-7, border_color)
    e.draw_rect(x1+8, y2-8, x2-9, y2-8, black)

    -- Missing corner pieces
    e.draw_rect(x1+1, y1+1, x1+1, y1+1, black)
    e.draw_rect(x1+3, y1+3, x1+3, y1+3, black)
    e.draw_rect(x1+4, y1+4, x1+4, y1+4, black)
    e.draw_rect(x1+6, y1+6, x1+6, y1+6, black)

    e.draw_rect(x2-2, y2-2, x2-2, y2-2, black)
    e.draw_rect(x2-4, y2-4, x2-4, y2-4, black)
    e.draw_rect(x2-5, y2-5, x2-5, y2-5, black)
    e.draw_rect(x2-7, y2-7, x2-7, y2-7, black)

    e.draw_rect(x1+1, y2-2, x1+1, y2-2, black)
    e.draw_rect(x1+3, y2-4, x1+3, y2-4, black)
    e.draw_rect(x1+4, y2-5, x1+4, y2-5, black)
    e.draw_rect(x1+6, y2-7, x1+6, y2-7, black)

    e.draw_rect(x2-2, y1+1, x2-2, y1+1, black)
    e.draw_rect(x2-4, y1+3, x2-4, y1+3, black)
    e.draw_rect(x2-5, y1+4, x2-5, y1+4, black)
    e.draw_rect(x2-7, y1+6, x2-7, y1+6, black)
end

function draw_message()
    if current_drawing == nil and not message_window_visible then return end
    draw_window(16, 132, 224, 88)
    if current_drawing == nil then return end
    message_window_visible = false
    local yp = gy + scroll_time * scroll_amount / 2
    if scroll_time ~= 0 then
        scroll_time = scroll_time - 1
    end

    if current_message_squashed_new ~= nil then
        writing_time = writing_time + 1
        if writing_time == current_japanese_length * 2 then
            current_message_squashed_old =
                current_message_squashed_old .. current_message_squashed_new
            current_message_squashed_new = nil
            current_drawing = current_message_squashed_old
        else
            local i = current_english_length * writing_time
                / (current_japanese_length * 2)
            current_drawing = current_message_squashed_old ..
                string.sub(current_message_squashed_new, 1, i) .. "\n"
        end
    end

    local i = 0
    for _, line in ipairs(split(current_drawing, "\n")) do
        e.draw_text(32, 149 + yp + 8*i, line, e.black, e.clear)
        i = i + 1
    end
end

function border_changed()
    border_pos = e.read(0x7A)
    if border_pos == 0x1B then
        --e.log("New message")
        clear_all()
        message_window_visible = true
    end
end

function option_border_changed()
    option_border_pos = e.read(0x74)
    if option_border_pos == 0x0A then
        --e.log("New options")
        option_values = {}
        option_window_visible = true
    end
end

function draw_options()
    if #option_values == 0 and not option_window_visible then return end
    draw_window(48, 132, 160, 88)
    for i=0,#option_values-1 do
        local text = option_values[i+1]
        local _, c = string.gsub(text, "\n", "")
        e.draw_text(
            72 + math.floor(i / 4) * 64,
            149 + gy + 16*(i % 4) - (c-1)*4,
            option_values[i+1], e.black, e.clear)
    end
end

function draw_option_border()
    if option_border_pos == 0x0A or option_border_pos == 0 then return end
    draw_window(48, 132, 160, 8 + option_border_pos*8)
end

function draw_border()
    if border_pos == 0x1B or border_pos == 0 then return end
    draw_window(16, 132, 8 + 8*border_pos, 88)
end

function draw_cursors()
    if border_pos ~= 0x1B and border_pos ~= 0 then return end
    if option_border_pos ~= 0x0A and option_border_pos ~= 0 then return end
    if #option_values == 0 and not option_window_visible then
        local cursor_color = e.get_pixel2(125, 208)
        e.draw_rect(125, 208, 129, 208, cursor_color)
        e.draw_rect(126, 209, 128, 209, cursor_color)
        e.draw_rect(127, 210, 127, 210, cursor_color)
    else
        for i=0,7 do
            local xp = math.floor(i/4)*64
            local yp = (i%4)*16
            local cursor_color = e.get_pixel2(67 + xp, 149 + yp)
            e.draw_rect(67 + xp, 149 + yp, 67 + xp, 155 + yp, cursor_color)
            e.draw_rect(68 + xp, 150 + yp, 68 + xp, 154 + yp, cursor_color)
            e.draw_rect(69 + xp, 151 + yp, 69 + xp, 153 + yp, cursor_color)
            e.draw_rect(70 + xp, 152 + yp, 70 + xp, 152 + yp, cursor_color)
            e.draw_rect(124 + xp, 149 + yp, 124 + xp, 155 + yp, cursor_color)
            e.draw_rect(123 + xp, 150 + yp, 123 + xp, 154 + yp, cursor_color)
            e.draw_rect(122 + xp, 151 + yp, 122 + xp, 153 + yp, cursor_color)
            e.draw_rect(121 + xp, 152 + yp, 121 + xp, 152 + yp, cursor_color)
        end
    end
end

function loop()
    if e.get_pixel2(23, 140) == e.get_pixel2(22, 140) then
        if current_message_squashed_old ~= "Please wait a moment.\n\n"
            or #option_values ~= 0
        then
            clear_all()
            return
        end
    end
    -- Stupid bouncing
    gy = 0
    if e.get_pixel2(24, 130) ~= e.get_pixel2(24, 131) then
        gy = -1
    end
    if not bad_translation then
        e.draw_rect(15, 131, 241, 221, e.get_pixel2(8, 8))
    end
    draw_message()
    draw_options()
    draw_option_border()
    draw_border()
    draw_cursors()
end

function safe_call(func)
    function result()
        local status, err = pcall(func)
        if not status then
            e.log(err)
        end
    end
    return result
end

e.register_exec(0x7FBA, safe_call(line1_written)) -- Start of a message
e.register_exec(0x8032, safe_call(line2_written)) -- When writing starts at the 2nd line
e.register_exec(0x8019, safe_call(line3_written)) -- When writing starts at the 3rd line
e.register_exec(0x804B, safe_call(line4_written)) -- When writing starts at the 4th line
e.register_exec(0x8000, safe_call(line4_written)) -- When writing after scrolling
e.register_exec(0x7FED, safe_call(scroll_message)) -- When just starting to scroll
e.register_exec(0x8947, safe_call(border_changed))
e.register_exec(0x946B, safe_call(option_added))
e.register_exec(0x8818, safe_call(option_border_changed))
e.register_frame(loop)

e.register_save(clear_all)
clear_all()
