local RenderSystem = {}
RenderSystem.__index = RenderSystem

function love.graphics.squircle(mode, x, y, w, h, n)
    local angle_res = 0.01
    local vertices = {}
    -- Adjust n based on width and height to make corners more consistent across different sizes
    local adjusted_n = (n - 1) * (math.min(w, h) / math.max(w, h)) * 5

    for angle = 0, math.pi * 2, angle_res do
        local sx = (math.abs(math.cos(angle)) ^ (2 / adjusted_n) * (math.cos(angle) < 0 and -1 or 1))
        local sy = (math.abs(math.sin(angle)) ^ (2 / adjusted_n) * (math.sin(angle) < 0 and -1 or 1))
        sx = sx * (w / 2)
        sy = sy * (h / 2)
        table.insert(vertices, sx)
        table.insert(vertices, sy)
    end
    love.graphics.translate(x + w / 2, y + h / 2)
    love.graphics.polygon(mode, vertices)
    love.graphics.translate(-(x + (w / 2)), -(y + (h / 2)))
end

function RenderSystem.new()
    return setmetatable({
        name = "RenderSystem",
        world = nil,
        drawOrder = {} -- Entities sorted by depth
    }, RenderSystem)
end

function RenderSystem:calculateDrawOrder()
    self.drawOrder = {}

    for entityId, _ in pairs(self.world.entities) do
        local transform = self.world:getComponent(entityId, "transform")
        local visual = self.world:getComponent(entityId, "visual")

        if transform and visual and transform.visible then
            table.insert(self.drawOrder, entityId)
        end
    end

    -- Sort by parent-child relationship
    table.sort(self.drawOrder, function(a, b)
        local layoutA = self.world:getComponent(a, "layout")
        local layoutB = self.world:getComponent(b, "layout")

        if layoutA and layoutB then
            if layoutA.parent == b then return false end
            if layoutB.parent == a then return true end
        end

        return a < b
    end)
end

function RenderSystem:drawEntity(entityId)
    local transform = self.world:getComponent(entityId, "transform")
    local visual = self.world:getComponent(entityId, "visual")
    local interactive = self.world:getComponent(entityId, "interactive")

    if not transform or not visual or not transform.visible then return end

    -- Set opacity
    love.graphics.setColor(1, 1, 1, visual.opacity)

    -- Save current state
    love.graphics.push()
    love.graphics.translate(transform.x, transform.y)

    -- Determine colors based on interaction state
    local bgColor = { unpack(visual.backgroundColor) }
    local borderColor = { unpack(visual.borderColor) }

    if interactive and interactive.hovered then
        -- Lighten colors when hovered
        for i = 1, 3 do
            bgColor[i] = bgColor[i] * 1.1
            borderColor[i] = borderColor[i] * 1.2
        end
    end

    if interactive and interactive.pressed then
        -- Darken colors when pressed
        for i = 1, 3 do
            bgColor[i] = bgColor[i] * 0.9
            borderColor[i] = borderColor[i] * 0.8
        end
    end

    -- Draw shadow if enabled
    if visual.shadow and visual.shadow.enabled then
        love.graphics.setColor(visual.shadow.color)
        if visual.type == "rectangle" or visual.type == "roundedrect" then
            love.graphics.rectangle(
                "fill",
                visual.shadow.offsetX,
                visual.shadow.offsetY,
                transform.width,
                transform.height,
                visual.type == "roundedrect" and visual.cornerRadius or 0
            )
        end
    end

    -- Draw background
    love.graphics.setColor(bgColor)
    if visual.type == "rectangle" then
        love.graphics.rectangle("fill", 0, 0, transform.width, transform.height)
    elseif visual.type == "squircle" then
        love.graphics.squircle("fill", 0, 0, transform.width, transform.height, visual.cornerRadius)
    elseif visual.type == "roundedrect" then
        love.graphics.rectangle("fill", 0, 0, transform.width, transform.height, visual.cornerRadius)
    elseif visual.type == "image" and visual.image then
        love.graphics.draw(visual.image, 0, 0, 0, transform.width / visual.image:getWidth(),
            transform.height / visual.image:getHeight())
    end

    -- Draw border
    if visual.borderWidth > 0 then
        love.graphics.setColor(borderColor)
        love.graphics.setLineWidth(visual.borderWidth)
        if visual.type == "rectangle" then
            love.graphics.rectangle("line", 0, 0, transform.width, transform.height)
        elseif visual.type == "squircle" then
            love.graphics.squircle("line", 0, 0, transform.width, transform.height, visual.cornerRadius)
        elseif visual.type == "roundedrect" then
            love.graphics.rectangle("line", 0, 0, transform.width, transform.height, visual.cornerRadius)
        end
    end

    -- Draw text
    if visual.text and visual.text ~= "" then
        love.graphics.setColor(visual.textColor)
        love.graphics.setFont(visual.font)

        local textWidth = visual.font:getWidth(visual.text)
        local textHeight = visual.font:getHeight()
        local textX = 0

        -- Determine text position based on alignment
        if visual.textAlign == "left" then
            textX = 10                               -- Left padding
        elseif visual.textAlign == "right" then
            textX = transform.width - textWidth - 10 -- Right padding
        else                                         -- center
            textX = (transform.width - textWidth) / 2
        end

        local textY = (transform.height - textHeight) / 2

        love.graphics.print(visual.text, textX, textY)
    end

    love.graphics.pop()
end

function RenderSystem:update(dt)
    self:calculateDrawOrder()
end

function RenderSystem:draw()
    for _, entityId in ipairs(self.drawOrder) do
        self:drawEntity(entityId)
    end
end

return RenderSystem
