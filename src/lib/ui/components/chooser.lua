-- Chooser component (segmented control)
local chooser = {}
local utils = require('lib.ui.utils')
local theme = require('lib.ui.theme')

function chooser.new(x, y, options, selected_index)
  local c = {
    x = x or 0,
    y = y or 0,
    options = options or {},
    selected_index = selected_index or 1,
    visible = true,
    enabled = true,

    -- Animation states
    indicator_x = 0,
    indicator_target_x = 0,

    -- Callbacks
    onchange = nil,

    -- Component type
    _type = "chooser",
    _ui_id = nil,
  }

  function c:get_corner_radius()
    return theme.manager:get_config("chooser.corner_radius", 6)
  end

  function c:get_smoothness()
    return theme.manager:get_config("chooser.smoothness", 4.0)
  end

  function c:get_height()
    return theme.manager:get_config("chooser.height", 32)
  end

  function c:get_segment_width()
    local configured_width = theme.manager:get_config("chooser.segment_width")
    if configured_width then
      return configured_width
    end
    
    -- Auto-calculate based on text width
    local font = theme.manager:get_current_font()
    if font and font.actual_font then
      local max_width = 0
      for _, option in ipairs(self.options) do
        local text_width = font.actual_font:getWidth(option)
        max_width = math.max(max_width, text_width)
      end
      local padding = theme.manager:get_config("chooser.indicator_padding", 2) * 4 -- padding on both sides, plus some extra
      return max_width + padding + 20 -- 20px extra for comfortable spacing
    end
    
    return 90 -- fallback
  end

  function c:get_indicator_padding()
    return theme.manager:get_config("chooser.indicator_padding", 2)
  end

  function c:get_text_y_offset()
    return theme.manager:get_config("chooser.text_y_offset", 0)
  end

  function c:get_width()
    return self:get_segment_width() * #self.options
  end

  function c:get_colors()
    return {
      background = theme.manager:get_color('surface_variant', { 0.15, 0.15, 0.15, 1 }),
      indicator = theme.manager:get_color('primary', { 0.5, 0.3, 0.8, 1 }),
      text_active = theme.manager:get_color('on_primary', { 1, 1, 1, 1 }),
      text_inactive = theme.manager:get_color('text_secondary', { 0.7, 0.7, 0.7, 1 }),
      border = theme.manager:get_color('border', { 0.3, 0.3, 0.3, 1 }),
    }
  end

  function c:update_indicator_position()
    local segment_width = self:get_segment_width()
    local padding = self:get_indicator_padding()

    self.indicator_target_x = self.x + ((self.selected_index - 1) * segment_width) + padding
  end

  function c:set_selected_index(index)
    if index >= 1 and index <= #self.options then
      local old_index = self.selected_index
      self.selected_index = index
      self:update_indicator_position()

      if self.onchange and old_index ~= index then
        self.onchange(self, index, self.options[index])
      end
    end
  end

  function c:get_selected_option()
    return self.options[self.selected_index]
  end

  function c:set_options(options)
    self.options = options
    if self.selected_index > #options then
      self.selected_index = math.max(1, #options)
    end
    self:update_indicator_position()
  end

  function c:update(dt)
    if not self.enabled then return end

    -- Animate indicator position
    self.indicator_x = self.indicator_x + (self.indicator_target_x - self.indicator_x) * dt * 12
  end

  function c:draw()
    if not self.visible then return end

    local colors = self:get_colors()
    local width = self:get_width()
    local height = self:get_height()
    local corner_radius = self:get_corner_radius()
    local smoothness = self:get_smoothness()
    local segment_width = self:get_segment_width()
    local padding = self:get_indicator_padding()

    -- Draw background
    utils.draw_superellipse(self.x, self.y, width, height, corner_radius,
      colors.background, colors.border, 1, smoothness)

    -- Draw indicator
    local indicator_width = segment_width - (padding * 2)
    local indicator_height = height - (padding * 2)
    local indicator_y = self.y + padding

    utils.draw_superellipse(self.indicator_x, indicator_y, indicator_width, indicator_height,
      corner_radius - 1, colors.indicator, { 0, 0, 0, 0 }, 0, smoothness)

    -- Draw option text
    local font = theme.manager:get_current_font()
    if font and font.actual_font then
      for i, option in ipairs(self.options) do
        local text_x = self.x + ((i - 1) * segment_width)
        local text_color = i == self.selected_index and colors.text_active or colors.text_inactive

        utils.draw_centered_text(
          option,
          text_x, self.y,
          segment_width, height,
          font.actual_font,
          text_color,
          font.yoffset or self:get_text_y_offset()
        )
      end
    end
  end

  function c:mouse_pressed(x, y, button)
    if button == 1 and self.enabled and self.visible and
        utils.point_in_rect(x, y, self.x, self.y, self:get_width(), self:get_height()) then
      -- Determine which segment was clicked
      local segment_width = self:get_segment_width()
      local relative_x = x - self.x
      local clicked_segment = math.floor(relative_x / segment_width) + 1

      if clicked_segment >= 1 and clicked_segment <= #self.options then
        self:set_selected_index(clicked_segment)
      end

      return true
    end
    return false
  end

  function c:mouse_released(x, y, button)
    -- Override if needed
  end

  function c:mouse_moved(x, y, dx, dy)
    -- Override if needed
  end

  function c:set_position(x, y)
    self.x = x
    self.y = y
    self:update_indicator_position()
  end

  function c:set_enabled(enabled)
    self.enabled = enabled
  end

  function c:set_visible(visible)
    self.visible = visible
  end

  -- Initialize indicator position
  c:update_indicator_position()

  return c
end

return chooser
