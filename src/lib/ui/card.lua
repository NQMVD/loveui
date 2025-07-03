local card = {}
local utils = require('lib.ui.utils')
local theme = require('lib.ui.theme')

function card.new(x, y, w, h, style)
  style = style or "container"

  local c = {
    x = x,
    y = y,
    w = w or 200,
    h = h or 120,
    style = style,
    children = {},
    background_color = nil,
    border_color = nil,
    -- Store overrides, use theme values dynamically
    _padding_override = nil,
    _corner_radius_override = nil,
    _smoothness_override = nil,
    _border_width_override = nil,
  }

  function c:set_colors(bg, border)
    self.background_color = bg
    self.border_color = border
  end

  function c:set_corner_style(radius, smoothness)
    self._corner_radius_override = radius
    self._smoothness_override = smoothness
  end

  function c:set_padding(padding)
    self._padding_override = padding
  end

  function c:get_padding()
    return self._padding_override or theme.get_style('card', 'padding', 16)
  end

  function c:get_corner_radius()
    return self._corner_radius_override or theme.get_style('card', 'corner_radius', 25)
  end

  function c:get_smoothness()
    return self._smoothness_override or theme.get_style('card', 'smoothness', 3.0)
  end

  function c:get_border_width()
    return self._border_width_override or theme.get_style('card', 'border_width', 1)
  end

  function c:add_child(child, rel_x, rel_y)
    rel_x = rel_x or self:get_padding()
    rel_y = rel_y or self:get_padding()

    table.insert(self.children, {
      element = child,
      x = rel_x,
      y = rel_y
    })
  end

  function c:add_text(text, rel_x, rel_y, font, color)
    local padding = self:get_padding()
    rel_x = rel_x or 0
    rel_y = rel_y or 0

    table.insert(self.children, {
      type = "text",
      text = text,
      x = padding + rel_x,
      y = padding + rel_y,
      font = font or love.graphics.getFont(),
      color = color or theme.get_color('text_primary', { 1, 1, 1, 1 })
    })
  end

  function c:draw()
    local bg_color = self.background_color or theme.get_color('surface', { 0.15, 0.15, 0.15, 1 })
    local border_color = self.border_color or theme.get_color('border', { 0.3, 0.3, 0.3, 1 })

    -- Use theme-configured superellipse for cards
    utils.draw_superellipse(self.x, self.y, self.w, self.h, self:get_corner_radius(),
      bg_color, border_color, self:get_border_width(), self:get_smoothness())

    -- Draw children
    for _, child in ipairs(self.children) do
      love.graphics.push()
      love.graphics.translate(self.x + child.x, self.y + child.y)

      if child.type == "text" then
        local text_y_offset = theme.get_style('card', 'text_y_offset', 0)
        love.graphics.setFont(child.font)
        love.graphics.setColor(child.color)
        love.graphics.printf(child.text, 0, text_y_offset, self.w - 2 * self:get_padding())
      elseif child.element and child.element.draw then
        child.element:draw()
      end

      love.graphics.pop()
    end
  end

  function c:update(dt)
    for _, child in ipairs(self.children) do
      if child.element and child.element.update then
        child.element:update(dt)
      end
    end
  end

  function c:mouse_pressed(x, y, button)
    for i = #self.children, 1, -1 do
      local child = self.children[i]
      if child.element and child.element.mouse_pressed then
        local rel_x = x - (self.x + child.x)
        local rel_y = y - (self.y + child.y)
        if child.element:mouse_pressed(rel_x, rel_y, button) then
          return true
        end
      end
    end
    return false
  end

  return c
end

return card
