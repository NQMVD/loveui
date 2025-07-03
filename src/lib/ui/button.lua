local button = {}
local utils = require('lib.ui.utils')
local theme = require('lib.ui.theme')

function button.new(text, x, y, w, h, style, corner_radius, smoothness)
  style = style or "primary"

  local btn = {
    text = text,
    x = x,
    y = y,
    w = w or 120,
    h = h, -- will be set dynamically
    style = style,
    state = "normal",
    enabled = true,
    onclick = nil,
    transition = 0,
    shine_intensity = 0,
    -- Store overrides, use theme values dynamically
    _corner_radius_override = corner_radius,
    _smoothness_override = smoothness,
  }

  function btn:set_corner_style(radius, smoothness)
    self._corner_radius_override = radius
    self._smoothness_override = smoothness
  end

  function btn:get_corner_radius()
    return self._corner_radius_override or theme.get_style('button', 'corner_radius', 8)
  end

  function btn:get_smoothness()
    return self._smoothness_override or theme.get_style('button', 'smoothness', 4.0)
  end

  function btn:get_height()
    return self.h or theme.get_style('button', 'height', 36)
  end

  function btn:update(dt, more)
    local mx, my = love.mouse.getPosition()
    local is_hovered = utils.point_in_rect(mx, my, self.x, self.y, self.w, self:get_height())

    if not self.enabled then
      self.state = "disabled"
      return
    end

    if love.mouse.isDown(1) and is_hovered then
      self.state = "pressed"
    elseif is_hovered then
      self.state = "hover"
    else
      self.state = "normal"
    end

    -- Smooth transitions
    local target = self.state == "normal" and 0 or (self.state == "hover" and 0.4 or 0.7)
    self.transition = self.transition + (target - self.transition) * dt * 12

    -- Inner shine for enhanced buttons
    local base_shine = theme.get_style('button', 'shine_intensity', 0.15)
    if self.style == "primary" or self.style == "secondary_shine" then
      local shine_target = self.state == "normal" and base_shine or (self.state == "hover" and 0.7 or 0.3)
      if self.style == "secondary_shine" then
        shine_target = self.state == "normal" and (base_shine * 0.8) or (self.state == "hover" and 0.4 or 0.1)
      end
      self.shine_intensity = self.shine_intensity + (shine_target - self.shine_intensity) * dt * 10
    else
      self.shine_intensity = 0
    end
    if more then
      self.shine_offset_x = more.shine_offset_x or 0
      self.shine_offset_y = more.shine_offset_y or 0
    end
  end

  function btn:draw()
    local colors = self:get_colors()

    local bg_color = colors.background
    local text_color = colors.text

    if self.transition > 0 then
      bg_color = utils.lerp_color(bg_color, colors.background_hover, self.transition)
    end

    -- Draw with theme-configured superellipse shapes
    local corner_radius = self:get_corner_radius()
    local smoothness = self:get_smoothness()
    local height = self:get_height()

    if self.style == "primary" or self.style == "secondary_shine" then
      -- local shine_loss = theme.get_style('button', 'shine_loss', 0.0)
      utils.draw_button_with_shine(
        self.x, self.y,
        self.w, height,
        corner_radius,
        smoothness,
        bg_color,
        {
          shine_color = self.shine_color,
          shine_intensity = self.shine_intensity,
          offset_x = self.shine_offset_x,
          offset_y = self.shine_offset_y
        }
      )
    else
      utils.draw_superellipse(self.x, self.y, self.w, height, corner_radius,
        bg_color, colors.border, 1, smoothness)
    end

    utils.draw_centered_text(
      self.text,
      self.x, self.y,
      self.w, self:get_height(),
      love.graphics.getFont(),
      text_color,
      theme.current.font.yoffset or 0
    )
  end

  function btn:get_colors()
    if self.style == "primary" then
      return {
        background = theme.get_color('primary', { 0.5, 0.3, 0.8, 1 }),
        background_hover = theme.get_color('primary_dark', { 0.4, 0.2, 0.7, 1 }),
        border = { 0, 0, 0, 0 },
        text = { 1, 1, 1, 1 },
        shine_color = { 1, 1, 1, 1 }
      }
    elseif self.style == "secondary" then
      return {
        background = theme.get_color('surface_variant', { 0.2, 0.2, 0.2, 1 }),
        background_hover = theme.get_color('border', { 0.3, 0.3, 0.3, 1 }),
        border = theme.get_color('border', { 0.3, 0.3, 0.3, 1 }),
        text = theme.get_color('text_primary', { 1, 1, 1, 1 })
      }
    elseif self.style == "secondary_shine" then
      return {
        background = theme.get_color('surface_variant', { 0.2, 0.2, 0.2, 1 }),
        background_hover = theme.get_color('border', { 0.3, 0.3, 0.3, 1 }),
        border = { 0, 0, 0, 0 },
        text = theme.get_color('text_primary', { 1, 1, 1, 1 }),
        shine_color = theme.get_color('text_muted', { 0.6, 0.6, 0.6, 1 })
      }
    end
  end

  function btn:mouse_pressed(x, y, button)
    if button == 1 and self.enabled and
        utils.point_in_rect(x, y, self.x, self.y, self.w, self:get_height()) then
      if self.onclick then
        self.onclick(self)
      end
      return true
    end
    return false
  end

  return btn
end

return button
