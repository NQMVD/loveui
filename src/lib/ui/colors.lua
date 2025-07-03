-- Color system based on the reference purple
local colors = {}

-- Base purple from "Get it now!" button: #8B5CF6
local base_hue = 258  -- Purple hue
local base_sat = 0.64 -- 64% saturation
local base_val = 0.9  -- 96% brightness/value

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

-- Generate color variants with same saturation and brightness
function colors.generate_palette()
  local palette = {}

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
    palette[name] = { r, g, b, 1 }

    -- Generate darker variant for hover/pressed states
    local r_dark, g_dark, b_dark = hsv_to_rgb(hue, base_sat, base_val * 0.8)
    palette[name .. "_dark"] = { r_dark, g_dark, b_dark, 1 }

    -- Generate lighter variant for highlights
    local r_light, g_light, b_light = hsv_to_rgb(hue, base_sat * 0.5, base_val)
    palette[name .. "_light"] = { r_light, g_light, b_light, 1 }
  end

  return palette
end

-- hex to RGB conversion
local function hex_to_rgb(hex)
  return
      tonumber("0x" .. hex:sub(2, 3)) / 255,
      tonumber("0x" .. hex:sub(4, 5)) / 255,
      tonumber("0x" .. hex:sub(6, 7)) / 255,
      1
end

-- Dark theme colors
colors.dark = {
  background = { hex_to_rgb '#0A0A0A' },
  surface = { hex_to_rgb '#0F0F0F' }, -- cards
  surface_variant = { hex_to_rgb '#121212' },
  border = { 0.24, 0.24, 0.24, 1 },   -- borders for buttons, cards, etc.
  text_primary = { 0.95, 0.95, 0.95, 1 },
  text_secondary = { 0.7, 0.7, 0.7, 1 },
  text_muted = { 0.5, 0.5, 0.5, 1 },
}

-- Initialize palette
colors.palette = colors.generate_palette()

return colors
