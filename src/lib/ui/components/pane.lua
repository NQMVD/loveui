-- Pane component (formerly Card) with layout engine
local pane = {}
local utils = require('lib.ui.utils')
local theme = require('lib.ui.theme')

function pane.new(x, y, w, h, layout_type)
  local p = {
    x = x or 0,
    y = y or 0,
    w = w or 200,
    h = h or 150,
    layout_type = layout_type or "free", -- "free", "vertical", "horizontal"
    visible = true,

    -- Container properties
    children = {},
    padding = nil, -- Will use theme default
    spacing = nil, -- Will use theme default

    -- Scrolling support
    scroll_y = 0,
    max_scroll_y = 0,
    scrollable = false,

    -- Background styling
    background_color = nil, -- Will use theme default
    border_color = nil,     -- Will use theme default
    corner_radius = nil,    -- Will use theme default

    -- Component type
    _type = "pane",
    _ui_id = nil,
  }

  function p:get_corner_radius()
    return self.corner_radius or theme.manager:get_config("pane.corner_radius", 12)
  end

  function p:get_smoothness()
    return theme.manager:get_config("pane.smoothness", 3.0)
  end

  function p:get_padding()
    return self.padding or theme.manager:get_config("pane.padding", 16)
  end

  function p:get_spacing()
    return self.spacing or theme.manager:get_config("global.spacing", 8)
  end
  
  function p:get_auto_size()
    return theme.manager:get_config("pane.auto_size", false)
  end

  function p:get_border_width()
    return theme.manager:get_config("pane.border_width", 1)
  end

  function p:get_background_color()
    return self.background_color or theme.manager:get_color('surface', { 0.1, 0.1, 0.1, 1 })
  end

  function p:get_border_color()
    return self.border_color or theme.manager:get_color('border', { 0.3, 0.3, 0.3, 1 })
  end

  function p:add_child(child, layout_options)
    layout_options = layout_options or {}

    local child_info = {
      component = child,
      layout = {
        x_offset = layout_options.x_offset or 0,
        y_offset = layout_options.y_offset or 0,
        fixed_width = layout_options.fixed_width,
        fixed_height = layout_options.fixed_height,
        fill_width = layout_options.fill_width or false,
        align = layout_options.align or "left",  -- "left", "center", "right" for horizontal
        valign = layout_options.valign or "top", -- "top", "center", "bottom" for vertical
      }
    }

    table.insert(self.children, child_info)
    self:update_layout()
    return child
  end

  function p:remove_child(child)
    for i, child_info in ipairs(self.children) do
      if child_info.component == child then
        table.remove(self.children, i)
        self:update_layout()
        return true
      end
    end
    return false
  end

  function p:clear_children()
    self.children = {}
    self:update_layout()
  end

  function p:update_layout()
    if #self.children == 0 then 
      if self:get_auto_size() then
        local padding = self:get_padding()
        self.w = padding * 2
        self.h = padding * 2
      end
      return 
    end

    local padding = self:get_padding()
    local spacing = self:get_spacing()
    local content_x = self.x + padding
    local content_y = self.y + padding - self.scroll_y
    local content_width = self.w - (padding * 2)
    local content_height = self.h - (padding * 2)

    if self.layout_type == "vertical" then
      self:layout_vertical(content_x, content_y, content_width, spacing)
    elseif self.layout_type == "horizontal" then
      self:layout_horizontal(content_x, content_y, content_height, spacing)
    else
      self:layout_free(content_x, content_y)
    end

    -- Auto-size pane to fit children if enabled
    if self:get_auto_size() then
      self:auto_size_to_children()
    end

    self:update_scroll_bounds()
  end
  
  function p:auto_size_to_children()
    if #self.children == 0 then return end
    
    local padding = self:get_padding()
    local spacing = self:get_spacing()
    local min_x, min_y = math.huge, math.huge
    local max_x, max_y = 0, 0
    
    -- Find bounds of all children
    for _, child_info in ipairs(self.children) do
      local child = child_info.component
      local child_w = child.get_width and child:get_width() or child.w or 0
      local child_h = child.get_height and child:get_height() or child.h or 0
      
      min_x = math.min(min_x, child.x)
      min_y = math.min(min_y, child.y)
      max_x = math.max(max_x, child.x + child_w)
      max_y = math.max(max_y, child.y + child_h)
    end
    
    -- Calculate required size
    local required_width = (max_x - self.x) + padding
    local required_height = (max_y - self.y) + padding
    
    self.w = math.max(self.w, required_width)
    self.h = math.max(self.h, required_height)
  end

  function p:layout_vertical(start_x, start_y, available_width, spacing)
    local current_y = start_y

    for i, child_info in ipairs(self.children) do
      local child = child_info.component
      local layout = child_info.layout

      -- Calculate width
      local child_width
      if layout.fixed_width then
        child_width = layout.fixed_width
      elseif layout.fill_width then
        child_width = available_width
      elseif child.get_width then
        child_width = child:get_width()
      else
        child_width = child.w or 100
      end

      -- Calculate height
      local child_height
      if layout.fixed_height then
        child_height = layout.fixed_height
      elseif child.get_height then
        child_height = child:get_height()
      else
        child_height = child.h or 30
      end

      -- Calculate x position based on alignment
      local child_x = start_x + layout.x_offset
      if layout.align == "center" then
        child_x = start_x + (available_width - child_width) / 2
      elseif layout.align == "right" then
        child_x = start_x + available_width - child_width
      end

      -- Set position
      local child_y = current_y + layout.y_offset
      if child.set_position then
        child:set_position(child_x, child_y)
      else
        child.x = child_x
        child.y = child_y
      end

      -- Set size if supported
      if child.set_size then
        child:set_size(child_width, child_height)
      else
        child.w = child_width
        child.h = child_height
      end

       current_y = current_y + child_height
       if i < #self.children then
         current_y = current_y + spacing
       end    end
  end

  function p:layout_horizontal(start_x, start_y, available_height, spacing)
    local current_x = start_x

    for i, child_info in ipairs(self.children) do
      local child = child_info.component
      local layout = child_info.layout

      -- Calculate width
      local child_width
      if layout.fixed_width then
        child_width = layout.fixed_width
      elseif child.get_width then
        child_width = child:get_width()
      else
        child_width = child.w or 100
      end

      -- Calculate height
      local child_height
      if layout.fixed_height then
        child_height = layout.fixed_height
      elseif layout.fill_width then -- fill_width in horizontal layout affects height
        child_height = available_height
      elseif child.get_height then
        child_height = child:get_height()
      else
        child_height = child.h or 30
      end

      -- Calculate y position based on vertical alignment
      local child_y = start_y + layout.y_offset
      if layout.valign == "center" then
        child_y = start_y + (available_height - child_height) / 2
      elseif layout.valign == "bottom" then
        child_y = start_y + available_height - child_height
      end

      -- Set position
      local child_x = current_x + layout.x_offset
      if child.set_position then
        child:set_position(child_x, child_y)
      else
        child.x = child_x
        child.y = child_y
      end

      -- Set size if supported
      if child.set_size then
        child:set_size(child_width, child_height)
      else
        child.w = child_width
        child.h = child_height
      end

       current_x = current_x + child_width
       if i < #self.children then
         current_x = current_x + spacing
       end    end
  end

  function p:layout_free(base_x, base_y)
    for i, child_info in ipairs(self.children) do
      local child = child_info.component
      local layout = child_info.layout

      local child_x = base_x + layout.x_offset
      local child_y = base_y + layout.y_offset

      if child.set_position then
        child:set_position(child_x, child_y)
      else
        child.x = child_x
        child.y = child_y
      end

      -- Apply fixed sizes if specified
      if layout.fixed_width or layout.fixed_height then
        local w = layout.fixed_width or child.w
        local h = layout.fixed_height or child.h
        if child.set_size then
          child:set_size(w, h)
        else
          child.w = w
          child.h = h
        end
      end
    end
  end

  function p:update_scroll_bounds()
    if not self.scrollable then return end

    -- Calculate content height
    local max_y = 0
    for _, child_info in ipairs(self.children) do
      local child = child_info.component
      local child_bottom = child.y + (child.h or 0)
      max_y = math.max(max_y, child_bottom)
    end

    local padding = self:get_padding()
    local content_height = max_y - (self.y + padding)
    local available_height = self.h - (padding * 2)

    self.max_scroll_y = math.max(0, content_height - available_height)
  end

  function p:scroll(delta_y)
    if not self.scrollable then return end

    self.scroll_y = math.max(0, math.min(self.max_scroll_y, self.scroll_y + delta_y))
    self:update_layout()
  end

  function p:update(dt)
    -- Update all children
    for _, child_info in ipairs(self.children) do
      local child = child_info.component
      if child.update then
        child:update(dt)
      end
    end
  end

  function p:draw()
    if not self.visible then return end

    -- Draw background
    local bg_color = self:get_background_color()
    local border_color = self:get_border_color()
    local corner_radius = self:get_corner_radius()
    local smoothness = self:get_smoothness()
    local border_width = self:get_border_width()

    utils.draw_superellipse(self.x, self.y, self.w, self.h, corner_radius,
      bg_color, border_color, border_width, smoothness)

    -- Setup clipping for scrollable content
    if self.scrollable then
      local padding = self:get_padding()
      love.graphics.push()
      love.graphics.setScissor(
        self.x + padding,
        self.y + padding,
        self.w - padding * 2,
        self.h - padding * 2
      )
    end

    -- Draw children
    for _, child_info in ipairs(self.children) do
      local child = child_info.component
      if child.draw and child.visible ~= false then
        child:draw()
      end
    end

    if self.scrollable then
      love.graphics.setScissor()
      love.graphics.pop()
    end
  end

  function p:mouse_pressed(x, y, button)
    -- Check children first (reverse order for proper hit testing)
    for i = #self.children, 1, -1 do
      local child = self.children[i].component
      if child.mouse_pressed and child.visible ~= false then
        if child:mouse_pressed(x, y, button) then
          return true
        end
      end
    end

    -- Check if click is within pane bounds
    return utils.point_in_rect(x, y, self.x, self.y, self.w, self.h)
  end

  function p:mouse_released(x, y, button)
    for _, child_info in ipairs(self.children) do
      local child = child_info.component
      if child.mouse_released and child.visible ~= false then
        child:mouse_released(x, y, button)
      end
    end
  end

  function p:mouse_moved(x, y, dx, dy)
    for _, child_info in ipairs(self.children) do
      local child = child_info.component
      if child.mouse_moved and child.visible ~= false then
        child:mouse_moved(x, y, dx, dy)
      end
    end
  end

  -- Utility methods
  function p:set_position(x, y)
    self.x = x
    self.y = y
    self:update_layout()
  end

  function p:set_size(w, h)
    self.w = w
    self.h = h
    self:update_layout()
  end

  function p:set_layout_type(layout_type)
    self.layout_type = layout_type
    self:update_layout()
  end

  function p:set_scrollable(scrollable)
    self.scrollable = scrollable
    if scrollable then
      self:update_scroll_bounds()
    end
  end

  function p:set_visible(visible)
    self.visible = visible
  end

  return p
end

return pane
