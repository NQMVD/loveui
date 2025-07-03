local utils = {}

-- Draw superellipse with fill and optional border
function utils.draw_superellipse(x, y, w, h, corner_radius, fill_color, border_color, border_width, smoothness)
  corner_radius = corner_radius or 10
  smoothness = smoothness or 7.0
  border_width = border_width or 1
  
  -- Handle border cases
  if border_color and border_width > 0 and (border_color[1] ~= 0 or border_color[2] ~= 0 or border_color[3] ~= 0 or border_color[4] ~= 0) then
    -- Draw border first
    love.graphics.setColor(border_color)
    love.graphics.superellipse('fill', x, y, w, h, corner_radius, smoothness)
    
    -- Draw fill on top, inset by border width
    if fill_color then
      love.graphics.setColor(fill_color)
      love.graphics.superellipse('fill', 
        x + border_width, 
        y + border_width, 
        w - (border_width * 2), 
        h - (border_width * 2), 
        math.max(0, corner_radius - border_width), 
        smoothness)
    end
  elseif fill_color then
    -- No border, just fill
    love.graphics.setColor(fill_color)
    love.graphics.superellipse('fill', x, y, w, h, corner_radius, smoothness)
  end
end

-- Draw superellipse with shine effect
function utils.draw_superellipse_with_shine(x, y, w, h, corner_radius, fill_color, shine_options, smoothness)
  smoothness = smoothness or 7.0
  shine_options = shine_options or {}
  
  -- Draw base shape
  if fill_color then
    love.graphics.setColor(fill_color)
    love.graphics.superellipse('fill', x, y, w, h, corner_radius, smoothness)
  end
  
  -- Add shine effect
  if shine_options.shine_intensity and shine_options.shine_intensity > 0 then
    utils.draw_shine_effect(x, y, w, h, corner_radius, smoothness, shine_options)
  end
end

-- Inner shine effect with superellipse gradient falloff
-- function utils.draw_button_with_shine(x, y, w, h, radius, bg_color, shine_color, shine_intensity, smoothness, shine_loss)
function utils.draw_button_with_shine(x, y, w, h, radius, smoothness, bg_color, shine_table)
  smoothness = smoothness or 7.0
  local shine_intensity = shine_table.shine_intensity or 0.3
  local shine_loss = shine_table.shine_loss or 0.0
  local shine_color = shine_table.shine_color or { 1, 1, 1, 1 }

  -- Draw main button background
  utils.draw_superellipse(x, y, w, h, radius, bg_color, nil, 0, smoothness)

  if shine_intensity > 0 and shine_color then
    -- Calculate shine depth (how far the shine penetrates inward)
    local shine_depth = math.min(w, h) * 0.3          -- 30% of the smaller dimension
    local step_size = 1.5                             -- Step size
    local steps = math.floor(shine_depth / step_size) -- Number of gradient steps
    local offset_x = (shine_table and shine_table.offset_x) or 0
    local offset_y = (shine_table and shine_table.offset_y) or 0

    love.graphics.push()
    love.graphics.translate(x, y)

    -- Create stencil mask using superellipse shape
    love.graphics.stencil(function()
      utils.draw_superellipse(0, 0, w, h, radius, { 1, 1, 1, 1 }, nil, 0, smoothness)
    end, "replace", 1)

    -- love.graphics.setStencilTest("greater", 0)

    -- Draw border-only shine rings
    for i = 1, steps do
      -- Calculate ring dimensions
      local outer_inset = (i - 1) * step_size
      local inner_inset = i * step_size

      local outer_w = w - outer_inset
      local outer_h = h - outer_inset
      local inner_w = w - inner_inset + offset_x
      local inner_h = h - inner_inset + offset_y

      local outer_radius = math.max(0, radius - outer_inset / 2)
      local inner_radius = math.max(0, radius - inner_inset / 2)

      -- Skip if shapes become too small
      if outer_w <= 0 or outer_h <= 0 or inner_w <= 0 or inner_h <= 0 then
        break
      end

      -- Exponential falloff for quick decay
      local progress = (i - 1) / (steps - 1)
      local alpha_factor = math.pow(1 - progress, 2.5) -- Quick falloff

      local alpha = (shine_color[4] or 1) * shine_intensity * alpha_factor

      if alpha > 0.0005 then -- Skip nearly transparent layers
        local shine = { shine_color[1], shine_color[2], shine_color[3], alpha }

        -- Draw outer ring
        -- local outer_shape = get_superellipse(outer_w, outer_h, outer_radius, smoothness)
        -- outer_shape:draw(outer_inset / 2, outer_inset / 2, shine)
        utils.draw_superellipse(outer_inset / 2, outer_inset / 2, outer_w, outer_h, outer_radius, nil, shine, 0,
          smoothness)

        -- Cut out inner area by drawing background color on top
        -- local inner_shape = get_superellipse(inner_w, inner_h, inner_radius, smoothness)
        -- inner_shape:draw(inner_inset / 2, inner_inset / 2, bg_color)
        utils.draw_superellipse(inner_inset / 2, inner_inset / 2, inner_w, inner_h, inner_radius, nil, bg_color, 0,
          smoothness)
      end
    end

    -- love.graphics.setStencilTest()
    love.graphics.pop()
  end
