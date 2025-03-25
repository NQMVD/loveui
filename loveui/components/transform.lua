local Transform = {}

function Transform.new(x, y, width, height)
    return {
        x = x or 0,
        y = y or 0,
        width = width or 100,
        height = height or 50,
        scale = 1,
        rotation = 0,
        anchor = {x = 0, y = 0}, -- 0,0 is top-left, 0.5,0.5 is center
        visible = true
    }
end

return Transform
