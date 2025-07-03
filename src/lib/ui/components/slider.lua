-- Slider component with floating and integer precision modes
local slider = {}
local utils = require('lib.ui.utils')
local theme = require('lib.ui.theme')

function slider.new(x, y, w, min_val, max_val, initial_val, precision_mode)
  local s = {
    x = x or 0,
    y = y or 0,
    w = w or 200,
    min_val = min_val or 0,
    max_val = max_val or 100,
    value = initial_val or min_val or 0,
    precision_mode = precision_mode or "float", -- "float" or "integer"
    visible = true,
    enabled = true,

    -- State
    dragging = false,
    hovered = false,

    -- Display options
    show_ticks = true,
    show_value = true,
    show_min_max = true,

    -- Callbacks
    onchange = nil,
    ondrag = nil,

    -- Component type
    _type = "slider",
    _ui_id = nil,
  }

  function s:get_height()
    return theme.manager:get_config("slider.height", 6)
  end

  function s:get_handle_size()
    return theme.manager:get_config("slider.handle_size", 20)
  end

  function s:get_corner_radius()
    return theme.manager:get_config("slider.corner_radius", 3)
  end

  function s:get_track_corner_radius()
    return theme.manager:get_config("slider.track_corner_radius", 3)
  end

  function s:get_smoothness()
    return theme.manager:get_config("slider.smoothness", 2.0)
  end

  function s:get_colors()
    return {
      track = theme.manager:get_color('surface_variant', { 0.2, 0.2, 0.2, 1 }),
      track_filled = theme.manager:get_color('primary', { 0.5, 0.3, 0.8, 1 }),
      handle = theme.manager:get_color('primary', { 0.5, 0.3, 0.8, 1 }),
      handle_hover = theme.manager:get_color('primary_light', { 0.6, 0.4, 0.9, 1 }),
      text = theme.manager:get_color('text_primary', { 1, 1, 1, 1 }),
      text_muted = theme.manager:get_color('text_muted', { 0.6, 0.6, 0.6, 1 }),
      tick = theme.manager:get_color('text_muted', { 0.4, 0.4, 0.4, 1 }),
    }
  end

  function s:get_total_height()
    local base_height = self:get_handle_size()
    local extra_height = 0

    if self.show_value then
      extra_height = extra_height + 20 -- Space for value text above
    end

    if self.show_ticks and self.precision_mode == "integer" then
      extra_height = extra_height + 15 -- Space for tick marks below
    end

    if self.show_min_max then
      extra_height = extra_height + 15 -- Space for min/max values
    end

    return base_height + extra_height
  end

  function s:get_track_rect()
    local handle_size = self:get_handle_size()
    local track_height = self:get_height()
    local track_y = self.y + (handle_size - track_height) / 2

    if self.show_value then
      track_y = track_y + 20
    end

    -- Leave space for handle on both ends
    local track_x = self.x + handle_size / 2
    local track_width = self.w - handle_size

    return track_x, track_y, track_width, track_height
  end

  function s:get_handle_position()
    local track_x, track_y, track_width, track_height = self:get_track_rect()
    local handle_size = self:get_handle_size()

    local normalized = (self.value - self.min_val) / (self.max_val - self.min_val)
    local handle_x = track_x + (normalized * track_width) - handle_size / 2
    local handle_y = track_y + (track_height - handle_size) / 2

    return handle_x, handle_y
  end

  function s:set_value(value)
    local old_value = self.value

    if self.precision_mode == "integer" then
      value = math.floor(value + 0.5)
    end

    self.value = math.max(self.min_val, math.min(self.max_val, value))

    if self.onchange and old_value ~= self.value then
      self.onchange(self, self.value)
    end
  end

  function s:get_value_from_mouse_x(mouse_x)
    local track_x, _, track_width, _ = self:get_track_rect()
    local relative_x = mouse_x - track_x
    local normalized = math.max(0, math.min(1, relative_x / track_width))
    return self.min_val + normalized * (self.max_val - self.min_val)
  end

  function s:get_tick_positions()
    if self.precision_mode ~= "integer" then return {} end

    local positions = {}
    local track_x, _, track_width, _ = self:get_track_rect()

    for i = self.min_val, self.max_val do
      local normalized = (i - self.min_val) / (self.max_val - self.min_val)
      local tick_x = track_x + normalized * track_width
      table.insert(positions, { x = tick_x, value = i })
    end

    return positions
  end

  function s:update(dt)
    if not self.enabled then return end

    local mx, my = love.mouse.getPosition()
    local handle_x, handle_y = self:get_handle_position()
    local handle_size = self:get_handle_size()

    self.hovered = utils.point_in_rect(mx, my, handle_x, handle_y, handle_size, handle_size)

    if self.dragging then
      local new_value = self:get_value_from_mouse_x(mx)
      self:set_value(new_value)

      if self.ondrag then
        self.ondrag(self, self.value)
      end
    end
  end

  function s:draw()
    if not self.visible then return end

    local colors = self:get_colors()
    local track_x, track_y, track_width, track_height = self:get_track_rect()
    local handle_x, handle_y = self:get_handle_position()
    local handle_size = self:get_handle_size()
    local corner_radius = self:get_corner_radius()
    local track_corner_radius = self:get_track_corner_radius()
    local smoothness = self:get_smoothness()

    -- Draw track background
    utils.draw_superellipse(track_x, track_y, track_width, track_height, track_corner_radius,
      colors.track, { 0, 0, 0, 0 }, 0, smoothness)

    -- Draw filled portion of track
    local normalized = (self.value - self.min_val) / (self.max_val - self.min_val)
    local filled_width = normalized * track_width
    if filled_width > 0 then
      utils.draw_superellipse(track_x, track_y, filled_width, track_height, track_corner_radius,
        colors.track_filled, { 0, 0, 0, 0 }, 0, smoothness)
    end

    -- Draw tick marks
    if self.show_ticks and self.precision_mode == "integer" then
      local tick_positions = self:get_tick_positions()
      local tick_y = track_y + track_height + 5

      for _, tick in ipairs(tick_positions) do
        love.graphics.setColor(colors.tick)
        love.graphics.line(tick.x, tick_y, tick.x, tick_y + 8)
      end
    end

    -- Draw handle
    local handle_color = self.hovered and colors.handle_hover or colors.handle
    utils.draw_superellipse(handle_x, handle_y, handle_size, handle_size, corner_radius,
      handle_color, { 0, 0, 0, 0 }, 0, smoothness)

    -- Draw value text above handle
    if self.show_value then
      local font = theme.manager:get_current_font()
      if font and font.actual_font then
        local value_text
        if self.precision_mode == "integer" then
          value_text = tostring(self.value)
        else
          value_text = string.format("%.2f", self.value)
        end

        local text_x = handle_x + handle_size / 2
        local text_y = self.y

        utils.draw_centered_text(
          value_text,
          text_x - 20, text_y,
          40, 15,
          font.actual_font,
          colors.text,
          0
        )
      end
    end

    -- Draw min/max values
    if self.show_min_max then
      local font = theme.manager:get_current_font()
      if font and font.actual_font then
        local text_y = track_y + track_height + (self.show_ticks and 20 or 8)

        -- Min value (left)
        local min_text = self.precision_mode == "integer" and tostring(self.min_val) or
        string.format("%.1f", self.min_val)
        love.graphics.setColor(colors.text_muted)
        love.graphics.setFont(font.actual_font)
        love.graphics.print(min_text, track_x, text_y)

        -- Max value (right)
        local max_text = self.precision_mode == "integer" and tostring(self.max_val) or
        string.format("%.1f", self.max_val)
        local max_width = font.actual_font:getWidth(max_text)
        love.graphics.print(max_text, track_x + track_width - max_width, text_y)
      end
    end
  end

  function s:mouse_pressed(x, y, button)
    if button == 1 and self.enabled and self.visible then
      local handle_x, handle_y = self:get_handle_position()
      local handle_size = self:get_handle_size()

      -- Check if clicking on handle
      if utils.point_in_rect(x, y, handle_x, handle_y, handle_size, handle_size) then
        self.dragging = true
        return true
      end

      -- Check if clicking on track
      local track_x, track_y, track_width, track_height = self:get_track_rect()
      if utils.point_in_rect(x, y, track_x, track_y, track_width, track_height) then
        local new_value = self:get_value_from_mouse_x(x)
        self:set_value(new_value)
        self.dragging = true
        return true
      end
    end
    return false
  end

  function s:mouse_released(x, y, button)
    if button == 1 then
      self.dragging = false
    end
  end

  function s:mouse_moved(x, y, dx, dy)
    -- Handled in update
  end

  function s:set_position(x, y)
    self.x = x
    self.y = y
  end

  function s:set_size(w, h)
    self.w = w
    -- Height is calculated automatically
  end

  function s:set_range(min_val, max_val)
    self.min_val = min_val
    self.max_val = max_val
    self:set_value(self.value) -- Clamp current value to new range
  end

  function s:set_precision_mode(mode)
    self.precision_mode = mode
    if mode == "integer" then
      self:set_value(self.value) -- Apply integer rounding
    end
  end

  function s:set_enabled(enabled)
    self.enabled = enabled
    if not enabled then
      self.dragging = false
    end
  end

  function s:set_visible(visible)
    self.visible = visible
  end

  return s
end

return slider