end

function utils.point_in_rect(px, py, x, y, w, h)
  return px >= x and px <= x + w and py >= y and py <= y + h
end

function utils.lerp_color(color1, color2, t)
  return {
    color1[1] + (color2[1] - color1[1]) * t,
    color1[2] + (color2[2] - color1[2]) * t,
    color1[3] + (color2[3] - color1[3]) * t,
    color1[4] + (color2[4] - color1[4]) * t,
  }
end

function utils.draw_centered_text(text, x, y, w, h, font, color, y_offset)
  love.graphics.setFont(font)
  love.graphics.setColor(color)

  local text_w = font:getWidth(text)
  local text_h = font:getHeight()

  local text_x = math.floor(x + (w - text_w) / 2)
  local text_y = math.floor(y + (h - text_h) / 2) + (y_offset or 0)

  love.graphics.print(text, text_x, text_y)
end

-- array_iter(t)
--   for each i=1..#t returns t[i], without the index
function utils.array(t)
  local i, n = 0, #t
  return function()
    i = i + 1
    if i <= n then
      return t[i]
    end
  end
end

-- flatten_iter(t)
--   for each element e of t:
--     if type(e) == "table" then returns table.unpack(e)
--     else returns e
function utils.flatten(t)
  local unpack = table.unpack or unpack
  local i, n = 0, #t
  return function()
    i = i + 1
    if i > n then return end
    local e = t[i]
    if type(e) == "table" then
      return unpack(e)
    else
      return e
    end
  end
end

-- permutations(...)
--   takes any number of tables
--   returns an iterator which on each call yields a new table
--   containing one element from each input table
function utils.permutations(...)
  local unpack = table.unpack or unpack
  local wrap   = coroutine.wrap
  local lists  = { ... }
  local n      = #lists
  -- ensure all args are tables
  for i = 1, n do
    assert(type(lists[i]) == "table",
      "permutations: argument " .. i .. " must be a table")
  end
  return wrap(function()
    local cur = {}
    local function recurse(depth)
      if depth > n then
        -- yield a fresh copy of cur[1..n]
        coroutine.yield({ unpack(cur, 1, n) })
      else
        for _, v in ipairs(lists[depth]) do
          cur[depth] = v
          recurse(depth + 1)
        end
      end
    end
    recurse(1)
  end)
end

local function load_font(font_name, size, dpi_scale, yoffset)
  local FONT_PATH = "assets/fonts/"
  local font_path = FONT_PATH .. font_name
  local font = love.graphics.newFont(font_path, size, 'normal', dpi_scale or 1)
  -- print(
  --   "Loaded " .. font_name
  --   .. " at size: " .. size
  --   .. ", dpi scale: " .. font:getDPIScale()
  --   .. ", yoffset: " .. (yoffset or 0))
  return { actual_font = font, yoffset = yoffset or 0, dpi_scale = dpi_scale or 1 }
end

function utils.load_fonts(font_names, font_sizes)
  local fonts = {
    highdpi = {},
    lowdpi = {}
  }
  -- local w, h = love.graphics.getDimensions()
  for file_name, font_name, yoffset in utils.flatten(font_names) do
    -- print("Loading font: " .. file_name .. " as " .. font_name)
    -- highdpi first
    for size_name, size in pairs(font_sizes) do
      -- love.window.updateMode(w, h, { highdpi = true })
      local highdpi_font = load_font(file_name, size, 2, yoffset)
      if highdpi_font then
        fonts.highdpi[font_name] = fonts.highdpi[font_name] or {}
        fonts.highdpi[font_name][size_name] = highdpi_font
      end
      -- love.window.updateMode(w, h, { highdpi = false })
      local lowdpi_font = load_font(file_name, size, 1, yoffset)
      if lowdpi_font then
        fonts.lowdpi[font_name] = fonts.lowdpi[font_name] or {}
        fonts.lowdpi[font_name][size_name] = lowdpi_font
      end
    end
  end

  -- serp = require('serpent')
  -- print("Loaded fonts:")
  -- print(serp.block(fonts))
  return fonts
end

return utils
