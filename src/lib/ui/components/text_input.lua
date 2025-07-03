-- Text Input component
local text_input = {}
local utils = require('lib.ui.utils')
local theme = require('lib.ui.theme')

function text_input.new(x, y, w, placeholder, button_text)
  local ti = {
    x = x or 0,
    y = y or 0,
    w = w or 200,
    placeholder = placeholder or "",
    button_text = button_text,
    text = "",
    visible = true,
    enabled = true,

    -- Input state
    focused = false,
    cursor_pos = 0,
    selection_start = nil,
    selection_end = nil,

    -- Display properties
    scroll_offset = 0,

    -- Animation
    cursor_blink_timer = 0,
    cursor_visible = true,

    -- Callbacks
    onchange = nil,
    onsubmit = nil,
    onfocus = nil,
    onblur = nil,
    onbutton = nil, -- For optional button

    -- Component type
    _type = "text_input",
    _ui_id = nil,
  }

  function ti:get_height()
    return theme.manager:get_config("text_input.height", 36)
  end

  function ti:get_corner_radius()
    return theme.manager:get_config("text_input.corner_radius", 8)
  end

  function ti:get_smoothness()
    return theme.manager:get_config("text_input.smoothness", 4.0)
  end

  function ti:get_padding()
    return {
      x = theme.manager:get_config("text_input.padding.x", 12),
      y = theme.manager:get_config("text_input.padding.y", 8)
    }
  end

  function ti:get_cursor_width()
    return theme.manager:get_config("text_input.cursor_width", 1)
  end

  function ti:get_button_width()
    if not self.button_text then return 0 end

    local font = theme.manager:get_current_font()
    if font and font.actual_font then
      return font.actual_font:getWidth(self.button_text) + 20
    end
    return 60
  end

  function ti:get_input_width()
    local button_width = self:get_button_width()
    if button_width > 0 then
      return self.w - button_width - 8 -- 8px spacing
    end
    return self.w
  end

  function ti:get_colors()
    return {
      background = theme.manager:get_color('surface', { 0.1, 0.1, 0.1, 1 }),
      background_focused = theme.manager:get_color('surface_variant', { 0.15, 0.15, 0.15, 1 }),
      border = theme.manager:get_color('border', { 0.3, 0.3, 0.3, 1 }),
      border_focused = theme.manager:get_color('primary', { 0.5, 0.3, 0.8, 1 }),
      text = theme.manager:get_color('text_primary', { 1, 1, 1, 1 }),
      placeholder = theme.manager:get_color('text_muted', { 0.6, 0.6, 0.6, 1 }),
      selection = theme.manager:get_color('primary', { 0.5, 0.3, 0.8, 0.3 }),
      cursor = theme.manager:get_color('text_primary', { 1, 1, 1, 1 }),
      button_bg = theme.manager:get_color('primary', { 0.5, 0.3, 0.8, 1 }),
      button_text = theme.manager:get_color('on_primary', { 1, 1, 1, 1 }),
    }
  end

  function ti:set_text(text)
    local old_text = self.text
    self.text = text or ""
    self.cursor_pos = math.min(self.cursor_pos, #self.text)
    self:clear_selection()
    self:update_scroll()

    if self.onchange and old_text ~= self.text then
      self.onchange(self, self.text)
    end
  end

  function ti:get_text()
    return self.text
  end

  function ti:insert_text(new_text)
    if self:has_selection() then
      self:delete_selection()
    end

    local before = self.text:sub(1, self.cursor_pos)
    local after = self.text:sub(self.cursor_pos + 1)
    self:set_text(before .. new_text .. after)
    self.cursor_pos = self.cursor_pos + #new_text
    self:update_scroll()
  end

  function ti:delete_char(direction)
    if self:has_selection() then
      self:delete_selection()
      return
    end

    if direction == "backspace" and self.cursor_pos > 0 then
      local before = self.text:sub(1, self.cursor_pos - 1)
      local after = self.text:sub(self.cursor_pos + 1)
      self:set_text(before .. after)
      self.cursor_pos = self.cursor_pos - 1
    elseif direction == "delete" and self.cursor_pos < #self.text then
      local before = self.text:sub(1, self.cursor_pos)
      local after = self.text:sub(self.cursor_pos + 2)
      self:set_text(before .. after)
    end

    self:update_scroll()
  end

  function ti:move_cursor(direction, select)
    local old_pos = self.cursor_pos

    if direction == "left" and self.cursor_pos > 0 then
      self.cursor_pos = self.cursor_pos - 1
    elseif direction == "right" and self.cursor_pos < #self.text then
      self.cursor_pos = self.cursor_pos + 1
    elseif direction == "home" then
      self.cursor_pos = 0
    elseif direction == "end" then
      self.cursor_pos = #self.text
    end

    if select then
      if not self.selection_start then
        self.selection_start = old_pos
      end
      self.selection_end = self.cursor_pos

      -- Ensure start <= end
      if self.selection_start > self.selection_end then
        self.selection_start, self.selection_end = self.selection_end, self.selection_start
      end
    else
      self:clear_selection()
    end

    self:update_scroll()
    self:reset_cursor_blink()
  end

  function ti:has_selection()
    return self.selection_start ~= nil and self.selection_end ~= nil and
        self.selection_start ~= self.selection_end
  end

  function ti:clear_selection()
    self.selection_start = nil
    self.selection_end = nil
  end

  function ti:delete_selection()
    if not self:has_selection() then return end

    local before = self.text:sub(1, self.selection_start)
    local after = self.text:sub(self.selection_end + 1)
    self:set_text(before .. after)
    self.cursor_pos = self.selection_start
    self:clear_selection()
  end

  function ti:select_all()
    self.selection_start = 0
    self.selection_end = #self.text
    self.cursor_pos = #self.text
  end

  function ti:update_scroll()
    local font = theme.manager:get_current_font()
    if not font or not font.actual_font then return end

    local padding = self:get_padding()
    local available_width = self:get_input_width() - (padding.x * 2)

    -- Calculate cursor x position
    local text_before_cursor = self.text:sub(1, self.cursor_pos)
    local cursor_x = font.actual_font:getWidth(text_before_cursor)

    -- Adjust scroll to keep cursor visible
    if cursor_x - self.scroll_offset < 0 then
      self.scroll_offset = cursor_x
    elseif cursor_x - self.scroll_offset > available_width then
      self.scroll_offset = cursor_x - available_width
    end

    self.scroll_offset = math.max(0, self.scroll_offset)
  end

  function ti:reset_cursor_blink()
    self.cursor_blink_timer = 0
    self.cursor_visible = true
  end

  function ti:focus()
    if not self.focused then
      self.focused = true
      self:reset_cursor_blink()
      
      -- Add to focus stack
      local state = require('lib.ui.state')
      state.global:push_focus(self)
      
      if self.onfocus then
        self.onfocus(self)
      end
    end
  end

  function ti:blur()
    if self.focused then
      self.focused = false
      self:clear_selection()
      
      -- Remove from focus stack
      local state = require('lib.ui.state')
      state.global:pop_focus()
      
      if self.onblur then
        self.onblur(self)
      end
    end
  end

  function ti:submit()
    if self.onsubmit then
      self.onsubmit(self, self.text)
    end
  end

  function ti:update(dt)
    if not self.enabled then return end

    -- Handle cursor blinking
    if self.focused then
      self.cursor_blink_timer = self.cursor_blink_timer + dt
      if self.cursor_blink_timer >= 1.0 then
        self.cursor_visible = not self.cursor_visible
        self.cursor_blink_timer = 0
      end
    end
  end

  function ti:draw()
    if not self.visible then return end

    local colors = self:get_colors()
    local height = self:get_height()
    local corner_radius = self:get_corner_radius()
    local smoothness = self:get_smoothness()
    local padding = self:get_padding()
    local input_width = self:get_input_width()

    -- Draw input background
    local bg_color = self.focused and colors.background_focused or colors.background
    local border_color = self.focused and colors.border_focused or colors.border

    utils.draw_superellipse(self.x, self.y, input_width, height, corner_radius,
      bg_color, border_color, 1, smoothness)

    -- Setup clipping for text
    love.graphics.push()
    love.graphics.setScissor(self.x + padding.x, self.y, input_width - padding.x * 2, height)

    local font = theme.manager:get_current_font()
    if font and font.actual_font then
      love.graphics.setFont(font.actual_font)

      local text_x = self.x + padding.x - self.scroll_offset
      local text_y = self.y + (height - font.actual_font:getHeight()) / 2

      -- Draw selection background
      if self:has_selection() then
        local sel_start_x = text_x + font.actual_font:getWidth(self.text:sub(1, self.selection_start))
        local sel_end_x = text_x + font.actual_font:getWidth(self.text:sub(1, self.selection_end))

        love.graphics.setColor(colors.selection)
        love.graphics.rectangle("fill", sel_start_x, self.y + padding.y,
          sel_end_x - sel_start_x, height - padding.y * 2)
      end

      -- Draw text or placeholder
      if self.text == "" and not self.focused then
        love.graphics.setColor(colors.placeholder)
        love.graphics.print(self.placeholder, text_x, text_y)
      else
        love.graphics.setColor(colors.text)
        love.graphics.print(self.text, text_x, text_y)
      end

      -- Draw cursor
      if self.focused and self.cursor_visible then
        local cursor_x = text_x + font.actual_font:getWidth(self.text:sub(1, self.cursor_pos))
        local cursor_width = self:get_cursor_width()

        love.graphics.setColor(colors.cursor)
        love.graphics.rectangle("fill", cursor_x, self.y + padding.y,
          cursor_width, height - padding.y * 2)
      end
    end

    love.graphics.setScissor()
    love.graphics.pop()

    -- Draw button if present
    if self.button_text then
      local button_width = self:get_button_width()
      local button_x = self.x + input_width + 8

      utils.draw_superellipse(button_x, self.y, button_width, height, corner_radius,
        colors.button_bg, { 0, 0, 0, 0 }, 0, smoothness)

      if font and font.actual_font then
        local button_text_x = button_x + (button_width - font.actual_font:getWidth(self.button_text)) / 2
        local button_text_y = self.y + (height - font.actual_font:getHeight()) / 2

        love.graphics.setColor(colors.button_text)
        love.graphics.print(self.button_text, button_text_x, button_text_y)
      end
    end
  end

  function ti:mouse_pressed(x, y, button)
    if button == 1 and self.enabled and self.visible then
      local height = self:get_height()
      local input_width = self:get_input_width()

      -- Check input area
      if utils.point_in_rect(x, y, self.x, self.y, input_width, height) then
        self:focus()

        -- Position cursor based on click
        local font = theme.manager:get_current_font()
        if font and font.actual_font then
          local padding = self:get_padding()
          local relative_x = x - (self.x + padding.x) + self.scroll_offset

          -- Find closest character position
          local best_pos = 0
          local best_distance = math.huge

          for i = 0, #self.text do
            local char_x = font.actual_font:getWidth(self.text:sub(1, i))
            local distance = math.abs(char_x - relative_x)
            if distance < best_distance then
              best_distance = distance
              best_pos = i
            end
          end

          self.cursor_pos = best_pos
          self:clear_selection()
          self:reset_cursor_blink()
        end

        return true
      end

      -- Check button area
      if self.button_text then
        local button_width = self:get_button_width()
        local button_x = self.x + input_width + 8

        if utils.point_in_rect(x, y, button_x, self.y, button_width, height) then
          if self.onbutton then
            self.onbutton(self, self.text)
          end
          return true
        end
      end

      -- Clicked outside - blur
      self:blur()
    end

    return false
  end

  function ti:mouse_released(x, y, button)
    -- Override if needed
  end

  function ti:mouse_moved(x, y, dx, dy)
    -- Override if needed
  end

  function ti:key_pressed(key, scancode, isrepeat)
    if not self.focused then return false end

    local shift = love.keyboard.isDown("lshift", "rshift")
    local ctrl = love.keyboard.isDown("lctrl", "rctrl")

    if key == "backspace" then
      self:delete_char("backspace")
      self:reset_cursor_blink()
    elseif key == "delete" then
      self:delete_char("delete")
      self:reset_cursor_blink()
    elseif key == "left" then
      self:move_cursor("left", shift)
    elseif key == "right" then
      self:move_cursor("right", shift)
    elseif key == "home" then
      self:move_cursor("home", shift)
    elseif key == "end" then
      self:move_cursor("end", shift)
    elseif key == "return" or key == "kpenter" then
      self:submit()
    elseif key == "tab" then
      self:blur()
    elseif ctrl and key == "a" then
      self:select_all()
    elseif ctrl and key == "c" then
      if self:has_selection() then
        local selected_text = self.text:sub(self.selection_start + 1, self.selection_end)
        love.system.setClipboardText(selected_text)
      end
    elseif ctrl and key == "v" then
      local clipboard = love.system.getClipboardText()
      if clipboard then
        self:insert_text(clipboard)
      end
    elseif ctrl and key == "x" then
      if self:has_selection() then
        local selected_text = self.text:sub(self.selection_start + 1, self.selection_end)
        love.system.setClipboardText(selected_text)
        self:delete_selection()
      end
    end

    return true
  end

  function ti:text_input(text)
    if not self.focused then return false end

    self:insert_text(text)
    self:reset_cursor_blink()
    return true
  end

  function ti:set_position(x, y)
    self.x = x
    self.y = y
  end

  function ti:set_size(w, h)
    self.w = w
    self:update_scroll()
  end

  function ti:set_enabled(enabled)
    self.enabled = enabled
    if not enabled then
      self:blur()
    end
  end

  function ti:set_visible(visible)
    self.visible = visible
    if not visible then
      self:blur()
    end
  end

  function ti:get_width()
    return self.w
  end

  function ti:get_total_width()
    return self.w
  end

  return ti
end

return text_input
