-- Centralized UI state management for LoveUI
local state = {}

-- UI Instance state tracker
local UIState = {}
UIState.__index = UIState

function UIState.new()
  local s = setmetatable({}, UIState)
  s.components = {}
  s.component_counter = 0
  s.theme_manager = nil
  s.settings = nil
  s.event_handlers = {}
  s.update_queue = {}
  s.focus_stack = {}
  s.mouse_capture = nil
  s.keyboard_capture = nil
  return s
end

function UIState:register_component(component)
  self.component_counter = self.component_counter + 1
  local id = "component_" .. self.component_counter
  component._ui_id = id
  self.components[id] = component
  return id
end

function UIState:unregister_component(component_id)
  self.components[component_id] = nil
end

function UIState:get_component(component_id)
  return self.components[component_id]
end

function UIState:get_all_components()
  return self.components
end

function UIState:set_theme_manager(theme_manager)
  self.theme_manager = theme_manager
end

function UIState:get_theme_manager()
  return self.theme_manager
end

function UIState:set_settings(settings)
  self.settings = settings
end

function UIState:get_settings()
  return self.settings
end

-- Event handling
function UIState:add_event_handler(event_type, handler)
  if not self.event_handlers[event_type] then
    self.event_handlers[event_type] = {}
  end
  table.insert(self.event_handlers[event_type], handler)
end

function UIState:remove_event_handler(event_type, handler)
  if self.event_handlers[event_type] then
    for i, h in ipairs(self.event_handlers[event_type]) do
      if h == handler then
        table.remove(self.event_handlers[event_type], i)
        break
      end
    end
  end
end

function UIState:emit_event(event_type, ...)
  if self.event_handlers[event_type] then
    for _, handler in ipairs(self.event_handlers[event_type]) do
      handler(...)
    end
  end
end

-- Update queue for batching operations
function UIState:queue_update(component_id, update_fn)
  table.insert(self.update_queue, { component_id = component_id, update_fn = update_fn })
end

function UIState:process_update_queue()
  for _, update_item in ipairs(self.update_queue) do
    local component = self.components[update_item.component_id]
    if component then
      update_item.update_fn(component)
    end
  end
  self.update_queue = {}
end

-- Focus management
function UIState:push_focus(component)
  table.insert(self.focus_stack, component)
end

function UIState:pop_focus()
  return table.remove(self.focus_stack)
end

function UIState:get_focused_component()
  return self.focus_stack[#self.focus_stack]
end

function UIState:clear_focus()
  self.focus_stack = {}
end

-- Mouse and keyboard capture
function UIState:capture_mouse(component)
  self.mouse_capture = component
end

function UIState:release_mouse_capture()
  self.mouse_capture = nil
end

function UIState:get_mouse_capture()
  return self.mouse_capture
end

function UIState:capture_keyboard(component)
  self.keyboard_capture = component
end

function UIState:release_keyboard_capture()
  self.keyboard_capture = nil
end

function UIState:get_keyboard_capture()
  return self.keyboard_capture
end

-- Component lifecycle management
function UIState:update_all_components(dt)
  for _, component in pairs(self.components) do
    if component.update then
      component:update(dt)
    end
  end
  self:process_update_queue()
end

function UIState:draw_all_components()
  -- Draw components in registration order (or implement z-order later)
  for _, component in pairs(self.components) do
    if component.draw and component.visible ~= false then
      component:draw()
    end
  end
end

-- Mouse event distribution
function UIState:mouse_pressed(x, y, button)
  -- First check if mouse is captured
  if self.mouse_capture then
    if self.mouse_capture.mouse_pressed then
      return self.mouse_capture:mouse_pressed(x, y, button)
    end
    return false
  end
  
  -- Check components in reverse order (last drawn = first hit)
  local components_list = {}
  for _, component in pairs(self.components) do
    table.insert(components_list, component)
  end
  
  for i = #components_list, 1, -1 do
    local component = components_list[i]
    if component.mouse_pressed and component.visible ~= false then
      if component:mouse_pressed(x, y, button) then
        return true
      end
    end
  end
  
  return false
end

function UIState:mouse_released(x, y, button)
  if self.mouse_capture then
    if self.mouse_capture.mouse_released then
      return self.mouse_capture:mouse_released(x, y, button)
    end
    return false
  end
  
  -- Distribute to all components
  for _, component in pairs(self.components) do
    if component.mouse_released and component.visible ~= false then
      component:mouse_released(x, y, button)
    end
  end
end

function UIState:mouse_moved(x, y, dx, dy)
  if self.mouse_capture then
    if self.mouse_capture.mouse_moved then
      return self.mouse_capture:mouse_moved(x, y, dx, dy)
    end
    return false
  end
  
  -- Distribute to all components
  for _, component in pairs(self.components) do
    if component.mouse_moved and component.visible ~= false then
      component:mouse_moved(x, y, dx, dy)
    end
  end
end

-- Keyboard event distribution
function UIState:key_pressed(key, scancode, isrepeat)
  if self.keyboard_capture then
    if self.keyboard_capture.key_pressed then
      return self.keyboard_capture:key_pressed(key, scancode, isrepeat)
    end
    return false
  end
  
  local focused = self:get_focused_component()
  if focused and focused.key_pressed then
    return focused:key_pressed(key, scancode, isrepeat)
  end
  
  return false
end

function UIState:key_released(key, scancode)
  if self.keyboard_capture then
    if self.keyboard_capture.key_released then
      return self.keyboard_capture:key_released(key, scancode)
    end
    return false
  end
  
  local focused = self:get_focused_component()
  if focused and focused.key_released then
    return focused:key_released(key, scancode)
  end
  
  return false
end

function UIState:text_input(text)
  if self.keyboard_capture then
    if self.keyboard_capture.text_input then
      return self.keyboard_capture:text_input(text)
    end
    return false
  end
  
  local focused = self:get_focused_component()
  if focused and focused.text_input then
    return focused:text_input(text)
  end
  
  return false
end

-- Global state instance
local global_ui_state = UIState.new()

-- Export
state.UIState = UIState
state.global = global_ui_state

return state