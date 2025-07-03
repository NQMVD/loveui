-- Text/Label component
local text_component = {}
local theme = require('lib.ui.theme')

function text_component.new(x, y, w, text_content, font_size, color_name)
  local t = {
    x = x or 0,
    y = y or 0,
    w = w or 200,
    text_content = text_content or "",
    font_size = font_size or "normal",
    color_name = color_name or "text_primary",
    visible = true,

    -- Text properties
    wrap_limit = nil,  -- Will use width if not set
    line_height = nil, -- Will use theme default
    align = "left",    -- "left", "center", "right", "justify"
    valign = "top",    -- "top", "center", "bottom"

    -- Calculated properties
    wrapped_text = {},
    text_height = 0,

    -- Component type
    _type = "text",
    _ui_id = nil,
  }

  function t:get_line_height()
    return self.line_height or theme.manager:get_config("text.line_height", 1.2)
  end

  function t:get_wrap_mode()
    return theme.manager:get_config("text.wrap_mode", "word")
  end

  function t:get_color()
    return theme.manager:get_color(self.color_name, { 1, 1, 1, 1 })
  end

  function t:get_font()
    local current_theme = theme.manager:get_current_theme()
    if current_theme and current_theme.fonts then
      if current_theme.fonts.highdpi and current_theme.fonts.highdpi.berkeley then
        return current_theme.fonts.highdpi.berkeley[self.font_size]
      end
    end
    return theme.manager:get_current_font()
  end

  function t:wrap_text()
    local font = self:get_font()
    if not font or not font.actual_font then
      self.wrapped_text = { self.text_content }
      self.text_height = 20
      return
    end

    local wrap_limit = self.wrap_limit or self.w
    if wrap_limit <= 0 then
      self.wrapped_text = { self.text_content }
      self.text_height = font.actual_font:getHeight()
      return
    end

    local wrap_mode = self:get_wrap_mode()
    if wrap_mode == "none" then
      self.wrapped_text = { self.text_content }
      self.text_height = font.actual_font:getHeight()
      return
    end

    -- Wrap text based on mode
    self.wrapped_text = {}
    local words = {}

    if wrap_mode == "word" then
      -- Split by words
      for word in self.text_content:gmatch("%S+") do
        table.insert(words, word)
      end
    else
      -- Character mode - split by characters
      for i = 1, #self.text_content do
        table.insert(words, self.text_content:sub(i, i))
      end
    end

    local current_line = ""
    local space_width = font.actual_font:getWidth(" ")

    for i, word in ipairs(words) do
      local test_line = current_line == "" and word or (current_line .. " " .. word)
      local test_width = font.actual_font:getWidth(test_line)

      if test_width > wrap_limit and current_line ~= "" then
        -- Line is too long, finish current line and start new one
        table.insert(self.wrapped_text, current_line)
        current_line = word
      else
        current_line = test_line
      end
    end

    -- Add the last line
    if current_line ~= "" then
      table.insert(self.wrapped_text, current_line)
    end

    -- If no lines were created, add empty string
    if #self.wrapped_text == 0 then
      self.wrapped_text = { "" }
    end

    -- Calculate total text height
    local line_height = font.actual_font:getHeight() * self:get_line_height()
    self.text_height = #self.wrapped_text * line_height
  end

  function t:set_text(text_content)
    self.text_content = text_content or ""
    self:wrap_text()
  end

  function t:set_font_size(font_size)
    self.font_size = font_size
    self:wrap_text()
  end

  function t:set_color(color_name)
    self.color_name = color_name
  end

  function t:set_width(width)
    self.w = width
    self:wrap_text()
  end

  function t:set_wrap_limit(limit)
    self.wrap_limit = limit
    self:wrap_text()
  end

  function t:set_align(align)
    self.align = align
  end

  function t:set_valign(valign)
    self.valign = valign
  end

  function t:update(dt)
    -- Text components generally don't need updates
    -- Override if animation or other dynamic behavior is needed
  end

  function t:draw()
    if not self.visible or self.text_content == "" then return end

    local font = self:get_font()
    if not font or not font.actual_font then return end

    local color = self:get_color()
    local line_height_multiplier = self:get_line_height()
    local font_height = font.actual_font:getHeight()
    local line_spacing = font_height * line_height_multiplier

    love.graphics.setColor(color)
    love.graphics.setFont(font.actual_font)

    -- Calculate starting Y position based on vertical alignment
    local start_y = self.y
    if self.valign == "center" then
      start_y = self.y - self.text_height / 2
    elseif self.valign == "bottom" then
      start_y = self.y - self.text_height
    end

    -- Draw each line
    for i, line in ipairs(self.wrapped_text) do
      local line_y = start_y + (i - 1) * line_spacing
      local line_x = self.x

      -- Calculate X position based on horizontal alignment
      if self.align == "center" then
        local line_width = font.actual_font:getWidth(line)
        line_x = self.x + (self.w - line_width) / 2
      elseif self.align == "right" then
        local line_width = font.actual_font:getWidth(line)
        line_x = self.x + self.w - line_width
      end
      -- "left" and "justify" use default line_x

      love.graphics.print(line, line_x, line_y)
    end
  end

  function t:mouse_pressed(x, y, button)
    -- Text components typically don't handle mouse events
    -- Override if clickable text is needed
    return false
  end

  function t:mouse_released(x, y, button)
    -- Override if needed
  end

  function t:mouse_moved(x, y, dx, dy)
    -- Override if needed
  end

  function t:set_position(x, y)
    self.x = x
    self.y = y
  end

  function t:set_size(w, h)
    self.w = w
    -- Height is calculated automatically based on text content
    self:wrap_text()
  end

  function t:set_visible(visible)
    self.visible = visible
  end

  function t:get_width()
    return self.w
  end

  function t:get_height()
    return self.text_height
  end

  function t:get_text_bounds()
    return self.x, self.y, self.w, self.text_height
  end

  -- Initialize wrapped text
  t:wrap_text()

  return t
end

return text_component
