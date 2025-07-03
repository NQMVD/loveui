-- Checkbox component
local checkbox = {}
local utils = require('lib.ui.utils')
local theme = require('lib.ui.theme')

function checkbox.new(x, y, label, initial_checked)
  local cb = {
    x = x or 0,
    y = y or 0,
    label = label or "",
    checked = initial_checked or false,
    visible = true,
    enabled = true,

    -- State
    hovered = false,

    -- Animation
    check_scale = 0,

    -- Callbacks
    onchange = nil,

    -- Component type
    _type = "checkbox",
    _ui_id = nil,
  }

  function cb:get_size()
    return theme.manager:get_config("checkbox.size", 20)
  end

  function cb:get_corner_radius()
    return theme.manager:get_config("checkbox.corner_radius", 4)
  end

  function cb:get_smoothness()
    return theme.manager:get_config("checkbox.smoothness", 2.0)
  end

  function cb:get_border_width()
    return theme.manager:get_config("checkbox.border_width", 2)
  end

  function cb:get_colors()
    return {
      background_unchecked = theme.manager:get_color('surface', { 0.1, 0.1, 0.1, 0 }),
      background_checked = theme.manager:get_color('primary', { 0.5, 0.3, 0.8, 1 }),
      border_unchecked = theme.manager:get_color('border', { 0.4, 0.4, 0.4, 1 }),
      border_checked = theme.manager:get_color('primary', { 0.5, 0.3, 0.8, 1 }),
      checkmark = theme.manager:get_color('on_primary', { 1, 1, 1, 1 }),
      text = theme.manager:get_color('text_primary', { 1, 1, 1, 1 }),
      disabled = theme.manager:get_color('text_disabled', { 0.3, 0.3, 0.3, 1 }),
    }
  end

  function cb:get_total_width()
    local size = self:get_size()
    local spacing = 8

    if self.label == "" then
      return size
    end

    local font = theme.manager:get_current_font()
    if font and font.actual_font then
      local text_width = font.actual_font:getWidth(self.label)
      return size + spacing + text_width
    end

    return size + spacing + 100 -- fallback
  end

  function cb:get_total_height()
    local size = self:get_size()
    local font = theme.manager:get_current_font()

    if font and font.actual_font then
      local text_height = font.actual_font:getHeight()
      return math.max(size, text_height)
    end

    return size
  end

  function cb:set_checked(checked)
    if self.checked ~= checked then
      self.checked = checked

      if self.onchange then
        self.onchange(self, checked)
      end
    end
  end

  function cb:toggle()
    self:set_checked(not self.checked)
  end

  function cb:update(dt)
    if not self.enabled then return end

    local mx, my = love.mouse.getPosition()
    local total_width = self:get_total_width()
    local total_height = self:get_total_height()

    self.hovered = utils.point_in_rect(mx, my, self.x, self.y, total_width, total_height)

    -- Animate checkmark
    local target_scale = self.checked and 1 or 0
    self.check_scale = self.check_scale + (target_scale - self.check_scale) * dt * 12
  end

  function cb:draw()
    if not self.visible then return end

    local colors = self:get_colors()
    local size = self:get_size()
    local corner_radius = self:get_corner_radius()
    local smoothness = self:get_smoothness()
    local border_width = self:get_border_width()

    -- Choose colors based on state
    local bg_color = self.checked and colors.background_checked or colors.background_unchecked
    local border_color = self.checked and colors.border_checked or colors.border_unchecked
    local text_color = self.enabled and colors.text or colors.disabled

    if not self.enabled then
      bg_color = { bg_color[1] * 0.5, bg_color[2] * 0.5, bg_color[3] * 0.5, bg_color[4] * 0.5 }
      border_color = colors.disabled
    end

    -- Draw checkbox background
    utils.draw_superellipse(self.x, self.y, size, size, corner_radius,
      bg_color, border_color, border_width, smoothness)

    -- Draw checkmark
    if self.check_scale > 0.01 then
      local check_size = size * 0.6 * self.check_scale
      local check_x = self.x + (size - check_size) / 2
      local check_y = self.y + (size - check_size) / 2

      -- Simple checkmark using lines
      love.graphics.push()
      love.graphics.translate(check_x + check_size / 2, check_y + check_size / 2)
      love.graphics.scale(self.check_scale)

      love.graphics.setColor(colors.checkmark)
      love.graphics.setLineWidth(2)

      -- Draw checkmark path
      local points = {
        -check_size * 0.3, 0,
        -check_size * 0.1, check_size * 0.2,
        check_size * 0.3, -check_size * 0.2
      }

      for i = 1, #points - 2, 2 do
        love.graphics.line(points[i], points[i + 1], points[i + 2], points[i + 3])
      end

      love.graphics.pop()
    end

    -- Draw label text
    if self.label ~= "" then
      local font = theme.manager:get_current_font()
      if font and font.actual_font then
        local text_x = self.x + size + 8
        local text_y = self.y + (size - font.actual_font:getHeight()) / 2

        love.graphics.setColor(text_color)
        love.graphics.setFont(font.actual_font)
        love.graphics.print(self.label, text_x, text_y)
      end
    end
  end

  function cb:mouse_pressed(x, y, button)
    if button == 1 and self.enabled and self.visible then
      local total_width = self:get_total_width()
      local total_height = self:get_total_height()

      if utils.point_in_rect(x, y, self.x, self.y, total_width, total_height) then
        self:toggle()
        return true
      end
    end
    return false
  end

  function cb:mouse_released(x, y, button)
    -- Override if needed
  end

  function cb:mouse_moved(x, y, dx, dy)
    -- Override if needed
  end

  function cb:set_position(x, y)
    self.x = x
    self.y = y
  end

  function cb:set_label(label)
    self.label = label
  end

  function cb:set_enabled(enabled)
    self.enabled = enabled
  end

  function cb:set_visible(visible)
    self.visible = visible
  end

  function cb:get_width()
    return self:get_total_width()
  end

  function cb:get_height()
    return self:get_total_height()
  end

  return cb
end

return checkbox
