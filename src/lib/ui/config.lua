-- Configuration system for LoveUI
-- Separates app-level Settings from UI-level Configurations
local config = {}

-- Settings: App-level configuration (API refresh rates, debug modes, etc.)
local Settings = {}
Settings.__index = Settings

function Settings.new(initial_settings)
  local settings = setmetatable({}, Settings)
  settings.data = initial_settings or {}
  return settings
end

function Settings:get(key, fallback)
  return self.data[key] ~= nil and self.data[key] or fallback
end

function Settings:set(key, value)
  self.data[key] = value
end

function Settings:validate()
  -- Add validation logic for app settings
  return true
end

-- Configurations: UI-level styling and behavior configurations
local Configuration = {}
Configuration.__index = Configuration

function Configuration.new(name, config_data)
  local cfg = setmetatable({}, Configuration)
  cfg.name = name
  cfg.data = config_data or {}
  cfg._validated = false
  return cfg
end

function Configuration:get(path, fallback)
  local keys = {}
  for key in path:gmatch("[^%.]+") do
    table.insert(keys, key)
  end

  local current = self.data
  for _, key in ipairs(keys) do
    if type(current) ~= "table" or current[key] == nil then
      return fallback
    end
    current = current[key]
  end

  return current
end

function Configuration:set(path, value)
  local keys = {}
  for key in path:gmatch("[^%.]+") do
    table.insert(keys, key)
  end

  local current = self.data
  for i = 1, #keys - 1 do
    local key = keys[i]
    if type(current[key]) ~= "table" then
      current[key] = {}
    end
    current = current[key]
  end

  current[keys[#keys]] = value
  self._validated = false -- Require revalidation
end

function Configuration:get_with_inheritance(component_type, property, fallback)
  -- First try component-specific value
  local component_value = self:get(component_type .. "." .. property)
  if component_value ~= nil then
    return component_value
  end
  
  -- Then try global inheritance
  local global_value = self:get("global." .. property)
  if global_value ~= nil then
    return global_value
  end
  
  return fallback
end

function Configuration:validate()
  -- Validation rules for UI configurations
  local required_paths = {
    "global.corner_radius",
    "global.smoothness", 
    "global.border_width",
    "global.spacing",
    "global.padding",
    "button.height",
    "button.padding.x",
    "button.padding.y",
    "chooser.height",
    "fonts.sizes.normal",
    "fonts.sizes.small",
    "fonts.sizes.big"
  }

  for _, path in ipairs(required_paths) do
    if self:get(path) == nil then
      error("Missing required configuration: " .. path)
    end
  end

  -- Type validation
  local numeric_paths = {
    "global.corner_radius",
    "global.smoothness",
    "global.border_width", 
    "global.spacing",
    "global.padding",
    "button.height",
    "button.padding.x",
    "button.padding.y",
    "chooser.height",
    "fonts.sizes.normal",
    "fonts.sizes.small",
    "fonts.sizes.big"
  }

  for _, path in ipairs(numeric_paths) do
    local value = self:get(path)
    if value ~= nil and type(value) ~= "number" then
      error("Configuration " .. path .. " must be a number, got " .. type(value))
    end
  end

  self._validated = true
  return true
end

function Configuration:is_validated()
  return self._validated
end

-- Configuration factory functions
function config.create_default_configuration()
  return Configuration.new("default", {
    -- Global styling inheritance
    global = {
      corner_radius = 8,
      smoothness = 4.0,
      border_width = 1,
      spacing = 8,
      padding = 16,
    },
    -- Button variants configuration
    button_variants = {
      primary = {
        background_color = "primary",
        background_hover_color = "primary_dark",
        text_color = "on_primary",
        border_color = nil,
        shine_color = { 1, 1, 1, 1 },
        has_shine = true,
      },
      secondary = {
        background_color = "surface_variant",
        background_hover_color = "border",
        text_color = "text_primary",
        border_color = "border",
        has_shine = false,
      },
      secondary_shine = {
        background_color = "surface_variant",
        background_hover_color = "border",
        text_color = "text_primary",
        border_color = nil,
        shine_color = "text_muted",
        has_shine = true,
      },
      success = {
        background_color = "success",
        background_hover_color = "success_dark",
        text_color = "on_success",
        border_color = nil,
        shine_color = { 1, 1, 1, 1 },
        has_shine = true,
      },
      warning = {
        background_color = "warning",
        background_hover_color = "warning_dark",
        text_color = "on_warning",
        border_color = nil,
        shine_color = { 1, 1, 1, 1 },
        has_shine = true,
      },
      error = {
        background_color = "error",
        background_hover_color = "error_dark",
        text_color = "on_error",
        border_color = nil,
        shine_color = { 1, 1, 1, 1 },
        has_shine = true,
      },
    },
    button = {
      height = 36,
      padding = { x = 16, y = 8 },
      shine_intensity = 0.15,
      shine_loss = 0.0,
      text_y_offset = 0,
    },
    pane = {
      corner_radius = 12,
      auto_size = false,
      text_y_offset = 0,
    },
    chooser = {
      height = 32,
      segment_width = nil, -- Will auto-calculate
      indicator_padding = 2,
      text_y_offset = 0,
    },
    slider = {
      height = 6,
      handle_size = 20,
      corner_radius = 3,
      smoothness = 2.0,
      track_corner_radius = 3,
    },
    checkbox = {
      size = 20,
      corner_radius = 4,
      smoothness = 2.0,
      border_width = 2,
    },
    dropdown = {
      height = 36,
      corner_radius = 8,
      smoothness = 4.0,
      max_visible_items = 6,
      item_height = 32,
    },
    text_input = {
      height = 36,
      corner_radius = 8,
      smoothness = 4.0,
      padding = { x = 12, y = 8 },
      cursor_width = 1,
    },
    text = {
      line_height = 1.2,
      wrap_mode = "word",
    },
    fonts = {
      names = {
        { "BerkeleyMono.ttf",     "berkeley", 0 },
        { "StyreneA-Regular.ttf", "styrene",  2 }
      },
      sizes = {
        big = 20,
        normal = 16,
        small = 14
      },
      default_name = "berkeley",
      default_size = "small"
    },
    layout = {
      spacing = 8,
      margin = 16,
    }
  })
end

function config.create_rounded_configuration()
  local cfg = config.create_default_configuration()
  cfg:set("button.corner_radius", 12)
  cfg:set("pane.corner_radius", 16)
  cfg:set("chooser.corner_radius", 10)
  cfg:set("slider.corner_radius", 6)
  cfg:set("checkbox.corner_radius", 6)
  cfg:set("dropdown.corner_radius", 12)
  cfg:set("text_input.corner_radius", 12)
  cfg.name = "rounded"
  return cfg
end

function config.create_sharp_configuration()
  local cfg = config.create_default_configuration()
  cfg:set("button.corner_radius", 2)
  cfg:set("pane.corner_radius", 4)
  cfg:set("chooser.corner_radius", 2)
  cfg:set("slider.corner_radius", 1)
  cfg:set("checkbox.corner_radius", 2)
  cfg:set("dropdown.corner_radius", 2)
  cfg:set("text_input.corner_radius", 2)
  cfg.name = "sharp"
  return cfg
end

-- Export
config.Settings = Settings
config.Configuration = Configuration

return config
