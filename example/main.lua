-- main.lua - Example Love2D application using the egui bridge
local egui = require("love2d-egui.egui")

function love.load()
    print("Starting Love2D with egui integration")
    
    -- Initialize egui with screen dimensions
    local width, height = love.graphics.getDimensions()
    egui.init(width, height)
    
    -- Setup automatic input handling
    egui.setup_callbacks()
    
    print("egui integration ready!")
end

function love.update(dt)
    -- Begin the egui frame
    egui.begin_frame(dt)
    
    -- Here you would typically build your UI
    -- For example:
    -- if egui.button("Click me!", 100, 100, 120, 30) then
    --     print("Button clicked!")
    -- end
    
    -- egui.text("Hello from egui!", 100, 150)
    
    -- End the egui frame
    egui.end_frame()
end

function love.draw()
    -- Draw your game/application content first
    love.graphics.setBackgroundColor(0.1, 0.1, 0.2, 1.0)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Love2D + egui Integration Demo", 10, 10)
    love.graphics.print("This is a basic example showing the bridge between Love2D and egui", 10, 30)
    love.graphics.print("The red rectangle below is a placeholder for egui UI elements", 10, 50)
    
    -- Render the egui UI on top
    egui.render()
    
    -- Additional instructions
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.print("Press Escape to quit", 10, love.graphics.getHeight() - 25)
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function love.quit()
    print("Shutting down egui")
    egui.shutdown()
end

-- Window resize handling
function love.resize(w, h)
    if egui.is_initialized() then
        -- Reinitialize egui with new dimensions
        egui.shutdown()
        egui.init(w, h)
        egui.setup_callbacks()
    end
end