local Slider = {}


-- Helper function to calculate initial handle position
function calculateHandlePosition(sliderTransform, handleWidth, min, max, value)
    local percentage = (value - min) / (max - min)
    local maxX = sliderTransform.width - handleWidth
    return percentage * maxX
end

function Slider.new(world, params)
    params = params or {}

    local entityId = world:createEntity()

    -- Add components
    local transform = world:addComponent(entityId, "transform", require("loveui.components.transform").new(
        params.x or 0,
        params.y or 0,
        params.width or 200,
        params.height or 24
    ))

    world:addComponent(entityId, "visual", require("loveui.components.visual").new({
        type = "roundedrect",
        backgroundColor = params.backgroundColor or { 0.2, 0.2, 0.2, 1 },
        borderColor = params.borderColor or { 0.3, 0.3, 0.3, 1 },
        borderWidth = params.borderWidth or 1,
        cornerRadius = params.cornerRadius or 8
    }))

    -- Values for the slider
    local min = params.min or 0
    local max = params.max or 100
    local value = params.value or min

    -- Create handle (the draggable part)
    local handleId = world:createEntity()
    local handleSize = params.handleSize or transform.height * 1.2
    local handlePosition = calculateHandlePosition(transform, handleSize, min, max, value)

    world:addComponent(handleId, "transform", require("loveui.components.transform").new(
        handlePosition,
        (transform.height - handleSize) / 2,
        handleSize,
        handleSize
    ))

    world:addComponent(handleId, "visual", require("loveui.components.visual").new({
        type = "roundedrect",
        backgroundColor = params.handleColor or { 0.4, 0.4, 0.8, 1 },
        borderColor = params.handleBorderColor or { 0.5, 0.5, 0.9, 1 },
        borderWidth = params.handleBorderWidth or 2,
        cornerRadius = params.handleCornerRadius or handleSize / 2,
        shadow = {
            enabled = true,
            offsetX = 0,
            offsetY = 1,
            blur = 3,
            color = { 0, 0, 0, 0.3 }
        }
    }))

    -- The handle is draggable
    world:addComponent(handleId, "interactive", require("loveui.components.interactive").new({
        draggable = true,
        hoverable = true,
        onDrag = function(_, x, y, dx, dy)
            local handleTransform = world:getComponent(handleId, "transform")
            local sliderTransform = world:getComponent(entityId, "transform")

            -- Constrain handle position to slider bounds
            local minX = 0
            local maxX = sliderTransform.width - handleTransform.width

            handleTransform.x = math.max(minX, math.min(maxX, handleTransform.x + dx))

            -- Calculate new value based on position
            local percentage = handleTransform.x / maxX
            local newValue = min + percentage * (max - min)
            value = newValue

            -- Call onChange callback
            if params.onChange then
                params.onChange(value)
            end
        end,
        enabled = params.enabled ~= false
    }))

    world:addComponent(handleId, "layout", require("loveui.components.layout").new({
        parent = entityId
    }))

    -- Add layout to main entity
    local layout = world:addComponent(entityId, "layout", require("loveui.components.layout").new({
        parent = params.parent,
        marginLeft = params.marginLeft or 0,
        marginRight = params.marginRight or 0,
        marginTop = params.marginTop or 0,
        marginBottom = params.marginBottom or 0,
        grow = params.grow or 0
    }))

    -- Add handle to layout's children
    table.insert(layout.children, handleId)

    -- Add to parent if specified
    if params.parent then
        local parentLayout = world:getComponent(params.parent, "layout")
        if parentLayout then
            table.insert(parentLayout.children, entityId)
        end
    end

    -- Methods for the slider
    local slider = {
        entityId = entityId,
        handleId = handleId,

        getValue = function()
            return value
        end,

        setValue = function(newValue)
            -- Clamp value to range
            value = math.max(min, math.min(max, newValue))

            -- Update handle position
            local handleTransform = world:getComponent(handleId, "transform")
            local sliderTransform = world:getComponent(entityId, "transform")

            local percentage = (value - min) / (max - min)
            local maxX = sliderTransform.width - handleTransform.width
            handleTransform.x = percentage * maxX

            -- Call onChange callback
            if params.onChange then
                params.onChange(value)
            end

            return value
        end
    }

    -- Helper function to calculate initial handle position
    function calculateHandlePosition(sliderTransform, handleWidth, min, max, value)
        local percentage = (value - min) / (max - min)
        local maxX = sliderTransform.width - handleWidth
        return percentage * maxX
    end

    return entityId, slider
end

return Slider
