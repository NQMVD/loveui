-- main.lua - Example Love2D application using the egui bridge
local egui = require("love2d-egui.egui")

local button_clicked = false
local click_count = 0

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
    
    -- Create a UI instance
    local ui = egui.create_ui()
    
    -- Example button usage
    if ui:button("Click me!", 100, 100, 120, 30) then
        button_clicked = true
        click_count = click_count + 1
        print("Button clicked! Count: " .. click_count)
    end
    
    -- Example text
    ui:text("Hello from egui!", 100, 150)
    ui:text("Clicked " .. click_count .. " times", 100, 180)
    
    -- End the egui frame
    egui.end_frame()
end

function love.draw()
    -- Draw your game/application content first
    love.graphics.setBackgroundColor(0.1, 0.1, 0.2, 1.0)
    
    love.graphics.setColor(1, 1, 1, 1)
    love.graphics.print("Love2D + egui Integration Demo", 10, 10)
    love.graphics.print("This example demonstrates the bridge between Love2D and egui", 10, 30)
    
    if button_clicked then
        love.graphics.setColor(0, 1, 0, 1)
        love.graphics.print("Button was clicked!", 10, 50)
    end
    
    -- Render the egui UI on top
    egui.render()
    
    -- Additional instructions
    love.graphics.setColor(1, 1, 1, 0.8)
    love.graphics.print("Press Escape to quit", 10, love.graphics.getHeight() - 25)
    love.graphics.print("Click the egui button above to test interaction", 10, love.graphics.getHeight() - 45)
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