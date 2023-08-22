local function draw_rect(x1, y1, x2, y2, color)
    gui.box(x1, y1, x2, y2, color)
end
local function draw_text(x, y, str, foreground, background)
    gui.text(x, y, str, foreground, background)
end
local function log(string)
    emu.print(string)
end
local function read(address)
    return memory.readbyteunsigned(address)
end
local function get_pixel(x, y)
    local res = emu.getscreenpixel(x, y, true)
    if res == 0 then return 0
    else return 1 end
end
local function get_pixel2(x, y)
    local r,g,b,p = emu.getscreenpixel(x, y, true)
    return "P" .. string.format("%x", p)
end
local function get_framecount()
    return emu.framecount()
end
local function register_write(address, callback)
    local function f(address, size, value)
        callback(value)
    end
    memory.register(address, f)
end
local function register_save(callback)
    savestate.registerload(callback)
end
local function register_frame(callback)
    emu.registerbefore(callback)
end
local function supports_rom_swap()
    return true
end
e = {
    clear = "clear",
    black = "black",
    white = "white",
    gray = "#747474",
    title_color = "#2038ec",
    title_color2 = "#d82800",
    dark_sky = "#24188c",
    bright_sky = "#0070ec",
    title1_color = "#fc7460",
    title2_color = "#fcbcb0",
    subtitle1_color = "#8000f0",
    subtitle2_color = "#00e8d8",
    scroll_color = "#ffbeb2",
    dark_scroll = "#cb4d0c",
    cursor_color = "#db2800",
    oni_background = "#183c5d",
    draw_rect = draw_rect,
    draw_text = draw_text,
    log = log,
    read = read,
    get_pixel = get_pixel,
    get_pixel2 = get_pixel2,
    get_framecount = get_framecount,
    register_write = register_write,
    register_save = register_save,
    register_frame = register_frame,
    supports_rom_swap = supports_rom_swap,
    unpack = unpack,
    prologue_offset = 0
}
