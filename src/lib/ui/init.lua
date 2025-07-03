-- Modern UI Library for Love2D - New Architecture
local ui = {
  _VERSION = "1.0.0",
  _DESCRIPTION = "Modern Configurable UI library for Love2D",
}

-- Import new architecture modules
ui.config = require('lib.ui.config')
ui.palette = require('lib.ui.palette')
ui.theme = require('lib.ui.theme')
ui.state = require('lib.ui.state')
ui.utils = require('lib.ui.utils')

-- Component modules will be loaded on demand
local component_modules = {
  button = 'lib.ui.components.button',
  pane = 'lib.ui.components.pane',
  chooser = 'lib.ui.components.chooser',
  slider = 'lib.ui.components.slider',
  checkbox = 'lib.ui.components.checkbox',
  dropdown = 'lib.ui.components.dropdown',
  text_input = 'lib.ui.components.text_input',
  text = 'lib.ui.components.text',
}

-- Lazy loading of components
local loaded_components = {}
local function load_component(name)
  if not loaded_components[name] then
    loaded_components[name] = require(component_modules[name])
  end
  return loaded_components[name]
end

-- Initialize UI system
function ui.init(theme_name, settings)
  -- Initialize settings
  local ui_settings = ui.config.Settings.new(settings)
  ui.state.global:set_settings(ui_settings)

  -- Initialize theme system
  ui.state.global:set_theme_manager(ui.theme.manager)

  -- Set initial theme
  theme_name = theme_name or "dark_default"
  ui.theme.manager:set_current_theme(theme_name)

  return ui.state.global
end

-- Get current UI state
function ui.get_state()
  return ui.state.global
end

-- Theme management
function ui.set_theme(theme_name)
  ui.theme.manager:set_current_theme(theme_name)
end

function ui.get_theme()
  return ui.theme.manager:get_current_theme()
end

function ui.get_available_themes()
  local themes = {}
  for name, _ in pairs(ui.theme.manager.themes) do
    table.insert(themes, name)
  end
  return themes
end

-- Component factory functions
function ui.create_button(text, x, y, w, h, style)
  local button_module = load_component('button')
  local button = button_module.new(text, x, y, w, h, style)
  ui.state.global:register_component(button)
  return button
end

function ui.create_pane(x, y, w, h, layout_type)
  local pane_module = load_component('pane')
  local pane = pane_module.new(x, y, w, h, layout_type)
  ui.state.global:register_component(pane)
  return pane
end

function ui.create_chooser(x, y, options, selected_index)
  local chooser_module = load_component('chooser')
  local chooser = chooser_module.new(x, y, options, selected_index)
  ui.state.global:register_component(chooser)
  return chooser
end

function ui.create_slider(x, y, w, min_val, max_val, initial_val, precision_mode)
  local slider_module = load_component('slider')
  local slider = slider_module.new(x, y, w, min_val, max_val, initial_val, precision_mode)
  ui.state.global:register_component(slider)
  return slider
end

function ui.create_checkbox(x, y, label, initial_checked)
  local checkbox_module = load_component('checkbox')
  local checkbox = checkbox_module.new(x, y, label, initial_checked)
  ui.state.global:register_component(checkbox)
  return checkbox
end

function ui.create_dropdown(x, y, w, options, placeholder)
  local dropdown_module = load_component('dropdown')
  local dropdown = dropdown_module.new(x, y, w, options, placeholder)
  ui.state.global:register_component(dropdown)
  return dropdown
end

function ui.create_text_input(x, y, w, placeholder, button_text)
  local text_input_module = load_component('text_input')
  local text_input = text_input_module.new(x, y, w, placeholder, button_text)
  ui.state.global:register_component(text_input)
  return text_input
end

function ui.create_text(x, y, w, text_content, font_size, color_name)
  local text_module = load_component('text')
  local text_comp = text_module.new(x, y, w, text_content, font_size, color_name)
  ui.state.global:register_component(text_comp)
  return text_comp
end

-- Global update and draw functions
function ui.update(dt)
  ui.state.global:update_all_components(dt)
end

function ui.draw()
  ui.state.global:draw_all_components()
end

-- Event forwarding
function ui.mouse_pressed(x, y, button)
  return ui.state.global:mouse_pressed(x, y, button)
end

function ui.mouse_released(x, y, button)
  return ui.state.global:mouse_released(x, y, button)
end

function ui.mouse_moved(x, y, dx, dy)
  return ui.state.global:mouse_moved(x, y, dx, dy)
end

function ui.key_pressed(key, scancode, isrepeat)
  return ui.state.global:key_pressed(key, scancode, isrepeat)
end

function ui.key_released(key, scancode)
  return ui.state.global:key_released(key, scancode)
end

function ui.text_input(text)
  return ui.state.global:text_input(text)
end

-- Configuration access
function ui.get_config(path, fallback)
  return ui.theme.manager:get_config(path, fallback)
end

function ui.set_config(path, value)
  local current_theme = ui.theme.manager:get_current_theme()
  if current_theme then
    current_theme:set_config(path, value)
  end
end

function ui.get_color(color_name, fallback)
  return ui.theme.manager:get_color(color_name, fallback)
end

-- Font management
function ui.set_font(name, size, highdpi)
  ui.theme.manager:set_font(name, size, highdpi)
end

function ui.get_current_font()
  return ui.theme.manager:get_current_font()
end

-- Legacy compatibility (for gradual migration)
function ui.create_card(x, y, w, h, style)
  return ui.create_pane(x, y, w, h, nil) -- Maps to pane
end

-- Cleanup function
function ui.cleanup()
  ui.state.global = ui.state.UIState.new()
end

return ui
