-- debugui.lua
-- A simple UI library for Love2D to create buttons, sliders, and checkboxes on the right side of the screen.

local debugui = {}
debugui.elements = {}
debugui.config = {
  panelWidth = 200,
  padding = 10,
  elementHeight = 25,
  sliderHeight = 40,
  checkboxHeight = 25,
  font = love.graphics.newFont(12),
  colors = {
    background = { 0.15, 0.15, 0.2, 0.85 },
    button = { 0.3, 0.3, 0.35, 1 },
    buttonHover = { 0.4, 0.4, 0.45, 1 },
    buttonPressed = { 0.2, 0.2, 0.25, 1 },
    sliderTrack = { 0.25, 0.25, 0.3, 1 },
    sliderKnob = { 0.6, 0.6, 0.65, 1 },
    checkboxBox = { 0.3, 0.3, 0.35, 1 },
    checkboxHover = { 0.4, 0.4, 0.45, 1 },
    checkboxCheck = { 0.2, 0.7, 0.3, 1 },
    text = { 0.9, 0.9, 0.9, 1 }
  }
}

local currentY

function debugui.initializeLayout()
  currentY = debugui.config.padding
  local screenWidth = love.graphics.getWidth()
  for _, element in ipairs(debugui.elements) do
    element.x = screenWidth - debugui.config.panelWidth + debugui.config.padding / 2
    element.y = currentY
    if element.type == "slider" then
      element.sliderY = element.y + debugui.config.font:getHeight() + 5
      element:updateKnobPosition()
    end
    currentY = currentY + element.height + debugui.config.padding
  end
end

function debugui.addButton(text, onClick)
  local screenWidth = love.graphics.getWidth()
  local button = {
    type = "button",
    text = text,
    onClick = onClick,
    x = screenWidth - debugui.config.panelWidth + debugui.config.padding / 2,
    y = currentY or debugui.config.padding,
    width = debugui.config.panelWidth - debugui.config.padding,
    height = debugui.config.elementHeight,
    isHovered = false,
    isPressed = false
  }
  if not currentY then currentY = debugui.config.padding end
  currentY = currentY + button.height + debugui.config.padding
  table.insert(debugui.elements, button)
  return button
end

function debugui.addSlider(label, targetTable, targetKey, minValue, maxValue, initialValue, post_process)
  local screenWidth = love.graphics.getWidth()
  local value = initialValue or targetTable[targetKey] or minValue
  targetTable[targetKey] = value

  local slider = {
    type = "slider",
    label = label,
    targetTable = targetTable,
    targetKey = targetKey,
    minValue = minValue,
    maxValue = maxValue,
    currentValue = value,
    post_process = post_process,
    x = screenWidth - debugui.config.panelWidth + debugui.config.padding / 2,
    y = currentY or debugui.config.padding,
    width = debugui.config.panelWidth - debugui.config.padding,
    height = debugui.config.sliderHeight,
    sliderTrackHeight = 8,
    knobWidth = 10,
    knobHeight = 16,
    isHovered = false,
    isDragging = false
  }
  slider.sliderY = slider.y + debugui.config.font:getHeight() + 5
  slider.updateKnobPosition = function(self)
    local percent = (self.currentValue - self.minValue) / (self.maxValue - self.minValue)
    percent = math.max(0, math.min(1, percent))
    self.knobX = self.x + percent * (self.width - self.knobWidth)
  end
  slider:updateKnobPosition()

  if not currentY then currentY = debugui.config.padding end
  currentY = currentY + slider.height + debugui.config.padding
  table.insert(debugui.elements, slider)
  return slider
end

function debugui.addCheckbox(label, targetTable, targetKey, initialValue, onChange)
  local screenWidth = love.graphics.getWidth()
  local value = (initialValue ~= nil) and initialValue or (targetTable[targetKey] or false)
  targetTable[targetKey] = value

  local checkbox = {
    type = "checkbox",
    label = label,
    targetTable = targetTable,
    targetKey = targetKey,
    isChecked = value,
    onChange = onChange,
    x = screenWidth - debugui.config.panelWidth + debugui.config.padding / 2,
    y = currentY or debugui.config.padding,
    width = debugui.config.panelWidth - debugui.config.padding,
    height = debugui.config.checkboxHeight,
    boxSize = 18,
    isHovered = false
  }
  if not currentY then currentY = debugui.config.padding end
  currentY = currentY + checkbox.height + debugui.config.padding
  table.insert(debugui.elements, checkbox)
  return checkbox
end

function debugui.addSeparator()
  local screenWidth = love.graphics.getWidth()
  local separator = {
    type = "separator",
    x = screenWidth - debugui.config.panelWidth + debugui.config.padding / 2,
    y = currentY or debugui.config.padding,
    width = debugui.config.panelWidth - debugui.config.padding,
    height = 1,
    isHovered = false
  }
  if not currentY then currentY = debugui.config.padding end
  currentY = currentY + separator.height + debugui.config.padding
  table.insert(debugui.elements, separator)
  return separator
end

