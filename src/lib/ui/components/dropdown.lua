-- Dropdown component
local dropdown = {}
local utils = require('lib.ui.utils')
local theme = require('lib.ui.theme')

function dropdown.new(x, y, w, options, placeholder)
  local dd = {
    x = x or 0,
    y = y or 0,
    w = w or 200,
    options = options or {},
    placeholder = placeholder or "Select an option...",
    selected_index = nil,
    visible = true,
    enabled = true,

    -- State
    is_open = false,
    hovered = false,
    hovered_item = nil,

    -- Callbacks
    onchange = nil,
    onopen = nil,
    onclose = nil,

    -- Component type
    _type = "dropdown",
    _ui_id = nil,
  }

  function dd:get_height()
    return theme.manager:get_config("dropdown.height", 36)
  end

  function dd:get_corner_radius()
    return theme.manager:get_config("dropdown.corner_radius", 8)
  end

  function dd:get_smoothness()
    return theme.manager:get_config("dropdown.smoothness", 4.0)
  end

  function dd:get_max_visible_items()
    return theme.manager:get_config("dropdown.max_visible_items", 6)
  end

  function dd:get_item_height()
    return theme.manager:get_config("dropdown.item_height", 32)
  end

  function dd:get_colors()
    return {
      background = theme.manager:get_color('surface', { 0.1, 0.1, 0.1, 1 }),
      background_hover = theme.manager:get_color('surface_variant', { 0.15, 0.15, 0.15, 1 }),
      border = theme.manager:get_color('border', { 0.3, 0.3, 0.3, 1 }),
      text = theme.manager:get_color('text_primary', { 1, 1, 1, 1 }),
      text_placeholder = theme.manager:get_color('text_muted', { 0.6, 0.6, 0.6, 1 }),
      dropdown_bg = theme.manager:get_color('surface_container', { 0.08, 0.08, 0.08, 1 }),
      item_hover = theme.manager:get_color('primary', { 0.5, 0.3, 0.8, 0.3 }),
      item_selected = theme.manager:get_color('primary', { 0.5, 0.3, 0.8, 0.5 }),
      arrow = theme.manager:get_color('text_secondary', { 0.7, 0.7, 0.7, 1 }),
    }
  end

  function dd:get_dropdown_height()
    local visible_items = math.min(#self.options, self:get_max_visible_items())
    return visible_items * self:get_item_height()
  end

  function dd:get_selected_text()
    if self.selected_index and self.options[self.selected_index] then
      return self.options[self.selected_index]
    end
    return self.placeholder
  end

  function dd:is_placeholder_shown()
    return self.selected_index == nil
  end

  function dd:set_selected_index(index)
    local old_index = self.selected_index

    if index and index >= 1 and index <= #self.options then
      self.selected_index = index
    else
      self.selected_index = nil
    end

    if self.onchange and old_index ~= self.selected_index then
      self.onchange(self, self.selected_index, self:get_selected_text())
    end
  end

  function dd:get_selected_option()
    if self.selected_index then
      return self.options[self.selected_index]
    end
    return nil
  end

  function dd:set_options(options)
    self.options = options or {}
    if self.selected_index and self.selected_index > #self.options then
      self.selected_index = nil
    end
  end

  function dd:open()
    if not self.is_open then
      self.is_open = true
      if self.onopen then
        self.onopen(self)
      end
    end
  end

  function dd:close()
    if self.is_open then
      self.is_open = false
      self.hovered_item = nil
      if self.onclose then
        self.onclose(self)
      end
    end
  end

  function dd:toggle()
    if self.is_open then
      self:close()
    else
      self:open()
    end
  end

  function dd:update(dt)
    if not self.enabled then return end

    local mx, my = love.mouse.getPosition()
    local height = self:get_height()

    -- Check if hovering over main dropdown button
    self.hovered = utils.point_in_rect(mx, my, self.x, self.y, self.w, height)

    -- Check if hovering over dropdown items
    if self.is_open then
      local dropdown_y = self.y + height
      local dropdown_height = self:get_dropdown_height()
      local item_height = self:get_item_height()

      if utils.point_in_rect(mx, my, self.x, dropdown_y, self.w, dropdown_height) then
        local relative_y = my - dropdown_y
        local item_index = math.floor(relative_y / item_height) + 1

        if item_index >= 1 and item_index <= #self.options then
          self.hovered_item = item_index
        else
          self.hovered_item = nil
        end
      else
        self.hovered_item = nil
      end
    end
  end

  function dd:draw()
    if not self.visible then return end

    local colors = self:get_colors()
    local height = self:get_height()
    local corner_radius = self:get_corner_radius()
    local smoothness = self:get_smoothness()

    -- Draw main dropdown button
    local bg_color = self.hovered and colors.background_hover or colors.background
    utils.draw_superellipse(self.x, self.y, self.w, height, corner_radius,
      bg_color, colors.border, 1, smoothness)

    -- Draw dropdown text
    local font = theme.manager:get_current_font()
    if font and font.actual_font then
      local text = self:get_selected_text()
      local text_color = self:is_placeholder_shown() and colors.text_placeholder or colors.text
      local text_x = self.x + 12
      local text_y = self.y + (height - font.actual_font:getHeight()) / 2

      love.graphics.setColor(text_color)
      love.graphics.setFont(font.actual_font)
      love.graphics.print(text, text_x, text_y)
    end

    -- Draw dropdown arrow
    local arrow_size = 8
    local arrow_x = self.x + self.w - arrow_size - 12
    local arrow_y = self.y + height / 2

    love.graphics.setColor(colors.arrow)
    if self.is_open then
      -- Up arrow
      love.graphics.polygon("fill",
        arrow_x, arrow_y + arrow_size / 2,
        arrow_x + arrow_size, arrow_y + arrow_size / 2,
        arrow_x + arrow_size / 2, arrow_y - arrow_size / 2
      )
    else
      -- Down arrow
      love.graphics.polygon("fill",
        arrow_x, arrow_y - arrow_size / 2,
        arrow_x + arrow_size, arrow_y - arrow_size / 2,
        arrow_x + arrow_size / 2, arrow_y + arrow_size / 2
      )
    end

    -- Draw dropdown menu
    if self.is_open then
      local dropdown_y = self.y + height
      local dropdown_height = self:get_dropdown_height()
      local item_height = self:get_item_height()

      -- Draw dropdown background
      utils.draw_superellipse(self.x, dropdown_y, self.w, dropdown_height, corner_radius,
        colors.dropdown_bg, colors.border, 1, smoothness)

      -- Draw items
      for i, option in ipairs(self.options) do
        if i <= self:get_max_visible_items() then
          local item_y = dropdown_y + (i - 1) * item_height

          -- Draw item background if hovered or selected
          if i == self.hovered_item then
            utils.draw_superellipse(self.x + 2, item_y + 1, self.w - 4, item_height - 2,
              corner_radius - 2, colors.item_hover, { 0, 0, 0, 0 }, 0, smoothness)
          elseif i == self.selected_index then
            utils.draw_superellipse(self.x + 2, item_y + 1, self.w - 4, item_height - 2,
              corner_radius - 2, colors.item_selected, { 0, 0, 0, 0 }, 0, smoothness)
          end

          -- Draw item text
          if font and font.actual_font then
            local item_text_x = self.x + 12
            local item_text_y = item_y + (item_height - font.actual_font:getHeight()) / 2

            love.graphics.setColor(colors.text)
            love.graphics.setFont(font.actual_font)
            love.graphics.print(option, item_text_x, item_text_y)
          end
        end
      end
    end
  end

  function dd:mouse_pressed(x, y, button)
    if button == 1 and self.enabled and self.visible then
      local height = self:get_height()

      -- Check main dropdown button
      if utils.point_in_rect(x, y, self.x, self.y, self.w, height) then
        self:toggle()
        return true
      end

      -- Check dropdown items
      if self.is_open then
        local dropdown_y = self.y + height
        local dropdown_height = self:get_dropdown_height()
        local item_height = self:get_item_height()

        if utils.point_in_rect(x, y, self.x, dropdown_y, self.w, dropdown_height) then
          local relative_y = y - dropdown_y
          local clicked_item = math.floor(relative_y / item_height) + 1

          if clicked_item >= 1 and clicked_item <= #self.options then
            self:set_selected_index(clicked_item)
            self:close()
          end
          return true
        else
          -- Clicked outside dropdown - close it
          self:close()
        end
      end
    end

    return false
  end

  function dd:mouse_released(x, y, button)
    -- Override if needed
  end

  function dd:mouse_moved(x, y, dx, dy)
    -- Handled in update
  end

  function dd:set_position(x, y)
    self.x = x
    self.y = y
  end

  function dd:set_size(w, h)
    self.w = w
    -- Height is fixed based on configuration
  end

  function dd:set_enabled(enabled)
    self.enabled = enabled
    if not enabled then
      self:close()
    end
  end

  function dd:set_visible(visible)
    self.visible = visible
    if not visible then
      self:close()
    end
  end

  function dd:get_width()
    return self.w
  end

  function dd:get_total_height()
    if self.is_open then
      return self:get_height() + self:get_dropdown_height()
    else
      return self:get_height()
    end
  end

  return dd
end

return dropdown
