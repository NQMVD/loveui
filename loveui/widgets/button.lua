local Button = {}

-- Button widget
-- default params:
-- x = 0,
-- y = 0,
-- width = 180,
-- height = 40,
-- backgroundColor = { 0.2, 0.4, 0.8, 1 },
-- borderColor = { 0.3, 0.5, 0.9, 1 },
-- borderWidth = 2,
-- cornerRadius = 8,
-- text = "Button",
-- textColor = { 1, 1, 1, 1 },
-- font = love.graphics.getFont(),
-- shadow = true
-- parent = nil,
-- marginLeft = 0,
-- marginRight = 0,
-- marginTop = 0,
-- marginBottom = 0,
-- grow = 0
-- onClick = nil,
-- onHover = nil,
-- onLeave = nil,
-- onPress = nil,
-- onRelease = nil,
-- enabled = true
function Button.new(world, params)
    params = params or {}

    local entityId = world:createEntity()

    -- Add components
    world:addComponent(entityId, "transform", require("loveui.components.transform").new(
        params.x or 0,
        params.y or 0,
        params.width or 180,
        params.height or 40
    ))

    world:addComponent(entityId, "visual", require("loveui.components.visual").new({
        type = "roundedrect",
        backgroundColor = params.backgroundColor or { 0.2, 0.4, 0.8, 1 },
        borderColor = params.borderColor or { 0.3, 0.5, 0.9, 1 }, -- make this just brighter
        borderWidth = params.borderWidth or 1.5,
        cornerRadius = params.cornerRadius or 8,
        text = params.text or "Button",
        textColor = params.textColor or { 1, 1, 1, 1 },
        font = params.font or love.graphics.getFont(),
        shadow = {
            enabled = true,
            offsetX = 0,
            offsetY = 2,
            blur = 5,
            color = { 0, 0, 0, 0.3 }
        }
    }))

    world:addComponent(entityId, "interactive", require("loveui.components.interactive").new({
        clickable = true,
        hoverable = true,
        onClick = params.onClick,
        onHover = params.onHover,
        onLeave = params.onLeave,
        onPress = params.onPress,
        onRelease = params.onRelease,
        enabled = params.enabled
    }))

    world:addComponent(entityId, "layout", require("loveui.components.layout").new({
        parent = params.parent,
        marginLeft = params.marginLeft or 0,
        marginRight = params.marginRight or 0,
        marginTop = params.marginTop or 0,
        marginBottom = params.marginBottom or 0,
        grow = params.grow or 0
    }))

    if params.parent then
        local parentLayout = world:getComponent(params.parent, "layout")
        if parentLayout then
            table.insert(parentLayout.children, entityId)
        end
    end

    return entityId
end

return Button
