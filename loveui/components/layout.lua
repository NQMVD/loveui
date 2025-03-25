local Layout = {}

function Layout.new(params)
    params = params or {}
    return {
        parent = params.parent or nil,
        children = params.children or {},
        paddingLeft = params.paddingLeft or 10,
        paddingRight = params.paddingRight or 10,
        paddingTop = params.paddingTop or 10,
        paddingBottom = params.paddingBottom or 10,
        marginLeft = params.marginLeft or 0,
        marginRight = params.marginRight or 0,
        marginTop = params.marginTop or 0,
        marginBottom = params.marginBottom or 0,
        direction = params.direction or "vertical", -- "vertical" or "horizontal"
        spacing = params.spacing or 5,
        grow = params.grow or 0,
        align = params.align or "start", -- "start", "center", "end", "space-between"
        wrap = params.wrap or false
    }
end

return Layout
