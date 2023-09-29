local function draw_rect(x1, y1, x2, y2, color)
    emu.drawRectangle(x1, y1, x2 - x1 + 1, y2 - y1 + 1, color, true)
end
local function draw_text(x, y, str, foreground, background)
    emu.drawString(x, y, str, foreground, background)
end
local function log(string)
    emu.log(string)
end
local function read(address)
    return emu.read(address, emu.memType.cpuDebug)
end
local function get_pixel(x, y)
    local res = emu.getPixel(x, y)
    if res == 0 then return 0
    else return 1 end
end
local function get_pixel2(x, y)
    return emu.getPixel(x, y)
end
local function get_framecount()
    return emu.getState()["ppu"]["frameCount"]
end
local function register_write(address, callback)
    local function f(address, value)
        callback(value)
    end
    emu.addMemoryCallback(f, emu.memCallbackType.cpuWrite, address)
end
local function register_exec(address, callback)
    emu.addMemoryCallback(callback, emu.memCallbackType.cpuExec, address)
end
local function register_save(callback)
    emu.addEventCallback(callback, emu.eventType.stateLoaded)
end
local function register_frame(callback)
    emu.addEventCallback(callback, emu.eventType.startFrame)
end
e = {
    clear = 0xFF000000,
    black = 0x000000,
    white = 0xFFFFFF,
    draw_rect = draw_rect,
    draw_text = draw_text,
    log = log,
    read = read,
    get_pixel = get_pixel,
    get_pixel2 = get_pixel2,
    get_framecount = get_framecount,
    register_write = register_write,
    register_exec = register_exec,
    register_save = register_save,
    register_frame = register_frame,
    unpack = table.unpack,
    prologue_offset = -1
}
