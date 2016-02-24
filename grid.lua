-- @author cedlemo
--
--
local wibox = require('wibox')
local helpers = require('blingbling.helpers')
local grid = { mt = {} }
local data = setmetatable({}, { __mode = "k" })

function grid:add_child(child, left_x, top_x, width, height)

end

function grid:get_child(left_x, left_y)

end

function grid::set_padding(padding)

end

function grid.new(args)

end

function grid.mt:__call(...)
  return grid.new(...)
end

return setmetatable(calendar, calendar.mt)
