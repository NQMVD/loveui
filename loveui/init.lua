local LoveUI = {
    World = require("loveui.ecs.world"),
    systems = {
        RenderSystem = require("loveui.systems.render"),
        InputSystem = require("loveui.systems.input"),
        LayoutSystem = require("loveui.systems.layout")
    },
    components = {
        Transform = require("loveui.components.transform"),
        Visual = require("loveui.components.visual"),
        Interactive = require("loveui.components.interactive"),
        Layout = require("loveui.components.layout")
    },
    widgets = {
        Button = require("loveui.widgets.button"),
        Container = require("loveui.widgets.container"),
        Slider = require("loveui.widgets.slider"),
        TextInput = require("loveui.widgets.textinput")
    }
}

function LoveUI.createUI()
    local world = LoveUI.World.new()

    -- Add core systems
    world:addSystem(LoveUI.systems.RenderSystem.new())
    world:addSystem(LoveUI.systems.InputSystem.new())
    world:addSystem(LoveUI.systems.LayoutSystem.new())

    return world
end

return LoveUI
