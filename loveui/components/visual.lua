local Visual = {}

function Visual.new(params)
    params = params or {}
    return {
        type = params.type or "rectangle", -- rectangle, roundedrect, text, image
        backgroundColor = params.backgroundColor or { 0.2, 0.2, 0.2, 1 },
        borderColor = params.borderColor or { 0.4, 0.4, 0.4, 1 },
        borderWidth = params.borderWidth or 2,
        cornerRadius = params.cornerRadius or 8,
        text = params.text or "",
        font = params.font or love.graphics.getFont(),
        textColor = params.textColor or { 1, 1, 1, 1 },
        textAlign = params.textAlign or "center", -- "left", "center", "right"
        image = params.image or nil,
        shadow = params.shadow or {
            enabled = false,
            offsetX = 2,
            offsetY = 2,
            blur = 5,
            color = { 0, 0, 0, 0.5 }
        },
        opacity = params.opacity or 1
    }
end

return Visual
