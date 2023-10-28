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
local function read_range(address, length)
    return memory.readbyterange(address, length)
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
local function register_read(address, callback)
    memory.registerread(address, callback)
end
local function register_exec(address, callback)
    memory.registerexec(address, callback)
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
    draw_rect = draw_rect,
    draw_text = draw_text,
    log = log,
    read = read,
    read_range = read_range,
    get_pixel = get_pixel,
    get_pixel2 = get_pixel2,
    get_framecount = get_framecount,
    register_write = register_write,
    register_read = register_read,
    register_exec = register_exec,
    register_save = register_save,
    register_frame = register_frame,
    supports_rom_swap = supports_rom_swap,
    unpack = unpack,
    prologue_offset = 0
}
