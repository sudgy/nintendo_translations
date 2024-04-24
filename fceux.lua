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
local function register_before(callback)
    local old_callback = emu.registerbefore(nil)
    if old_callback ~= nil then
        function new_callback()
            old_callback()
            callback()
        end
        emu.registerbefore(new_callback)
    else
        emu.registerbefore(callback)
    end
end
local function register_frame(callback)
    register_before(callback)
end
local function register_input(callback)
    function real_callback()
        -- I seriously don't know why I have to use 2 here when it should be 1
        -- and I'm worried that this doesn't usually work
        input = joypad.get(2)
        new_input = callback({
            up = input["up"],
            down = input["down"],
            left = input["left"],
            right = input["right"],
            a = input["A"],
            b = input["B"],
            start = input["start"],
            select = input["select"],
        })
        joypad.set(1, {
            up = new_input["up"],
            down = new_input["down"],
            left = new_input["left"],
            right = new_input["right"],
            A = new_input["a"],
            B = new_input["b"],
            start = new_input["start"],
            select = new_input["select"],
        })
    end
    register_before(real_callback)
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
    register_input = register_input,
    supports_rom_swap = supports_rom_swap,
    unpack = unpack,
    prologue_offset = 0
}
