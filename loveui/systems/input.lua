local InputSystem = {}
InputSystem.__index = InputSystem

function InputSystem.new()
    return setmetatable({
        name = "InputSystem",
        world = nil,
        hoveredEntities = {},
        pressedEntities = {},
        focusedEntity = nil,
        draggedEntity = nil,
        dragStartX = 0,
        dragStartY = 0
    }, InputSystem)
end

function InputSystem:init()
    -- Register LÖVE callbacks
    local oldMousePressed = love.mousepressed or function() end
    love.mousepressed = function(x, y, button, ...)
        self:onMousePressed(x, y, button)
        return oldMousePressed(x, y, button, ...)
    end

    local oldMouseReleased = love.mousereleased or function() end
    love.mousereleased = function(x, y, button, ...)
        self:onMouseReleased(x, y, button)
        return oldMouseReleased(x, y, button, ...)
    end

    local oldMouseMoved = love.mousemoved or function() end
    love.mousemoved = function(x, y, dx, dy, ...)
        self:onMouseMoved(x, y, dx, dy)
        return oldMouseMoved(x, y, dx, dy, ...)
    end
end

function InputSystem:isPointInEntity(x, y, entityId)
    local transform = self.world:getComponent(entityId, "transform")
    if not transform or not transform.visible then return false end

    -- We're using absolute coordinates now, so this check is simpler
    return x >= transform.x and
        x <= transform.x + transform.width and
        y >= transform.y and
        y <= transform.y + transform.height
end

function InputSystem:onMousePressed(x, y, button)
    if button ~= 1 then return end

    -- Find entity under cursor
    local targetEntity = nil
    for entityId, _ in pairs(self.world.entities) do
        local interactive = self.world:getComponent(entityId, "interactive")
        if interactive and interactive.enabled and self:isPointInEntity(x, y, entityId) then
            targetEntity = entityId
            break
        end
    end

    if targetEntity then
        local interactive = self.world:getComponent(targetEntity, "interactive")
        interactive.pressed = true
        self.pressedEntities[targetEntity] = true

        -- Start drag if draggable
        if interactive.draggable then
            self.draggedEntity = targetEntity
            local transform = self.world:getComponent(targetEntity, "transform")
            self.dragStartX = x - transform.x
            self.dragStartY = y - transform.y
        end

        -- Set focus
        if self.focusedEntity ~= targetEntity then
            if self.focusedEntity then
                local prevFocused = self.world:getComponent(self.focusedEntity, "interactive")
                if prevFocused then prevFocused.focused = false end
            end
            self.focusedEntity = targetEntity
            interactive.focused = true
        end

        -- Call press callback
        if interactive.onPress then
            interactive.onPress(targetEntity, x, y)
        end
    end
end

function InputSystem:onMouseReleased(x, y, button)
    if button ~= 1 then return end

    -- Handle clicks and end drags
    for entityId, _ in pairs(self.pressedEntities) do
        local interactive = self.world:getComponent(entityId, "interactive")
        if interactive then
            interactive.pressed = false

            -- Handle click
            if self:isPointInEntity(x, y, entityId) and interactive.onClick then
                interactive.onClick(entityId, x, y)
            end

            -- Call release callback
            if interactive.onRelease then
                interactive.onRelease(entityId, x, y)
            end
        end
    end

    self.pressedEntities = {}
    self.draggedEntity = nil
end

function InputSystem:onMouseMoved(x, y, dx, dy)
    -- Handle drag
    if self.draggedEntity then
        local transform = self.world:getComponent(self.draggedEntity, "transform")
        local interactive = self.world:getComponent(self.draggedEntity, "interactive")

        if transform and interactive and interactive.draggable then
            transform.x = x - self.dragStartX
            transform.y = y - self.dragStartY

            if interactive.onDrag then
                interactive.onDrag(self.draggedEntity, x, y, dx, dy)
            end
        end
    end

    -- Update hover states
    local newHoveredEntities = {}
    for entityId, _ in pairs(self.world.entities) do
        local interactive = self.world:getComponent(entityId, "interactive")
        if interactive and interactive.hoverable and interactive.enabled then
            local isHovered = self:isPointInEntity(x, y, entityId)

            -- Enter hover
            if isHovered and not self.hoveredEntities[entityId] then
                interactive.hovered = true
                if interactive.onHover then
                    interactive.onHover(entityId, x, y)
                end
                -- Leave hover
            elseif not isHovered and self.hoveredEntities[entityId] then
                interactive.hovered = false
                if interactive.onLeave then
                    interactive.onLeave(entityId, x, y)
                end
            end

            if isHovered then
                newHoveredEntities[entityId] = true
            end
        end
    end

    self.hoveredEntities = newHoveredEntities
end

function InputSystem:update(dt)
    -- System logic here if needed
end

return InputSystem
