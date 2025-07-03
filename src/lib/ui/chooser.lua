-- Segmented control style like Chart view | Table view in the reference
local chooser = {}
local utils = require('lib.ui.utils')
local theme = require('lib.ui.theme')

function chooser.new(x, y, options, selected_index)
  selected_index = selected_index or 1

  local ch = {
    x = x,
    y = y,
    w = 0,
    h = nil, -- will be set dynamically
    options = options or {},
    selected = selected_index,
    on_change = nil,
    -- Store overrides, use theme values dynamically
    _segment_width_override = nil,
    _corner_radius_override = nil,
    _smoothness_override = nil,
    _indicator_padding_override = nil,
    transition = 0,
  }

  function ch:set_corner_style(radius, smoothness)
    self._corner_radius_override = radius
    self._smoothness_override = smoothness
  end

  function ch:set_segment_width(width)
    self._segment_width_override = width
    self:rebuild()
  end

  function ch:get_height()
    return self.h or theme.get_style('chooser', 'height', 32)
  end

  function ch:get_segment_width()
    return self._segment_width_override or theme.get_style('chooser', 'segment_width', 90)
  end

  function ch:get_corner_radius()
    return self._corner_radius_override or theme.get_style('chooser', 'corner_radius', 6)
  end

  function ch:get_smoothness()
    return self._smoothness_override or theme.get_style('chooser', 'smoothness', 4.0)
  end

  function ch:get_indicator_padding()
    return self._indicator_padding_override or theme.get_style('chooser', 'indicator_padding', 2)
  end

  function ch:rebuild()
    self.w = #self.options * self:get_segment_width()
  end

  function ch:select(index)
    if index >= 1 and index <= #self.options then
      local old_selected = self.selected
      self.selected = index

      if self.on_change and old_selected ~= index then
        self.on_change(index, self.options[index])
      end
    end
  end

  function ch:update(dt)
    -- local mx, my = love.mouse.getPosition()
    -- local is_hovered = utils.point_in_rect(mx, my, self.x, self.y, self.w, self:get_height())

    -- Smooth transition for selected indicator
    local target_x = (self.selected - 1) * self:get_segment_width()
    if not self.indicator_x then
      self.indicator_x = target_x
    end
    self.indicator_x = self.indicator_x + (target_x - self.indicator_x) * dt * 12
  end

  function ch:draw()
    -- Get theme colors with fallbacks
    local bg_color = theme.get_color('surface_variant', { 0.2, 0.2, 0.2, 1 })
    local border_color = theme.get_color('border', { 0.3, 0.3, 0.3, 1 })
    local primary_color = theme.get_color('primary', { 0.5, 0.3, 0.8, 1 })
    local text_primary = theme.get_color('text_primary', { 1, 1, 1, 1 })
    local text_secondary = theme.get_color('text_secondary', { 0.7, 0.7, 0.7, 1 })

    -- Draw background container using theme-configured superellipse
    local corner_radius = self:get_corner_radius()
    local smoothness = self:get_smoothness()
    local height = self:get_height()
    local segment_width = self:get_segment_width()
    local indicator_padding = self:get_indicator_padding() + 1

    utils.draw_superellipse(self.x, self.y, self.w, height, corner_radius,
      bg_color, border_color, 1, smoothness)

    -- Draw selected segment indicator
    if self.indicator_x then
      local indicator_color = primary_color
      local indicator_radius = math.max(0, corner_radius - 1)
      utils.draw_superellipse(self.x + self.indicator_x + indicator_padding,
        self.y + indicator_padding,
        segment_width - (indicator_padding * 2),
        height - (indicator_padding * 2),
        indicator_radius, indicator_color, nil, 0, smoothness)
    end

    -- Draw segment text
    for i, option in ipairs(self.options) do
      local seg_x = self.x + (i - 1) * segment_width
      local text_color = (i == self.selected) and { 1, 1, 1, 1 } or text_secondary

      utils.draw_centered_text(option.text, seg_x, self.y, segment_width, height,
        love.graphics.getFont(), text_color,
        theme.current.font.yoffset or 0)
    end
  end

  function ch:mouse_pressed(x, y, button)
    if button == 1 and utils.point_in_rect(x, y, self.x, self.y, self.w, self:get_height()) then
      local segment = math.floor((x - self.x) / self:get_segment_width()) + 1
      if segment >= 1 and segment <= #self.options then
        self:select(segment)
        return true
      end
    end
    return false
  end

  -- Initialize
  ch:rebuild()

  return ch
end

return chooser
