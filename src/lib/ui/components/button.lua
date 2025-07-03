-- New Button component with zero hardcoded values
local button = {}
local utils = require('lib.ui.utils')
local theme = require('lib.ui.theme')

function button.new(text, x, y, w, h, style)
  local btn = {
    text = text or "",
    x = x or 0,
    y = y or 0,
    w = w,
    h = h,
    style = style or "primary",
    state = "normal",
    enabled = true,
    visible = true,
    onclick = nil,
    onhover = nil,
    onunhover = nil,

    -- Animation states
    transition = 0,
    shine_intensity = 0,
    shine_offset_x = 0,
    shine_offset_y = 0,

    -- Component type
    _type = "button",
    _ui_id = nil,
  }

  function btn:get_corner_radius()
    return theme.manager:get_current_theme().config:get_with_inheritance("button", "corner_radius", 8)
  end

  function btn:get_smoothness()
    return theme.manager:get_current_theme().config:get_with_inheritance("button", "smoothness", 4.0)
  end
  
  function btn:get_border_width()
    return theme.manager:get_current_theme().config:get_with_inheritance("button", "border_width", 1)
  end

  function btn:get_height()
    return self.h or theme.manager:get_config("button.height", 36)
  end

  function btn:get_width()
    if self.w then
      return self.w
    end

    -- Auto-calculate width based on text
    local font = theme.manager:get_current_font()
    if font and font.actual_font then
      local text_width = font.actual_font:getWidth(self.text)
      local padding_x = theme.manager:get_config("button.padding.x", 16)
      return text_width + (padding_x * 2)
    end

    return 120 -- fallback
  end

  function btn:get_padding()
    return {
      x = theme.manager:get_config("button.padding.x", 16),
      y = theme.manager:get_config("button.padding.y", 8)
    }
  end

  function btn:get_shine_intensity()
    return theme.manager:get_config("button.shine_intensity", 0.15)
  end

  function btn:get_text_y_offset()
    return theme.manager:get_config("button.text_y_offset", 0)
  end

  function btn:update(dt)
    if not self.enabled then
      self.state = "disabled"
      return
    end

    local mx, my = love.mouse.getPosition()
    local is_hovered = utils.point_in_rect(mx, my, self.x, self.y, self:get_width(), self:get_height())

    local previous_state = self.state

    if love.mouse.isDown(1) and is_hovered then
      self.state = "pressed"
    elseif is_hovered then
      self.state = "hover"
    else
      self.state = "normal"
    end

    -- Trigger callbacks
    if previous_state ~= "hover" and self.state == "hover" and self.onhover then
      self.onhover(self)
    elseif previous_state == "hover" and self.state ~= "hover" and self.onunhover then
      self.onunhover(self)
    end

    -- Smooth transitions
    local target = self.state == "normal" and 0 or (self.state == "hover" and 0.4 or 0.7)
    self.transition = self.transition + (target - self.transition) * dt * 12

    -- Inner shine for enhanced buttons
    if self:has_shine() then
      local base_shine = self:get_shine_intensity()
      local shine_target = self.state == "normal" and base_shine or (self.state == "hover" and 0.7 or 0.3)
      self.shine_intensity = self.shine_intensity + (shine_target - self.shine_intensity) * dt * 10
    else
      self.shine_intensity = 0
    end
  end

  function btn:draw()
    if not self.visible then return end

    local colors = self:get_colors()
    local bg_color = colors.background
    local text_color = colors.text

    if self.transition > 0 then
      bg_color = utils.lerp_color(bg_color, colors.background_hover, self.transition)
    end

    local corner_radius = self:get_corner_radius()
    local smoothness = self:get_smoothness()
    local width = self:get_width()
    local height = self:get_height()
    local border_width = self:get_border_width()

    -- Draw button background
    if self:has_shine() then
      utils.draw_button_with_shine(
        self.x, self.y,
        width, height,
        corner_radius,
        smoothness,
        bg_color,
        {
          shine_color = colors.shine_color or { 1, 1, 1, 1 },
          shine_intensity = self.shine_intensity,
          offset_x = self.shine_offset_x,
          offset_y = self.shine_offset_y
        }
      )
    else
      utils.draw_superellipse(self.x, self.y, width, height, corner_radius,
        bg_color, colors.border, border_width, smoothness)
    end

    -- Draw text
    local font = theme.manager:get_current_font()
    if font and font.actual_font then
      utils.draw_centered_text(
        self.text,
        self.x, self.y,
        width, height,
        font.actual_font,
        text_color,
        font.yoffset or self:get_text_y_offset()
      )
    end
  end

  function btn:get_variant()
    return theme.manager:get_config("button_variants." .. self.style, {})
  end
  
  function btn:has_shine()
    local variant = self:get_variant()
    return variant.has_shine or false
  end

  function btn:get_colors()
    local variant = self:get_variant()
    if not variant or not variant.background_color then
      -- Fallback for unknown variants
      return {
        background = { 0.3, 0.3, 0.3, 1 },
        background_hover = { 0.4, 0.4, 0.4, 1 },
        border = { 0.5, 0.5, 0.5, 1 },
        text = { 1, 1, 1, 1 }
      }
    end
    
    local colors = {}
    
    -- Background colors
    if type(variant.background_color) == "string" then
      colors.background = theme.manager:get_color(variant.background_color, { 0.3, 0.3, 0.3, 1 })
    else
      colors.background = variant.background_color
    end
    
    if type(variant.background_hover_color) == "string" then
      colors.background_hover = theme.manager:get_color(variant.background_hover_color, { 0.4, 0.4, 0.4, 1 })
    else
      colors.background_hover = variant.background_hover_color or colors.background
    end
    
    -- Text color
    if type(variant.text_color) == "string" then
      colors.text = theme.manager:get_color(variant.text_color, { 1, 1, 1, 1 })
    else
      colors.text = variant.text_color or { 1, 1, 1, 1 }
    end
    
    -- Border color
    if variant.border_color then
      if type(variant.border_color) == "string" then
        colors.border = theme.manager:get_color(variant.border_color, { 0.5, 0.5, 0.5, 1 })
      else
        colors.border = variant.border_color
      end
    else
      colors.border = { 0, 0, 0, 0 } -- No border
    end
    
    -- Shine color
    if variant.shine_color then
      if type(variant.shine_color) == "string" then
        colors.shine_color = theme.manager:get_color(variant.shine_color, { 1, 1, 1, 1 })
      else
        colors.shine_color = variant.shine_color
      end
    else
      colors.shine_color = { 1, 1, 1, 1 }
    end
    
    return colors
  end

  function btn:mouse_pressed(x, y, button_num)
    if button_num == 1 and self.enabled and self.visible and
        utils.point_in_rect(x, y, self.x, self.y, self:get_width(), self:get_height()) then
      if self.onclick then
        self.onclick(self)
      end
      return true
    end
    return false
  end

  function btn:mouse_released(x, y, button_num)
    -- Override if needed
  end

  function btn:mouse_moved(x, y, dx, dy)
    -- Override if needed
  end

  function btn:set_position(x, y)
    self.x = x
    self.y = y
  end

  function btn:set_size(w, h)
    self.w = w
    self.h = h
  end

  function btn:set_text(text)
    self.text = text
  end

  function btn:set_enabled(enabled)
    self.enabled = enabled
  end

  function btn:set_visible(visible)
    self.visible = visible
  end

  function btn:set_style(style)
    self.style = style
  end

  return btn
end

return button