function debugui.update(dt)
  local mx, my = love.mouse.getPosition()
  local mousePressed = love.mouse.isDown(1)
  local mouseJustReleased = debugui.lastMousePressed and not mousePressed
  debugui.lastMousePressed = mousePressed

  for _, el in ipairs(debugui.elements) do
    el.isHovered = mx >= el.x and mx <= el.x + el.width and
        my >= el.y and my <= el.y + el.height

    if el.type == "button" then
      if el.isHovered and mousePressed then
        el.isPressed = true
      elseif el.isPressed and el.isHovered and mouseJustReleased then
        if el.onClick then el.onClick() end
        el.isPressed = false
      elseif not mousePressed then
        el.isPressed = false
      end
    elseif el.type == "slider" then
      local sliderInteractionY1 = el.sliderY - (el.knobHeight - el.sliderTrackHeight) / 2
      local sliderInteractionY2 = el.sliderY + el.sliderTrackHeight + (el.knobHeight - el.sliderTrackHeight) / 2
      local onSliderTrack = mx >= el.x and mx <= el.x + el.width and
          my >= sliderInteractionY1 and my <= sliderInteractionY2

      if el.isDragging then
        if mousePressed then
          local percent = (mx - el.x - el.knobWidth / 2) / (el.width - el.knobWidth)
          percent = math.max(0, math.min(1, percent))
          el.currentValue = el.minValue + percent * (el.maxValue - el.minValue)
          if el.post_process then
            el.currentValue = el.post_process(el.currentValue)
          end
          el.targetTable[el.targetKey] = el.currentValue
          el:updateKnobPosition()
        else
          el.isDragging = false
        end
      elseif onSliderTrack and mousePressed then
        el.isDragging = true
        local percent = (mx - el.x - el.knobWidth / 2) / (el.width - el.knobWidth)
        percent = math.max(0, math.min(1, percent))
        el.currentValue = el.minValue + percent * (el.maxValue - el.minValue)
        if el.post_process then
          el.currentValue = el.post_process(el.currentValue)
        end
        el.targetTable[el.targetKey] = el.currentValue
        el:updateKnobPosition()
      end
    elseif el.type == "checkbox" then
      -- Checkbox box area is at (el.x, el.y) with size el.boxSize
      local boxX, boxY = el.x, el.y + (el.height - el.boxSize) / 2
      local onBox = mx >= boxX and mx <= boxX + el.boxSize and
          my >= boxY and my <= boxY + el.boxSize

      if onBox and el.isHovered and mouseJustReleased then
        el.isChecked = not el.isChecked
        el.targetTable[el.targetKey] = el.isChecked
        if el.onChange then el.onChange(el.isChecked) end
      end
    end
  end
end

function debugui.draw()
  love.graphics.push("all")
  love.graphics.setFont(debugui.config.font)
  local screenWidth, screenHeight = love.graphics.getWidth(), love.graphics.getHeight()
  local panelX = screenWidth - debugui.config.panelWidth
  local panelActualHeight = currentY

  love.graphics.setColor(debugui.config.colors.background)
  love.graphics.rectangle("fill", panelX, 0, debugui.config.panelWidth, screenHeight)

  for _, el in ipairs(debugui.elements) do
    if el.type == "button" then
      if el.isPressed then
        love.graphics.setColor(debugui.config.colors.buttonPressed)
      elseif el.isHovered then
        love.graphics.setColor(debugui.config.colors.buttonHover)
      else
        love.graphics.setColor(debugui.config.colors.button)
      end
      love.graphics.rectangle("fill", el.x, el.y, el.width, el.height, 3, 3)
      love.graphics.setColor(debugui.config.colors.text)
      love.graphics.printf(el.text, el.x, el.y + (el.height - debugui.config.font:getHeight()) / 2, el.width,
        "center")
    elseif el.type == "slider" then
      love.graphics.setColor(debugui.config.colors.text)
      love.graphics.printf(el.label .. ": " .. string.format("%.2f", el.currentValue), el.x, el.y, el.width, "left")

      love.graphics.setColor(debugui.config.colors.sliderTrack)
      love.graphics.rectangle("fill", el.x, el.sliderY, el.width, el.sliderTrackHeight, el.sliderTrackHeight / 2,
        el.sliderTrackHeight / 2)

      love.graphics.setColor(debugui.config.colors.sliderKnob)
      love.graphics.rectangle("fill", el.knobX, el.sliderY - (el.knobHeight - el.sliderTrackHeight) / 2, el.knobWidth,
        el.knobHeight, 3, 3)
    elseif el.type == "checkbox" then
      local boxX = el.x
      local boxY = el.y + (el.height - el.boxSize) / 2
      if el.isHovered then
        love.graphics.setColor(debugui.config.colors.checkboxHover)
      else
        love.graphics.setColor(debugui.config.colors.checkboxBox)
      end
      love.graphics.rectangle("fill", boxX, boxY, el.boxSize, el.boxSize, 4, 4)

      if el.isChecked then
        love.graphics.setColor(debugui.config.colors.checkboxCheck)
        love.graphics.setLineWidth(3)
        love.graphics.line(boxX + 4, boxY + el.boxSize / 2, boxX + el.boxSize / 2, boxY + el.boxSize - 4)
        love.graphics.line(boxX + el.boxSize / 2, boxY + el.boxSize - 4, boxX + el.boxSize - 4, boxY + 4)
        love.graphics.setLineWidth(1)
      end
      love.graphics.setColor(debugui.config.colors.text)
      love.graphics.printf(el.label, boxX + el.boxSize + 8, el.y + (el.height - debugui.config.font:getHeight()) / 2,
        el.width - el.boxSize - 8, "left")
    elseif el.type == "separator" then
      love.graphics.setColor(debugui.config.colors.text)
      love.graphics.rectangle("fill", el.x, el.y + el.height / 2, el.width, 1)
    end
  end
  love.graphics.pop()
end

function debugui.handleResize()
  debugui.initializeLayout()
end

debugui.initializeLayout()

return debugui
