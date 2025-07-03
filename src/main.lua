-- Demo application for new LoveUI architecture
local ui = require('lib.ui.init')

local demo = {}
local components = {}
local current_theme = "dark_default"

function love.load()
  -- Initialize UI system
  ui.init(current_theme, {
    debug_mode = true,
    auto_update = true
  })

  print("Available themes:", table.concat(ui.get_available_themes(), ", "))

  -- Create demo components
  create_demo_components()
end

function create_demo_components()
  components = {}

  -- Title text
  local title = ui.create_text(20, 20, 400, "LoveUI New Architecture Demo", "big", "text_primary")
  table.insert(components, title)

  -- Theme selector
  local theme_options = ui.get_available_themes()
  local theme_chooser = ui.create_chooser(20, 60, theme_options, 1)
  theme_chooser.onchange = function(self, index, option)
    current_theme = option
    ui.set_theme(option)
    print("Theme changed to:", option)
  end
  table.insert(components, theme_chooser)

  -- Main content pane with vertical layout
  local main_pane = ui.create_pane(20, 120, 760, 500, "vertical")
  main_pane.spacing = 16
  main_pane.padding = 20
  table.insert(components, main_pane)

  -- Button section
  local button_section = ui.create_pane(0, 0, 720, 60, "horizontal")
  local primary_btn = ui.create_button("Primary", 0, 0, nil, nil, "primary")
  primary_btn.onclick = function() print("Primary button clicked!") end

  local secondary_btn = ui.create_button("Secondary", 0, 0, nil, nil, "secondary")
  secondary_btn.onclick = function() print("Secondary button clicked!") end

  local success_btn = ui.create_button("Success", 0, 0, nil, nil, "success")
  success_btn.onclick = function() print("Success button clicked!") end

  local warning_btn = ui.create_button("Warning", 0, 0, nil, nil, "warning")
  warning_btn.onclick = function() print("Warning button clicked!") end

  button_section:add_child(primary_btn, { align = "left" })
  button_section:add_child(secondary_btn, { align = "left" })
  button_section:add_child(success_btn, { align = "left" })
  button_section:add_child(warning_btn, { align = "left" })
  main_pane:add_child(button_section)

  -- Form controls section
  local form_pane = ui.create_pane(0, 0, 720, 200, "vertical")

  -- Text input
  local text_input = ui.create_text_input(0, 0, 300, "Enter your name...", "Submit")
  text_input.onsubmit = function(self, text)
    print("Text submitted:", text)
  end
  text_input.onbutton = function(self, text)
    print("Button clicked with text:", text)
  end
  form_pane:add_child(text_input)

  -- Slider
  local slider = ui.create_slider(0, 0, 300, 0, 100, 50, "integer")
  slider.onchange = function(self, value)
    print("Slider value:", value)
  end
  form_pane:add_child(slider)

  -- Checkbox
  local checkbox = ui.create_checkbox(0, 0, "Enable notifications", true)
  checkbox.onchange = function(self, checked)
    print("Checkbox:", checked and "checked" or "unchecked")
  end
  form_pane:add_child(checkbox)

  -- Dropdown
  local dropdown = ui.create_dropdown(0, 0, 200, { "Option 1", "Option 2", "Option 3" }, "Select...")
  dropdown.onchange = function(self, index, option)
    print("Dropdown selected:", option)
  end
  form_pane:add_child(dropdown)

  main_pane:add_child(form_pane)

  -- Info text
  local info_text = ui.create_text(0, 0, 700,
    "This demo showcases the new LoveUI architecture with zero hardcoded values, " ..
    "modular configuration system, and comprehensive theme support. All styling " ..
    "is controlled through the theme configuration system.", "normal", "text_secondary")
  info_text:set_align("left")
  main_pane:add_child(info_text)

  print("Demo components created successfully!")
end

function love.update(dt)
  ui.update(dt)
end

function love.draw()
  -- Clear screen with theme background
  local bg_color = ui.get_color('background', { 0, 0, 0, 1 })
  love.graphics.clear(bg_color[1], bg_color[2], bg_color[3], bg_color[4])

  ui.draw()

  -- Show theme info
  local font = ui.get_current_font()
  if font and font.actual_font then
    love.graphics.setColor(ui.get_color('text_muted', { 0.6, 0.6, 0.6, 1 }))
    love.graphics.setFont(font.actual_font)
    love.graphics.print("Current theme: " .. current_theme, 20, love.graphics.getHeight() - 40)
    love.graphics.print("Press ESC to quit", 20, love.graphics.getHeight() - 20)
  end
end

function love.mousepressed(x, y, button, istouch, presses)
  ui.mouse_pressed(x, y, button)
end

function love.mousereleased(x, y, button, istouch, presses)
  ui.mouse_released(x, y, button)
end

function love.mousemoved(x, y, dx, dy, istouch)
  ui.mouse_moved(x, y, dx, dy)
end

function love.keypressed(key, scancode, isrepeat)
  if key == "escape" then
    love.event.quit()
  else
    ui.key_pressed(key, scancode, isrepeat)
  end
end

function love.keyreleased(key, scancode)
  ui.key_released(key, scancode)
end

function love.textinput(text)
  ui.text_input(text)
end
