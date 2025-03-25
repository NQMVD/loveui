local Interactive = {}

function Interactive.new(params)
    params = params or {}
    return {
        clickable = params.clickable or false,
        draggable = params.draggable or false,
        hoverable = params.hoverable or false,
        hovered = false,
        pressed = false,
        focused = false,
        onClick = params.onClick,
        onHover = params.onHover,
        onLeave = params.onLeave,
        onPress = params.onPress,
        onRelease = params.onRelease,
        onDrag = params.onDrag,
        enabled = params.enabled == nil and true or params.enabled
    }
end

return Interactive
