local LayoutSystem = {}
LayoutSystem.__index = LayoutSystem

function LayoutSystem.new()
    return setmetatable({
        name = "LayoutSystem",
        world = nil,
        dirty = true,
        debug = false -- Set to true to see layout debug info
    }, LayoutSystem)
end

function LayoutSystem:init()
    -- Mark layout as dirty on component changes
end

function LayoutSystem:markDirty()
    self.dirty = true
end

-- Get absolute position including all parent transforms
function LayoutSystem:getAbsolutePosition(entityId)
    local transform = self.world:getComponent(entityId, "transform")
    local layout = self.world:getComponent(entityId, "layout")

    if not transform then
        return 0, 0
    end

    -- Start with entity's own position
    local x, y = transform.x, transform.y

    -- Recursively add parent positions if applicable
    if layout and layout.parent then
        local parentX, parentY = self:getAbsolutePosition(layout.parent)
        local parentTransform = self.world:getComponent(layout.parent, "transform")
        local parentLayout = self.world:getComponent(layout.parent, "layout")

        if parentTransform and parentLayout then
            -- Add parent position and padding
            x = parentX + parentLayout.paddingLeft + x
            y = parentY + parentLayout.paddingTop + y
        else
            x = parentX + x
            y = parentY + y
        end
    end

    return x, y
end

