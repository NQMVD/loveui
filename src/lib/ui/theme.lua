-- New Theme system for LoveUI
-- Integrates Configuration and Color Palette systems
local theme = {}
local config = require('lib.ui.config')
local palette = require('lib.ui.palette')
local utils = require('lib.ui.utils')

-- Theme structure
local Theme = {}
Theme.__index = Theme

function Theme.new(name, color_palette, configuration, font_config)
  local t = setmetatable({}, Theme)
  t.name = name
  t.palette = color_palette
  t.config = configuration
  t.font_config = font_config or {}
  t.fonts = nil -- Will be loaded on demand
  t.current_font = nil
  return t
end

function Theme:get_color(color_name, fallback)
  return self.palette:get(color_name, fallback)
end

function Theme:get_config(path, fallback)
  return self.config:get(path, fallback)
end

function Theme:set_config(path, value)
  self.config:set(path, value)
end

function Theme:validate()
  -- Validate both palette and configuration
  if not self.config:is_validated() then
    self.config:validate()
  end
  return true
end

function Theme:load_fonts()
  if self.fonts then
    return self.fonts -- Already loaded
  end

  local font_names = self.config:get("fonts.names", {})
  local font_sizes = self.config:get("fonts.sizes", { normal = 16, small = 14, big = 20 })

  self.fonts = utils.load_fonts(font_names, font_sizes)

  -- Set default font
  local default_name = self.config:get("fonts.default_name", "berkeley")
  local default_size = self.config:get("fonts.default_size", "small")

  if self.fonts and self.fonts.highdpi and self.fonts.highdpi[default_name] then
    self.current_font = self.fonts.highdpi[default_name][default_size]
    if self.current_font and self.current_font.actual_font then
      love.graphics.setFont(self.current_font.actual_font)
    end
  end

  return self.fonts
end

function Theme:set_font(name, size, highdpi)
  if not self.fonts then
    self:load_fonts()
  end

  size = size or "small"
  highdpi = highdpi ~= false -- default to true

  local font_collection = highdpi and self.fonts.highdpi or self.fonts.lowdpi
  if font_collection and font_collection[name] and font_collection[name][size] then
    self.current_font = font_collection[name][size]
    love.graphics.setFont(self.current_font.actual_font)
  end
end

function Theme:get_current_font()
  if not self.current_font and not self.fonts then
    self:load_fonts()
  end
  return self.current_font
end

-- Theme manager for handling multiple themes and runtime switching
local ThemeManager = {}
ThemeManager.__index = ThemeManager

function ThemeManager.new()
  local tm = setmetatable({}, ThemeManager)
  tm.themes = {}
  tm.current_theme = nil
  return tm
end

function ThemeManager:register_theme(theme)
  theme:validate()
  self.themes[theme.name] = theme
end

function ThemeManager:get_theme(name)
  return self.themes[name]
end

function ThemeManager:set_current_theme(theme_name)
  local theme_obj = self.themes[theme_name]
  if not theme_obj then
    error("Theme '" .. theme_name .. "' not found")
  end

  self.current_theme = theme_obj
  theme_obj:load_fonts() -- Ensure fonts are loaded
  return theme_obj
end

function ThemeManager:get_current_theme()
  return self.current_theme
end

-- Convenience functions that delegate to current theme
function ThemeManager:get_color(color_name, fallback)
  if not self.current_theme then
    return fallback or { 1, 1, 1, 1 }
  end
  return self.current_theme:get_color(color_name, fallback)
end

function ThemeManager:get_config(path, fallback)
  if not self.current_theme then
    return fallback
  end
  return self.current_theme:get_config(path, fallback)
end

function ThemeManager:set_font(name, size, highdpi)
  if self.current_theme then
    self.current_theme:set_font(name, size, highdpi)
  end
end

function ThemeManager:get_current_font()
  if not self.current_theme then
    return nil
  end
  return self.current_theme:get_current_font()
end

-- Factory functions for creating built-in themes
function theme.create_dark_default()
  local dark_palette = palette.create_dark_palette()
  local default_config = config.create_default_configuration()
  return Theme.new("dark_default", dark_palette, default_config)
end

function theme.create_dark_rounded()
  local dark_palette = palette.create_dark_palette()
  local rounded_config = config.create_rounded_configuration()
  return Theme.new("dark_rounded", dark_palette, rounded_config)
end

function theme.create_dark_sharp()
  local dark_palette = palette.create_dark_palette()
  local sharp_config = config.create_sharp_configuration()
  return Theme.new("dark_sharp", dark_palette, sharp_config)
end

function theme.create_light_default()
  local light_palette = palette.create_light_palette()
  local default_config = config.create_default_configuration()
  return Theme.new("light_default", light_palette, default_config)
end

function theme.create_light_rounded()
  local light_palette = palette.create_light_palette()
  local rounded_config = config.create_rounded_configuration()
  return Theme.new("light_rounded", light_palette, rounded_config)
end

function theme.create_light_sharp()
  local light_palette = palette.create_light_palette()
  local sharp_config = config.create_sharp_configuration()
  return Theme.new("light_sharp", light_palette, sharp_config)
end

-- Global theme manager instance
local global_theme_manager = ThemeManager.new()

-- Register built-in themes
global_theme_manager:register_theme(theme.create_dark_default())
global_theme_manager:register_theme(theme.create_dark_rounded())
global_theme_manager:register_theme(theme.create_dark_sharp())
global_theme_manager:register_theme(theme.create_light_default())
global_theme_manager:register_theme(theme.create_light_rounded())
global_theme_manager:register_theme(theme.create_light_sharp())

-- Set default theme
global_theme_manager:set_current_theme("dark_default")

-- Export the global theme manager as the main theme interface
theme.manager = global_theme_manager
theme.Theme = Theme
theme.ThemeManager = ThemeManager

-- Legacy compatibility functions
function theme.get_color(color_name, fallback)
  return global_theme_manager:get_color(color_name, fallback)
end

function theme.get_style(element_type, property, fallback)
  return global_theme_manager:get_config(element_type .. "." .. property, fallback)
end

function theme.set_font(name, size, highdpi)
  global_theme_manager:set_font(name, size, highdpi)
end

function theme.set(theme_obj)
  -- For compatibility with old API
  if type(theme_obj) == "string" then
    global_theme_manager:set_current_theme(theme_obj)
  elseif theme_obj and theme_obj.name then
    global_theme_manager:register_theme(theme_obj)
    global_theme_manager:set_current_theme(theme_obj.name)
  end
end

return theme
