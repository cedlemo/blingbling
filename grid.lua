-- @author cedlemo
--
--
local base = require("wibox.layout.base")
local widget_base = require("wibox.widget.base")
local table = table
local pairs = pairs
local floor = math.floor
local wibox = require('wibox')
local helpers = require('blingbling.helpers')


local grid = { mt = {} }
local data = setmetatable({}, { __mode = "k" })


local function round(x)
    return floor(x + 0.5)
end

function grid:draw(wibox, cr, width, height)
  local median_width = floor(width / data[self].num_columns)
  local median_height = floor(height / data[self].num_lines)
  local pos = 0
  
  for _, d in pairs(data[self].widgets) do
    local x, y, w, h
    
    x = round(median_width * (d.left - 1))
    y = round(median_height * (d.top - 1))

    w = floor(median_width * d.cols)
    h = floor(median_height * d.lines)
    
--    Keep for widget debug
--    str = "x " .. tostring(x) .. " y ".. tostring(y) .. " w " .. tostring(w) .. " h " .. tostring(h)
--    print("width " .. tostring(width) .. "height " .. tostring(height))
--    print("columns ".. tostring(data[self].num_columns) .. "median_width ".. tostring(median_width))
--    print("lines ".. tostring(data[self].num_lines) .. "median_height ".. tostring(median_height))
--    print(str)

    base.draw_widget(wibox, cr, d.widget, x, y, w, h)
  end

end

local function matrix_add(matrix, object, x, y, w, h)
  for i = 1, (y - 1) do 
    if matrix[i] == nil then matrix[i] = {} end
  end
  
  for i=0, (h - 1) do
    if matrix[y + i] == nil then matrix[y + i] = {} end
    local line = matrix[y + i]
    
    if #line < x - 1 then
      for j = #line + 1, (x - 1) do
        table.insert(line, j, "-") -- TODO find another way to use sparse table [w1,nil,nil,w2]
      end
    end
    
    for j=0,(w -1) do
      table.insert(line, x + j, object)
    end
  end
end

function grid:add_child(child, left, top, n_cols, n_lines)
  widget_base.check_widget(child)
  
  matrix_add(data[self].matrix, child, left, top, n_cols, n_lines)
  local widget_data = {}
  widget_data.widget = child
  widget_data.left = left
  widget_data.top = top
  widget_data.cols = n_cols
  widget_data.lines = n_lines

  table.insert(data[self].widgets, widget_data)

  if data[self].num_lines < n_lines + (top - 1) then
    data[self].num_lines = n_lines + (top - 1)
  end

  if data[self].num_columns < n_cols + (left - 1) then
    data[self].num_columns = n_cols + (left - 1)
  end
  
  child:connect_signal("widget::updated", self._emit_updated)
  self._emit_updated()
end

function grid:get_child(left, top)
  return data[self].matrix[left][top]
end

function grid:set_padding(padding)

end

function grid:fit(width, height)
  local matrix = data[self].matrix
  local max_width = 0
  local cumul_height = 0

  for _,line in ipairs(matrix) do
    local prev_widget = nil 
    local max_height = 0
    for i,w in ipairs(line) do
      local cumul_width = 0
      -- See TODO line 58
      if (prev_widget == nil or w ~= prev_widget) and w ~= "-" then 
        local w,h = w:fit(width, height)
        cumul_width = cumul_width + w
        if max_height <  h then max_height = h end
        prev_widget = w
      end
      if max_width < cumul_width then max_width = cumul_width end
    end

    cumul_height = max_height + cumul_height
  end
  return max_width, cumul_height
end

function grid.new()
  local _grid = widget_base.make_widget()
  
  data[_grid] = {}
  data[_grid].matrix = {} -- Used a map for access through get_child
  data[_grid].widgets = {}
  data[_grid].num_lines = 0
  data[_grid].num_columns = 0

  _grid._emit_updated = function()
      _grid:emit_signal("widget::updated")
  end

  _grid.add_child = grid.add_child
  _grid.get_child = grid.get_child
  _grid.set_padding = grid.set_padding
  _grid.draw = grid.draw
  _grid.fit = grid.fit
  
  return _grid
end

function grid.mt:__call(...)
  return grid.new(...)
end

return setmetatable(grid, grid.mt)
