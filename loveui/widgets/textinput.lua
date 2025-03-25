local TextInput = {}

function TextInput.new(world, params)
    params = params or {}

    local entityId = world:createEntity()

    -- Initialize text state
    local text = params.text or ""
    local cursorPosition = #text
    local cursorVisible = true
    local cursorBlinkTime = 0
    local cursorBlinkRate = 0.5 -- seconds
    local focused = false
    local selectionStart = nil
    local textPadding = params.textPadding or 10 -- Padding for text from left edge

    -- Add components
    world:addComponent(entityId, "transform", require("loveui.components.transform").new(
        params.x or 0,
        params.y or 0,
        params.width or 200,
        params.height or 40
    ))

    world:addComponent(entityId, "visual", require("loveui.components.visual").new({
        type = "roundedrect",
        backgroundColor = params.backgroundColor or { 0.2, 0.2, 0.2, 1 },
        borderColor = params.borderColor or { 0.3, 0.3, 0.3, 1 },
        borderWidth = params.borderWidth or 2,
        cornerRadius = params.cornerRadius or 8,
        text = text,
        textColor = params.textColor or { 0.9, 0.9, 0.9, 1 },
        font = params.font or love.graphics.getFont(),
        textAlign = "left" -- Explicitly set left alignment
    }))

    local interactive = world:addComponent(entityId, "interactive", require("loveui.components.interactive").new({
        clickable = true,
        hoverable = true,
        onClick = function(id, x, y)
            focused = true
            cursorVisible = true
            cursorBlinkTime = 0

            -- Find cursor position from click
            local visual = world:getComponent(id, "visual")
            local transform = world:getComponent(id, "transform")

            if not visual or not transform then return end

            local font = visual.font
            local relativeX = x - transform.x - textPadding

            -- Position cursor based on click position
            local clickedPosition = 0
            local textToCheck = text

            -- Find closest character position
            while clickedPosition <= #textToCheck do
                local subText = string.sub(textToCheck, 1, clickedPosition)
                local textWidth = font:getWidth(subText)

                if textWidth > relativeX then
                    break
                end

                clickedPosition = clickedPosition + 1
            end

            cursorPosition = math.max(0, clickedPosition - 1)
            selectionStart = nil

            -- Set up keyboard input
            love.keyboard.setKeyRepeat(true)
        end,
        onHover = params.onHover,
        onLeave = params.onLeave,
        enabled = params.enabled ~= false
    }))

    world:addComponent(entityId, "layout", require("loveui.components.layout").new({
        parent = params.parent,
        marginLeft = params.marginLeft or 0,
        marginRight = params.marginRight or 0,
        marginTop = params.marginTop or 0,
        marginBottom = params.marginBottom or 0,
        grow = params.grow or 0
    }))

    -- Add to parent if specified
    if params.parent then
        local parentLayout = world:getComponent(params.parent, "layout")
        if parentLayout then
            table.insert(parentLayout.children, entityId)
        end
    end

    -- Override draw to handle cursor and selection
    local renderSystem = nil
    for _, system in ipairs(world.systems) do
        if system.name == "RenderSystem" then
            renderSystem = system
            break
        end
    end

    if renderSystem then
        local originalDrawEntity = renderSystem.drawEntity
        renderSystem.drawEntity = function(self, id)
            if id ~= entityId then
                return originalDrawEntity(self, id)
            end

            -- Call original drawing first but modify it for text input
            local transform = world:getComponent(id, "transform")
            local visual = world:getComponent(id, "visual")
            local interactive = world:getComponent(id, "interactive")

            if not transform or not visual or not transform.visible then
                return
            end

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
                love.graphics.rectangle(
                    "fill",
                    visual.shadow.offsetX,
                    visual.shadow.offsetY,
                    transform.width,
                    transform.height,
                    visual.cornerRadius
                )
            end

            -- Draw background
            love.graphics.setColor(bgColor)
            love.graphics.rectangle("fill", 0, 0, transform.width, transform.height, visual.cornerRadius)

            -- Draw border
            if visual.borderWidth > 0 then
                love.graphics.setColor(borderColor)
                love.graphics.setLineWidth(visual.borderWidth)
                love.graphics.rectangle("line", 0, 0, transform.width, transform.height, visual.cornerRadius)
            end

            -- Draw selection if applicable (draw BEFORE text)
            if selectionStart and selectionStart ~= cursorPosition then
                local font = visual.font
                local startPos = math.min(selectionStart, cursorPosition)
                local endPos = math.max(selectionStart, cursorPosition)
                local selectedText = string.sub(text, 1, startPos)
                local selStartX = textPadding + font:getWidth(selectedText)
                local selWidth = font:getWidth(string.sub(text, startPos + 1, endPos))
                local cursorY = (transform.height - font:getHeight()) / 2

                love.graphics.setColor(0.3, 0.5, 0.9, 0.5)
                love.graphics.rectangle("fill", selStartX, cursorY, selWidth, font:getHeight())
            end

            -- Draw text (left-aligned)
            if visual.text and visual.text ~= "" then
                love.graphics.setColor(visual.textColor)
                love.graphics.setFont(visual.font)

                local textY = (transform.height - visual.font:getHeight()) / 2
                love.graphics.print(visual.text, textPadding, textY)
            end

            -- Draw cursor if focused
            if focused and cursorVisible then
                local font = visual.font
                local textBeforeCursor = string.sub(text, 1, cursorPosition)
                local cursorX = textPadding + font:getWidth(textBeforeCursor)
                local cursorY = (transform.height - font:getHeight()) / 2

                love.graphics.setColor(0.9, 0.9, 0.9, 1)
                love.graphics.setLineWidth(2)
                love.graphics.line(cursorX, cursorY, cursorX, cursorY + font:getHeight())
            end

            love.graphics.pop()
        end
    end

    -- Rest of the code (keyboard handling) remains the same
    -- Keyboard event handlers
    local oldTextInput = love.textinput or function() end
    love.textinput = function(t)
        if focused then
            -- Delete selected text if there's a selection
            if selectionStart and selectionStart ~= cursorPosition then
                local startPos = math.min(selectionStart, cursorPosition)
                local endPos = math.max(selectionStart, cursorPosition)

                text = string.sub(text, 1, startPos) .. string.sub(text, endPos + 1)
                cursorPosition = startPos
                selectionStart = nil
            end

            -- Insert text at cursor position
            text = string.sub(text, 1, cursorPosition) .. t .. string.sub(text, cursorPosition + 1)
            cursorPosition = cursorPosition + #t
            cursorVisible = true
            cursorBlinkTime = 0

            -- Update the visual component
            local visual = world:getComponent(entityId, "visual")
            if visual then
                visual.text = text

                -- Call onChange callback if provided
                if params.onChange then
                    params.onChange(text)
                end
            end
        end

        return oldTextInput(t)
    end

    -- Same keyboard handler code as before
    local oldKeyPressed = love.keypressed or function() end
    love.keypressed = function(key, scancode, isrepeat)
        if focused then
            -- Handle text manipulation keys
            if key == "backspace" then
                if selectionStart and selectionStart ~= cursorPosition then
                    -- Delete selection
                    local startPos = math.min(selectionStart, cursorPosition)
                    local endPos = math.max(selectionStart, cursorPosition)

                    text = string.sub(text, 1, startPos) .. string.sub(text, endPos + 1)
                    cursorPosition = startPos
                    selectionStart = nil
                else
                    -- Delete character before cursor
                    if cursorPosition > 0 then
                        text = string.sub(text, 1, cursorPosition - 1) .. string.sub(text, cursorPosition + 1)
                        cursorPosition = cursorPosition - 1
                    end
                end

                cursorVisible = true
                cursorBlinkTime = 0

                -- Update the visual component
                local visual = world:getComponent(entityId, "visual")
                if visual then
                    visual.text = text

                    -- Call onChange callback if provided
                    if params.onChange then
                        params.onChange(text)
                    end
                end
            elseif key == "delete" then
                if selectionStart and selectionStart ~= cursorPosition then
                    -- Delete selection
                    local startPos = math.min(selectionStart, cursorPosition)
                    local endPos = math.max(selectionStart, cursorPosition)

                    text = string.sub(text, 1, startPos) .. string.sub(text, endPos + 1)
                    cursorPosition = startPos
                    selectionStart = nil
                else
                    -- Delete character after cursor
                    if cursorPosition < #text then
                        text = string.sub(text, 1, cursorPosition) .. string.sub(text, cursorPosition + 2)
                    end
                end

                cursorVisible = true
                cursorBlinkTime = 0

                -- Update the visual component
                local visual = world:getComponent(entityId, "visual")
                if visual then
                    visual.text = text

                    -- Call onChange callback if provided
                    if params.onChange then
                        params.onChange(text)
                    end
                end
            elseif key == "left" then
                -- Move cursor left
                if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
                    -- Start selection if not already selecting
                    if selectionStart == nil then
                        selectionStart = cursorPosition
                    end
                else
                    selectionStart = nil
                end

                cursorPosition = math.max(0, cursorPosition - 1)
                cursorVisible = true
                cursorBlinkTime = 0
            elseif key == "right" then
                -- Move cursor right
                if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
                    -- Start selection if not already selecting
                    if selectionStart == nil then
                        selectionStart = cursorPosition
                    end
                else
                    selectionStart = nil
                end

                cursorPosition = math.min(#text, cursorPosition + 1)
                cursorVisible = true
                cursorBlinkTime = 0
            elseif key == "home" then
                -- Move cursor to start
                if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
                    if selectionStart == nil then
                        selectionStart = cursorPosition
                    end
                else
                    selectionStart = nil
                end

                cursorPosition = 0
                cursorVisible = true
                cursorBlinkTime = 0
            elseif key == "end" then
                -- Move cursor to end
                if love.keyboard.isDown("lshift") or love.keyboard.isDown("rshift") then
                    if selectionStart == nil then
                        selectionStart = cursorPosition
                    end
                else
                    selectionStart = nil
                end

                cursorPosition = #text
                cursorVisible = true
                cursorBlinkTime = 0
            elseif key == "return" or key == "escape" then
                -- Lose focus
                focused = false
                selectionStart = nil

                -- Call onSubmit callback if provided
                if key == "return" and params.onSubmit then
                    params.onSubmit(text)
                end
            elseif key == "v" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
                -- Paste text
                local clipboard = love.system.getClipboardText()

                -- Delete selected text if there's a selection
                if selectionStart and selectionStart ~= cursorPosition then
                    local startPos = math.min(selectionStart, cursorPosition)
                    local endPos = math.max(selectionStart, cursorPosition)

                    text = string.sub(text, 1, startPos) .. string.sub(text, endPos + 1)
                    cursorPosition = startPos
                    selectionStart = nil
                end

                -- Insert clipboard text
                text = string.sub(text, 1, cursorPosition) .. clipboard .. string.sub(text, cursorPosition + 1)
                cursorPosition = cursorPosition + #clipboard

                -- Update the visual component
                local visual = world:getComponent(entityId, "visual")
                if visual then
                    visual.text = text

                    -- Call onChange callback if provided
                    if params.onChange then
                        params.onChange(text)
                    end
                end
            elseif key == "c" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
                -- Copy selected text
                if selectionStart and selectionStart ~= cursorPosition then
                    local startPos = math.min(selectionStart, cursorPosition)
                    local endPos = math.max(selectionStart, cursorPosition)
                    local selectedText = string.sub(text, startPos + 1, endPos)

                    love.system.setClipboardText(selectedText)
                end
            elseif key == "a" and (love.keyboard.isDown("lctrl") or love.keyboard.isDown("rctrl")) then
                -- Select all text
                selectionStart = 0
                cursorPosition = #text
            end
        end

        return oldKeyPressed(key, scancode, isrepeat)
    end

    -- Add update handler for cursor blinking
    local inputSystem = nil
    for _, system in ipairs(world.systems) do
        if system.name == "InputSystem" then
            inputSystem = system
            break
        end
    end

    if inputSystem then
        local originalUpdate = inputSystem.update
        inputSystem.update = function(self, dt)
            originalUpdate(self, dt)

            -- Update cursor blinking
            if focused then
                cursorBlinkTime = cursorBlinkTime + dt
                if cursorBlinkTime >= cursorBlinkRate then
                    cursorVisible = not cursorVisible
                    cursorBlinkTime = cursorBlinkTime - cursorBlinkRate
                end

                -- Check for focus loss from clicking elsewhere
                if love.mouse.isDown(1) then
                    local x, y = love.mouse.getPosition()
                    if not self:isPointInEntity(x, y, entityId) then
                        focused = false
                        selectionStart = nil
                    end
                end
            end
        end
    end

    -- Methods for the text input
    local textInput = {
        entityId = entityId,

        getText = function()
            return text
        end,

        setText = function(newText)
            text = newText or ""
            cursorPosition = #text
            selectionStart = nil

            -- Update the visual component
            local visual = world:getComponent(entityId, "visual")
            if visual then
                visual.text = text
            end

            return text
        end,

        focus = function()
            focused = true
            cursorVisible = true
            cursorBlinkTime = 0
            love.keyboard.setKeyRepeat(true)
        end,

        unfocus = function()
            focused = false
            selectionStart = nil
        end,

        isFocused = function()
            return focused
        end
    }

    return entityId, textInput
end

return TextInput