-- Apply layout for a single container and its immediate children
function LayoutSystem:applyContainerLayout(containerId)
    local containerTransform = self.world:getComponent(containerId, "transform")
    local containerLayout = self.world:getComponent(containerId, "layout")

    if not containerTransform or not containerLayout then return end

    -- Get absolute position of container
    local containerX, containerY = containerTransform.x, containerTransform.y

    -- Process container's immediate children
    local childX = containerLayout.paddingLeft
    local childY = containerLayout.paddingTop

    -- Calculate total grow and fixed sizes
    local totalGrow = 0
    local fixedSize = 0
    local growingEntities = {}

    -- First pass: determine sizes and total grow
    for _, childId in ipairs(containerLayout.children) do
        local childTransform = self.world:getComponent(childId, "transform")
        local childLayout = self.world:getComponent(childId, "layout")

        if childTransform and childLayout then
            if childLayout.grow > 0 then
                totalGrow = totalGrow + childLayout.grow
                growingEntities[childId] = true
            else
                -- Add up fixed sizes
                if containerLayout.direction == "horizontal" then
                    fixedSize = fixedSize + childTransform.width
                else -- vertical
                    fixedSize = fixedSize + childTransform.height
                end
            end

            -- Add spacing and margins
            if containerLayout.direction == "horizontal" then
                fixedSize = fixedSize + childLayout.marginLeft + childLayout.marginRight
            else -- vertical
                fixedSize = fixedSize + childLayout.marginTop + childLayout.marginBottom
            end
        end
    end

    -- Add spacing between items
    if #containerLayout.children > 1 then
        fixedSize = fixedSize + containerLayout.spacing * (#containerLayout.children - 1)
    end

    -- Calculate available space for growing items
    local availableSpace = 0
    if containerLayout.direction == "horizontal" then
        availableSpace = containerTransform.width - containerLayout.paddingLeft - containerLayout.paddingRight -
        fixedSize
    else -- vertical
        availableSpace = containerTransform.height - containerLayout.paddingTop - containerLayout.paddingBottom -
        fixedSize
    end

    -- Ensure available space is not negative
    availableSpace = math.max(0, availableSpace)

    -- Second pass: position and size children
    for _, childId in ipairs(containerLayout.children) do
        local childTransform = self.world:getComponent(childId, "transform")
        local childLayout = self.world:getComponent(childId, "layout")

        if childTransform and childLayout then
            -- First apply grow if applicable
            if growingEntities[childId] and totalGrow > 0 then
                local growShare = availableSpace * (childLayout.grow / totalGrow)
                if containerLayout.direction == "horizontal" then
                    childTransform.width = growShare
                else -- vertical
                    childTransform.height = growShare
                end
            end

            -- Then position the child
            if containerLayout.direction == "horizontal" then
                -- Add left margin and set position
                childX = childX + childLayout.marginLeft
                childTransform.x = childX
                childTransform.y = childY + childLayout.marginTop

                -- Move position for next child
                childX = childX + childTransform.width + childLayout.marginRight + containerLayout.spacing
            else -- vertical
                -- Add top margin and set position
                childY = childY + childLayout.marginTop
                childTransform.x = childX + childLayout.marginLeft
                childTransform.y = childY

                -- Move position for next child
                childY = childY + childTransform.height + childLayout.marginBottom + containerLayout.spacing
            end

            -- Recursively apply layout for this child if it's a container
            self:applyContainerLayout(childId)
        end
    end
end

-- Convert local coordinates to absolute coordinates
function LayoutSystem:convertToAbsoluteCoordinates(rootEntities)
    local function processEntity(entityId, parentX, parentY)
        local transform = self.world:getComponent(entityId, "transform")
        local layout = self.world:getComponent(entityId, "layout")

        if not transform then return end

        -- Store original relative x,y for debugging
        local originalX, originalY = transform.x, transform.y

        -- Convert to absolute coordinates
        transform.x = transform.x + parentX
        transform.y = transform.y + parentY

        if self.debug then
            print(string.format("Entity %d: (%d,%d) -> (%d,%d)",
                entityId, originalX, originalY, transform.x, transform.y))
        end

        -- Process children
        if layout then
            for _, childId in ipairs(layout.children) do
                local childLayout = self.world:getComponent(childId, "layout")
                if childLayout then
                    local childParentX = transform.x
                    local childParentY = transform.y

                    -- Add padding if applicable
                    if layout then
                        childParentX = childParentX + layout.paddingLeft
                        childParentY = childParentY + layout.paddingTop
                    end

                    processEntity(childId, childParentX, childParentY)
                end
            end
        end
    end

    for _, entityId in ipairs(rootEntities) do
        processEntity(entityId, 0, 0)
    end
end

function LayoutSystem:update(dt)
    if not self.dirty then return end

    -- Reset transforms to container-relative positions first
    -- This ensures we're not compounding absolute positions
    self:resetPositionsToRelative()

    -- Find root entities (those without parents)
    local rootEntities = {}
    for entityId, _ in pairs(self.world.entities) do
        local layout = self.world:getComponent(entityId, "layout")
        local transform = self.world:getComponent(entityId, "transform")

        if transform and (not layout or not layout.parent) then
            table.insert(rootEntities, entityId)
        end
    end

    -- Apply layouts to all containers
    for _, rootId in ipairs(rootEntities) do
        self:applyContainerLayout(rootId)
    end

    -- Convert all positions to absolute coordinates
    self:convertToAbsoluteCoordinates(rootEntities)

    if self.debug then
        print("---Layout updated---")
    end

    self.dirty = false
end

-- Reset all entities to container-relative positions
function LayoutSystem:resetPositionsToRelative()
    -- Store original positions
    local originalPositions = {}

    for entityId, _ in pairs(self.world.entities) do
        local transform = self.world:getComponent(entityId, "transform")
        if transform then
            originalPositions[entityId] = { x = transform.x, y = transform.y }
        end
    end

    -- Reset positions to be relative to parent
    for entityId, _ in pairs(self.world.entities) do
        local transform = self.world:getComponent(entityId, "transform")
        local layout = self.world:getComponent(entityId, "layout")

        if transform and layout and layout.parent then
            -- Calculate position as offset from parent's absolute position
            local parentPos = originalPositions[layout.parent]
            local parentLayout = self.world:getComponent(layout.parent, "layout")

            if parentPos and parentLayout then
                -- Reset to be container-relative
                transform.x = transform.x - parentPos.x - parentLayout.paddingLeft
                transform.y = transform.y - parentPos.y - parentLayout.paddingTop
            end
        end
    end
end

return LayoutSystem
