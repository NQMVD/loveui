-- Color Palette system for LoveUI
-- Replaces the old "color themes" with proper color palettes
local palette = {}

-- Palette structure
local Palette = {}
Palette.__index = Palette

function Palette.new(name, colors)
  local p = setmetatable({}, Palette)
  p.name = name
  p.colors = colors or {}
  return p
end

function Palette:get(color_name, fallback)
  return self.colors[color_name] or fallback or { 1, 1, 1, 1 }
end

function Palette:set(color_name, color_value)
  self.colors[color_name] = color_value
end

function Palette:has(color_name)
  return self.colors[color_name] ~= nil
end

-- Helper function to convert HSV to RGB
local function hsv_to_rgb(h, s, v)
  local c = v * s
  local x = c * (1 - math.abs((h / 60) % 2 - 1))
  local m = v - c

  local r, g, b
  if h < 60 then
    r, g, b = c, x, 0
  elseif h < 120 then
    r, g, b = x, c, 0
  elseif h < 180 then
    r, g, b = 0, c, x
  elseif h < 240 then
    r, g, b = 0, x, c
  elseif h < 300 then
    r, g, b = x, 0, c
  else
    r, g, b = c, 0, x
  end

  return (r + m), (g + m), (b + m)
end

-- hex to RGB conversion
local function hex_to_rgb(hex)
  return
      tonumber("0x" .. hex:sub(2, 3)) / 255,
      tonumber("0x" .. hex:sub(4, 5)) / 255,
      tonumber("0x" .. hex:sub(6, 7)) / 255,
      1
end

-- Generate accent colors based on base purple
function palette.generate_accent_colors()
  local base_hue = 258  -- Purple hue
  local base_sat = 0.64 -- 64% saturation
  local base_val = 0.9  -- 96% brightness/value

  local accent_colors = {}
  
  -- Color definitions with hue shifts
  local color_defs = {
    purple = 258, -- Base purple
    blue = 220,   -- Blue variant
    cyan = 180,   -- Cyan variant
    green = 140,  -- Green variant
    yellow = 50,  -- Yellow variant
    orange = 25,  -- Orange variant
    red = 0,      -- Red variant
    pink = 320,   -- Pink variant
  }

  for name, hue in pairs(color_defs) do
    local r, g, b = hsv_to_rgb(hue, base_sat, base_val)
    accent_colors[name] = { r, g, b, 1 }

    -- Generate darker variant for hover/pressed states
    local r_dark, g_dark, b_dark = hsv_to_rgb(hue, base_sat, base_val * 0.8)
    accent_colors[name .. "_dark"] = { r_dark, g_dark, b_dark, 1 }

    -- Generate lighter variant for highlights
    local r_light, g_light, b_light = hsv_to_rgb(hue, base_sat * 0.5, base_val)
    accent_colors[name .. "_light"] = { r_light, g_light, b_light, 1 }
  end

  return accent_colors
end

