-- egui.lua - Love2D integration module for egui
-- This module provides a bridge between Love2D and the egui Rust library

local ffi = require("ffi")
local bit = require("bit")

-- FFI declarations for the Rust library
ffi.cdef[[
    int egui_love2d_init(float width, float height);
    void egui_love2d_shutdown();
    int egui_love2d_begin_frame(float dt);
    int egui_love2d_end_frame();
    int egui_love2d_handle_key(const char* key, int pressed);
    int egui_love2d_handle_text(const char* text);
    int egui_love2d_handle_mouse_button(float x, float y, int button, int pressed);
    int egui_love2d_handle_mouse_move(float x, float y);
    int egui_love2d_handle_wheel(float x, float y);
]]

local egui = {}

-- Load the dynamic library
local lib = nil
local function load_library()
    local system = love.system.getOS()
    local lib_name
    
    if system == "Windows" then
        lib_name = "egui_love2d.dll"
    elseif system == "OS X" then
        lib_name = "libegui_love2d.dylib"
    else
        lib_name = "libegui_love2d.so"
    end
    
    -- Try to load from different possible locations
    local possible_paths = {
        "./" .. lib_name,
        "egui-love2d/target/release/" .. lib_name,
        "lib/" .. lib_name,
        "/usr/local/lib/" .. lib_name,
    }
    
    for _, path in ipairs(possible_paths) do
        local ok, result = pcall(ffi.load, path)
        if ok then
            lib = result
            print("Loaded egui library from: " .. path)
            return true
        end
    end
    
    error("Could not load egui library. Tried: " .. table.concat(possible_paths, ", "))
end

-- State
local initialized = false
local ui_commands = {}

-- Helper functions
local function love_key_to_string(key)
    -- Convert Love2D key constants to strings
    return tostring(key)
end

local function love_button_to_number(button)
    -- Convert Love2D mouse button to number
    if button == 1 or button == "l" then return 1
    elseif button == 2 or button == "r" then return 2
    elseif button == 3 or button == "m" then return 3
    else return 1 end
end

-- Public API
function egui.init(width, height)
    if not lib then
        load_library()
    end
    
    width = width or love.graphics.getWidth()
    height = height or love.graphics.getHeight()
    
    local result = lib.egui_love2d_init(width, height)
    initialized = (result == 1)
    
    if initialized then
        print("egui initialized successfully")
    else
        error("Failed to initialize egui")
    end
    
    return initialized
end

function egui.shutdown()
    if lib and initialized then
        lib.egui_love2d_shutdown()
        initialized = false
        print("egui shutdown")
    end
end

function egui.begin_frame(dt)
    if not initialized then return false end
    
    dt = dt or love.timer.getDelta()
    local result = lib.egui_love2d_begin_frame(dt)
    return result == 1
end

function egui.end_frame()
    if not initialized then return false end
    
    local result = lib.egui_love2d_end_frame()
    return result == 1
end

-- Input handling functions
function egui.keypressed(key, scancode, isrepeat)
    if not initialized or isrepeat then return end
    
    local key_str = love_key_to_string(key)
    local result = lib.egui_love2d_handle_key(key_str, 1)
    return result == 1
end

function egui.keyreleased(key, scancode)
    if not initialized then return end
    
    local key_str = love_key_to_string(key)
    local result = lib.egui_love2d_handle_key(key_str, 0)
    return result == 1
end

function egui.textinput(text)
    if not initialized then return end
    
    local result = lib.egui_love2d_handle_text(text)
    return result == 1
end

function egui.mousepressed(x, y, button, istouch, presses)
    if not initialized or istouch then return end
    
    local button_num = love_button_to_number(button)
    local result = lib.egui_love2d_handle_mouse_button(x, y, button_num, 1)
    return result == 1
end

function egui.mousereleased(x, y, button, istouch, presses)
    if not initialized or istouch then return end
    
    local button_num = love_button_to_number(button)
    local result = lib.egui_love2d_handle_mouse_button(x, y, button_num, 0)
    return result == 1
end

function egui.mousemoved(x, y, dx, dy, istouch)
    if not initialized or istouch then return end
    
    local result = lib.egui_love2d_handle_mouse_move(x, y)
    return result == 1
end

function egui.wheelmoved(x, y)
    if not initialized then return end
    
    local result = lib.egui_love2d_handle_wheel(x, y)
    return result == 1
end

-- UI Functions (these interface with the actual egui functionality)
function egui.create_ui()
    -- Create and return a UI instance that can be used to create widgets
    local ui = {}
    
    function ui:button(text, x, y, width, height)
        if not initialized then return false end
        -- This would interface with the Rust egui context
        -- For now, simulate a simple button click detection
        local mx, my = love.mouse.getPosition()
        local clicked = false
        
        if love.mouse.isDown(1) then
            if mx >= x and mx <= x + width and my >= y and my <= y + height then
                clicked = true
            end
        end
        
        return clicked
    end
    
    function ui:text(text, x, y)
        if not initialized then return end
        -- This would interface with the Rust egui context
        -- For now, just store for rendering
    end
    
    return ui
end

function egui.window(title, x, y, width, height, content_func)
    -- Placeholder for window functionality
    -- In a real implementation, this would create an egui window
    if content_func then
        content_func()
    end
end

-- Rendering
function egui.render()
    if not initialized then return end
    
    -- In a real implementation, this would:
    -- 1. Get draw commands from the Rust backend
    -- 2. Execute them using Love2D graphics functions
    -- 3. Handle clipping, textures, etc.
    
    -- For now, just a placeholder
    love.graphics.setColor(1, 0, 0, 0.5)
    love.graphics.rectangle("fill", 10, 10, 200, 100)
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("egui placeholder", 20, 20)
end

-- Utility functions
function egui.is_initialized()
    return initialized
end

function egui.get_screen_size()
    return love.graphics.getWidth(), love.graphics.getHeight()
end

-- Auto-setup for common Love2D callbacks
function egui.setup_callbacks()
    local original_keypressed = love.keypressed
    local original_keyreleased = love.keyreleased
    local original_textinput = love.textinput
    local original_mousepressed = love.mousepressed
    local original_mousereleased = love.mousereleased
    local original_mousemoved = love.mousemoved
    local original_wheelmoved = love.wheelmoved
    
    love.keypressed = function(key, scancode, isrepeat)
        egui.keypressed(key, scancode, isrepeat)
        if original_keypressed then
            original_keypressed(key, scancode, isrepeat)
        end
    end
    
    love.keyreleased = function(key, scancode)
        egui.keyreleased(key, scancode)
        if original_keyreleased then
            original_keyreleased(key, scancode)
        end
    end
    
    love.textinput = function(text)
        egui.textinput(text)
        if original_textinput then
            original_textinput(text)
        end
    end
    
    love.mousepressed = function(x, y, button, istouch, presses)
        egui.mousepressed(x, y, button, istouch, presses)
        if original_mousepressed then
            original_mousepressed(x, y, button, istouch, presses)
        end
    end
    
    love.mousereleased = function(x, y, button, istouch, presses)
        egui.mousereleased(x, y, button, istouch, presses)
        if original_mousereleased then
            original_mousereleased(x, y, button, istouch, presses)
        end
    end
    
    love.mousemoved = function(x, y, dx, dy, istouch)
        egui.mousemoved(x, y, dx, dy, istouch)
        if original_mousemoved then
            original_mousemoved(x, y, dx, dy, istouch)
        end
    end
    
    love.wheelmoved = function(x, y)
        egui.wheelmoved(x, y)
        if original_wheelmoved then
            original_wheelmoved(x, y)
        end
    end
end

return egui