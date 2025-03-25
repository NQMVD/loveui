local LoveUI = require("loveui")

local colorSchemes = {
    gruvbox = {
        light = {
            background = { 251 / 255, 241 / 255, 199 / 255, 1 },
            foreground = { 60 / 255, 56 / 255, 54 / 255, 1 },
            red = { 251 / 255, 73 / 255, 52 / 255, 1 },
            green = { 184 / 255, 187 / 255, 38 / 255, 1 },
            yellow = { 250 / 255, 189 / 255, 47 / 255, 1 },
            blue = { 131 / 255, 165 / 255, 152 / 255, 1 },
            purple = { 211 / 255, 134 / 255, 155 / 255, 1 },
            aqua = { 142 / 255, 192 / 255, 124 / 255, 1 },
            orange = { 254 / 255, 128 / 255, 25 / 255, 1 },
        },
        dark = {
            background = { 40 / 255, 40 / 255, 40 / 255, 1 },
            foreground = { 235 / 255, 219 / 255, 178 / 255, 1 },
            red = { 251 / 255, 73 / 255, 52 / 255, 1 },
            green = { 184 / 255, 187 / 255, 38 / 255, 1 },
            yellow = { 250 / 255, 189 / 255, 47 / 255, 1 },
            blue = { 131 / 255, 165 / 255, 152 / 255, 1 },
            purple = { 211 / 255, 134 / 255, 155 / 255, 1 },
            aqua = { 142 / 255, 192 / 255, 124 / 255, 1 },
            orange = { 254 / 255, 128 / 255, 25 / 255, 1 },
        },
    },
    tokyo_night = {
        light = {
            background = { 224 / 255, 224 / 255, 224 / 255, 1 },
            foreground = { 26 / 255, 27 / 255, 38 / 255, 1 },
            red = { 255 / 255, 85 / 255, 85 / 255, 1 },
            green = { 80 / 255, 250 / 255, 123 / 255, 1 },
            yellow = { 241 / 255, 250 / 255, 140 / 255, 1 },
            blue = { 189 / 255, 147 / 255, 249 / 255, 1 },
            purple = { 255 / 255, 121 / 255, 198 / 255, 1 },
            aqua = { 139 / 255, 233 / 255, 253 / 255, 1 },
            orange = { 255 / 255, 184 / 255, 108 / 255, 1 },
        },
        dark = {
            background = { 26 / 255, 27 / 255, 38 / 255, 1 },
            foreground = { 169 / 255, 177 / 255, 214 / 255, 1 },
            red = { 247 / 255, 118 / 255, 142 / 255, 1 },
            green = { 158 / 255, 206 / 255, 106 / 255, 1 },
            yellow = { 224 / 255, 175 / 255, 104 / 255, 1 },
            blue = { 122 / 255, 162 / 255, 247 / 255, 1 },
            purple = { 187 / 255, 154 / 255, 247 / 255, 1 },
            aqua = { 125 / 255, 207 / 255, 255 / 255, 1 },
            orange = { 255 / 255, 158 / 255, 100 / 255, 1 },
        },
    },
    claude = {
        -- Background colors
        background_dark = { 0.086, 0.086, 0.086 },  -- #161616
        background_light = { 0.118, 0.118, 0.118 }, -- #1E1E1E

        -- Text colors
        text_white = { 1, 1, 1 },            -- #FFFFFF
        text_gray = { 0.678, 0.678, 0.678 }, -- #ADADAD
        text_blue = { 0.235, 0.525, 0.796 }, -- #3C86CB

        -- Highlight colors
        highlight_blue = { 0.235, 0.525, 0.796 }, -- #3C86CB
        highlight_gray = { 0.678, 0.678, 0.678 }, -- #ADADAD

        -- Button colors
        button_dark = { 0.118, 0.118, 0.118 },  -- #1E1E1E
        button_light = { 0.086, 0.086, 0.086 }, -- #161616

        -- Icon colors
        icon_gray = { 0.678, 0.678, 0.678 }, -- #ADADAD
        icon_blue = { 0.235, 0.525, 0.796 }, -- #3C86CB
    }
}
local colorScheme = colorSchemes.tokyo_night.dark

-- Values for demonstration
local sliderValue = 50
local labelText = "Slider Value: 50"

local Container = LoveUI.widgets.Container
local Button = LoveUI.widgets.Button
local Slider = LoveUI.widgets.Slider
local TextInput = LoveUI.widgets.TextInput

local fontName = "MonaspaceNeon.otf"

-- Helper function to brighten a color
local function brighten(color, amount)
    return {
        color[1] + amount,
        color[2] + amount,
        color[3] + amount,
        color[4]
    }