-- Create dark color palette
function palette.create_dark_palette()
  local accent_colors = palette.generate_accent_colors()
  
  local dark_colors = {
    -- Base colors
    background = { hex_to_rgb '#0A0A0A' },
    surface = { hex_to_rgb '#0F0F0F' },
    surface_variant = { hex_to_rgb '#121212' },
    surface_container = { hex_to_rgb '#1A1A1A' },
    
    -- Border and outline colors
    border = { 0.24, 0.24, 0.24, 1 },
    outline = { 0.3, 0.3, 0.3, 1 },
    outline_variant = { 0.2, 0.2, 0.2, 1 },
    
    -- Text colors
    text_primary = { 0.95, 0.95, 0.95, 1 },
    text_secondary = { 0.7, 0.7, 0.7, 1 },
    text_muted = { 0.5, 0.5, 0.5, 1 },
    text_disabled = { 0.3, 0.3, 0.3, 1 },
    
    -- Inverse colors for high contrast
    inverse_surface = { 0.9, 0.9, 0.9, 1 },
    inverse_text = { 0.1, 0.1, 0.1, 1 },
    
    -- Primary accent
    primary = accent_colors.purple,
    primary_dark = accent_colors.purple_dark,
    primary_light = accent_colors.purple_light,
    on_primary = { 1, 1, 1, 1 },
    
    -- Secondary accent
    secondary = accent_colors.blue,
    secondary_dark = accent_colors.blue_dark,
    secondary_light = accent_colors.blue_light,
    on_secondary = { 1, 1, 1, 1 },
    
    -- State colors
    success = accent_colors.green,
    success_dark = accent_colors.green_dark,
    success_light = accent_colors.green_light,
    on_success = { 1, 1, 1, 1 },
    
    warning = accent_colors.yellow,
    warning_dark = accent_colors.yellow_dark,
    warning_light = accent_colors.yellow_light,
    on_warning = { 0, 0, 0, 1 },
    
    error = accent_colors.red,
    error_dark = accent_colors.red_dark,
    error_light = accent_colors.red_light,
    on_error = { 1, 1, 1, 1 },
    
    info = accent_colors.cyan,
    info_dark = accent_colors.cyan_dark,
    info_light = accent_colors.cyan_light,
    on_info = { 1, 1, 1, 1 },
    
    -- Additional accent colors for variety
    accent_orange = accent_colors.orange,
    accent_pink = accent_colors.pink,
  }
  
  return Palette.new("dark", dark_colors)
end

-- Create light color palette
function palette.create_light_palette()
  local accent_colors = palette.generate_accent_colors()
  
  local light_colors = {
    -- Base colors
    background = { 1, 1, 1, 1 },
    surface = { 0.98, 0.98, 0.98, 1 },
    surface_variant = { 0.95, 0.95, 0.95, 1 },
    surface_container = { 0.92, 0.92, 0.92, 1 },
    
    -- Border and outline colors
    border = { 0.85, 0.85, 0.85, 1 },
    outline = { 0.7, 0.7, 0.7, 1 },
    outline_variant = { 0.8, 0.8, 0.8, 1 },
    
    -- Text colors
    text_primary = { 0.1, 0.1, 0.1, 1 },
    text_secondary = { 0.4, 0.4, 0.4, 1 },
    text_muted = { 0.6, 0.6, 0.6, 1 },
    text_disabled = { 0.7, 0.7, 0.7, 1 },
    
    -- Inverse colors for high contrast
    inverse_surface = { 0.1, 0.1, 0.1, 1 },
    inverse_text = { 0.9, 0.9, 0.9, 1 },
    
    -- Primary accent
    primary = accent_colors.purple,
    primary_dark = accent_colors.purple_dark,
    primary_light = accent_colors.purple_light,
    on_primary = { 1, 1, 1, 1 },
    
    -- Secondary accent
    secondary = accent_colors.blue,
    secondary_dark = accent_colors.blue_dark,
    secondary_light = accent_colors.blue_light,
    on_secondary = { 1, 1, 1, 1 },
    
    -- State colors
    success = accent_colors.green,
    success_dark = accent_colors.green_dark,
    success_light = accent_colors.green_light,
    on_success = { 1, 1, 1, 1 },
    
    warning = accent_colors.yellow,
    warning_dark = accent_colors.yellow_dark,
    warning_light = accent_colors.yellow_light,
    on_warning = { 0, 0, 0, 1 },
    
    error = accent_colors.red,
    error_dark = accent_colors.red_dark,
    error_light = accent_colors.red_light,
    on_error = { 1, 1, 1, 1 },
    
    info = accent_colors.cyan,
    info_dark = accent_colors.cyan_dark,
    info_light = accent_colors.cyan_light,
    on_info = { 1, 1, 1, 1 },
    
    -- Additional accent colors for variety
    accent_orange = accent_colors.orange,
    accent_pink = accent_colors.pink,
  }
  
  return Palette.new("light", light_colors)
end

-- Export
palette.Palette = Palette

return palette