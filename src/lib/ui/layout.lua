local layout = {}

-- Simple flex-like layout system
function layout.flex(container_x, container_y, container_w, direction, spacing, items)
  direction = direction or "row"   -- "row" or "column"
  spacing = spacing or 8

  local positions = {}
  local current_pos = 0

  if direction == "row" then
    for i, item in ipairs(items) do
      table.insert(positions, {
        x = container_x + current_pos,
        y = container_y,
        w = item.w,
        h = item.h
      })
      current_pos = current_pos + item.w + spacing
    end
  else   -- column
    for i, item in ipairs(items) do
      table.insert(positions, {
        x = container_x,
        y = container_y + current_pos,
        w = item.w,
        h = item.h
      })
      current_pos = current_pos + item.h + spacing
    end
  end

  return positions
end

function layout.center(container_x, container_y, container_w, container_h, item_w, item_h)
  return {
    x = container_x + (container_w - item_w) / 2,
    y = container_y + (container_h - item_h) / 2,
    w = item_w,
    h = item_h
  }
end

return layout