end

function love.load()
    -- Create font for better text display
    uiFont = love.graphics.newFont(fontName, 16)
    titleFont = love.graphics.newFont(fontName, 20)
    love.graphics.setFont(uiFont)

    -- Create UI world
    ui = LoveUI.createUI()

    -- Create main panel that holds everything
    mainPanel = Container.new(ui, {
        x = 50,
        y = 50,
        width = 700,
        height = 600,
        backgroundColor = brighten(colorScheme.background, 0.1),
        borderColor = brighten(colorScheme.background, 0.2),
        borderWidth = 2,
        direction = "horizontal",
    })

    -- Left column - Basic controls
    leftColumn = Container.new(ui, {
        parent = mainPanel,
        width = 340,
        height = 400,
        backgroundColor = brighten(colorScheme.background, 0.05),
        borderColor = brighten(colorScheme.background, 0.1),
        direction = "vertical",
    })

    -- Title for left panel
    titleLabel = Container.new(ui, {
        parent = leftColumn,
        height = 40,
        backgroundColor = brighten(colorScheme.background, 0.1),
        borderWidth = 0,
    })

    titleVisual = ui:getComponent(titleLabel, "visual")
    titleVisual.text = "Basic Controls"
    titleVisual.font = titleFont
    titleVisual.textColor = colorScheme.foreground

    -- Standard button
    button1 = Button.new(ui, {
        text = "Standard Button",
        parent = leftColumn,
        height = 40,
        backgroundColor = colorScheme.blue,
        borderColor = brighten(colorScheme.blue, 0.1),
        onClick = function()
            print("Standard button clicked!")
        end
    })

    -- Danger button
    button2 = Button.new(ui, {
        text = "Danger Button",
        parent = leftColumn,
        height = 40,
        backgroundColor = colorScheme.red,
        borderColor = brighten(colorScheme.red, 0.1),
        onClick = function()
            print("Danger button clicked!")
        end
    })

    -- Success button
    button3 = Button.new(ui, {
        text = "Success Button",
        parent = leftColumn,
        height = 40,
        backgroundColor = colorScheme.green,
        borderColor = brighten(colorScheme.green, 0.1),
        onClick = function()
            print("Success button clicked!")
        end
    })

    -- Label for slider
    valueLabel = Container.new(ui, {
        parent = leftColumn,
        height = 30,
        marginTop = 10,
        backgroundColor = { 0, 0, 0, 0 },
        borderWidth = 0
    })

    valueLabelVisual = ui:getComponent(valueLabel, "visual")
    valueLabelVisual.text = labelText
    valueLabelVisual.textColor = colorScheme.foreground

    -- Slider widget
    sliderWidget, slider = Slider.new(ui, {
        parent = leftColumn,
        height = 30,
        backgroundColor = brighten(colorScheme.background, 0.1),
        borderColor = brighten(colorScheme.background, 0.2),
        handleColor = colorScheme.blue,
        handleBorderColor = brighten(colorScheme.blue, 0.1),
        min = 0,
        max = 100,
        value = sliderValue,
        onChange = function(value)
            sliderValue = math.floor(value)
            labelText = "Slider Value: " .. sliderValue
            valueLabelVisual.text = labelText
        end
    })

    -- Right column - Container examples
    rightColumn = Container.new(ui, {
        parent = mainPanel,
        grow = 1, -- Take remaining space
        height = 500,
        backgroundColor = brighten(colorScheme.background, 0.05),
        borderColor = brighten(colorScheme.background, 0.1),
        direction = "vertical",
    })

    -- Title for right panel
    rightTitleLabel = Container.new(ui, {
        parent = rightColumn,
        height = 40,
        backgroundColor = brighten(colorScheme.background, 0.1),
        borderWidth = 0,
    })

    rightTitleVisual = ui:getComponent(rightTitleLabel, "visual")
    rightTitleVisual.text = "Container Examples"
    rightTitleVisual.font = titleFont
    rightTitleVisual.textColor = colorScheme.foreground

    -- Horizontal container
    horizontalContainer = Container.new(ui, {
        parent = rightColumn,
        height = 80,
        backgroundColor = brighten(colorScheme.background, 0.2),
        borderColor = brighten(colorScheme.background, 0.3),
        direction = "horizontal",
    })

    -- Add some buttons to horizontal container
    for i = 1, 3 do
        Button.new(ui, {
            text = "Button " .. i,
            parent = horizontalContainer,
            width = 80,
            height = 50,
            backgroundColor = { 0.2, 0.3 + i * 0.1, 0.6, 1 },
            borderColor = { 0.3, 0.4 + i * 0.1, 0.7, 1 },
            onClick = function()
                print("Button " .. i .. " button clicked!")
            end
        })
    end

    -- Form example with text inputs
    formContainer = Container.new(ui, {
        parent = rightColumn,
        height = 180,
        backgroundColor = brighten(colorScheme.background, 0.2),
        borderColor = brighten(colorScheme.background, 0.3),
        direction = "vertical",
        spacing = 10,
        paddingLeft = 15,
        paddingRight = 15,
        paddingTop = 15,
        paddingBottom = 15
    })

    -- Form label
    formLabel = Container.new(ui, {
        parent = formContainer,
        height = 25,
        backgroundColor = { 0, 0, 0, 0 },
        borderWidth = 0
    })

    formLabelVisual = ui:getComponent(formLabel, "visual")
    formLabelVisual.text = "Login Form Example"
    formLabelVisual.textColor = colorScheme.foreground

    -- Username field
    usernameLabel = Container.new(ui, {
        parent = formContainer,
        height = 20,
        backgroundColor = { 0, 0, 0, 0 },
        borderWidth = 0
    })

    usernameLabelVisual = ui:getComponent(usernameLabel, "visual")
    usernameLabelVisual.text = "Username:"
    usernameLabelVisual.textColor = colorScheme.foreground

    usernameInput = TextInput.new(ui, {
        parent = formContainer,
        height = 35,
        text = "user@example.com",
        backgroundColor = brighten(colorScheme.background, 0.3),
        borderColor = brighten(colorScheme.background, 0.4),
    })

    -- Form submit button
    submitButton = Button.new(ui, {
        text = "Log In",
        parent = formContainer,
        height = 35,
        backgroundColor = colorScheme.green,
        borderColor = brighten(colorScheme.green, 0.1),
        onClick = function()
            print("Form submitted!")
        end
    })

    -- Nested container example
    nestedContainer = Container.new(ui, {
        parent = rightColumn,
        grow = 1,
        backgroundColor = brighten(colorScheme.background, 0.2),
        borderColor = brighten(colorScheme.background, 0.3),
        direction = "vertical",
    })

    -- Label for nested container
    nestedLabel = Container.new(ui, {
        parent = nestedContainer,
        height = 30,
        backgroundColor = { 0, 0, 0, 0 },
        borderWidth = 0
    })

    nestedLabelVisual = ui:getComponent(nestedLabel, "visual")
    nestedLabelVisual.text = "Nested Container"
    nestedLabelVisual.textColor = colorScheme.foreground

    -- Inner container with different layout direction
    innerContainer = Container.new(ui, {
        parent = nestedContainer,
        grow = 1,
        backgroundColor = brighten(colorScheme.background, 0.3),
        borderColor = brighten(colorScheme.background, 0.4),
        direction = "horizontal",
    })

    -- Add content to inner container
    for i = 1, 2 do
        local innerColumn = Container.new(ui, {
            parent = innerContainer,
            grow = 1,
            backgroundColor = brighten(colorScheme.background, 0.4),
            borderColor = brighten(colorScheme.background, 0.5),
            direction = "vertical",
        })

        -- Add some buttons to each column
        for j = 1, 2 do
            Button.new(ui, {
                text = "Col " .. i .. " Btn " .. j,
                parent = innerColumn,
                height = 40,
                backgroundColor = { 0.3, 0.4 + j * 0.1, 0.5 + i * 0.1, 1 },
                borderColor = { 0.4, 0.5 + j * 0.1, 0.6 + i * 0.1, 1 }
            })
        end
    end

    Button.new(ui, {
        text = "Button ",
        parent = mainPanel,
        width = 80,
        height = 50,
        backgroundColor = colorScheme.background,
        borderColor = brighten(colorScheme.background, 0.1),
        onClick = function(id, x, y)
            ui:getComponent(id, "visual").backgroundColor = colorScheme.blue
            print("Button  button clicked!")
        end
    })

    -- Force layout calculation
    ui.systems[3]:markDirty()
end

function love.update(dt)
    ui:update(dt)
end

function love.draw()
    -- Set background color
    love.graphics.clear(colorScheme.background)

    -- Draw UI
    ui:draw()

    -- Draw title
    love.graphics.setFont(titleFont)
    love.graphics.setColor(colorScheme.foreground)
    love.graphics.print("LoveUI Widget Showcase", 50, 20)

    -- Draw info
    love.graphics.setFont(uiFont)
    love.graphics.setColor(colorScheme.foreground)
    love.graphics.print("An ECS-based UI library with modern styling", 50, 570)
end
