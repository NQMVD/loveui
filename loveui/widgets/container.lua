local Container = {}

-- Create a new container widget
-- default params:
-- x = 0,
-- y = 0,
-- width = 300,
-- height = 200,
-- backgroundColor = { 0.15, 0.15, 0.15, 1 },
-- borderColor = { 0.25, 0.25, 0.25, 1 },
-- borderWidth = 1,
-- cornerRadius = 10,
-- shadow = true,
-- parent = nil,
-- paddingLeft = 10,
-- paddingRight = 10,
-- paddingTop = 10,
-- paddingBottom = 10,
-- marginLeft = 0,
-- marginRight = 0,
-- marginTop = 0,
-- marginBottom = 0,
-- direction = "vertical",
-- spacing = 10,
-- grow = 0
function Container.new(world, params)
    params = params or {}

    local entityId = world:createEntity()

    -- Add components
    world:addComponent(entityId, "transform", require("loveui.components.transform").new(
        params.x or 0,
        params.y or 0,
        params.width or 300,
        params.height or 200
    ))

    world:addComponent(entityId, "visual", require("loveui.components.visual").new({
        type = "roundedrect",
        backgroundColor = params.backgroundColor or { 0.15, 0.15, 0.15, 1 },
        borderColor = params.borderColor or { 0.25, 0.25, 0.25, 1 },
        borderWidth = params.borderWidth or 1,
        cornerRadius = params.cornerRadius or 10,
        shadow = {
            enabled = params.shadow == nil and true or params.shadow,
            offsetX = 0,
            offsetY = 3,
            blur = 10,
            color = { 0, 0, 0, 0.2 }
        }
    }))

    world:addComponent(entityId, "layout", require("loveui.components.layout").new({
        parent = params.parent,
        paddingLeft = params.paddingLeft or 10,
        paddingRight = params.paddingRight or 10,
        paddingTop = params.paddingTop or 10,
        paddingBottom = params.paddingBottom or 10,
        marginLeft = params.marginLeft or 0,
        marginRight = params.marginRight or 0,
        marginTop = params.marginTop or 0,
        marginBottom = params.marginBottom or 0,
        direction = params.direction or "vertical",
        spacing = params.spacing or 10,
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

return Container
