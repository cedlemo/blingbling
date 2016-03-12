-- @ author Cédric Le Moigne
local helpers = require("blingbling.helpers")
local superproperties = require("blingbling.superproperties")
local calendar = require("blingbling.calendar")
local wibox = require("wibox")
local grid = require("blingbling.grid")
local text_box = require("blingbling.text_box")

local ext_calendar = { mt = {} }
local data = setmetatable({}, { __mode = "k" })

local properties = { "info_cell_style", "link_to_external_calendar" }

local function print_info_enter(widget, data)
  print("enter")
  print(widget._layout.text)
  print(data)
end
local function print_info_leave(widget, data)
  print("leave")
  print(widget._layout.text)
  print(data)
end

function ext_calendar.new(args)
  local args = args or {}

  local _calendar = wibox(args)
  data[_calendar] = {}

  args.focus_days = true 
  args.focus_days_enter_callback = {cb = print_info_enter, data = "yeah"}
  args.focus_days_leave_callback = {cb = print_info_leave, data = "double yeah"}
  data[_calendar].calendar = calendar(args)
  data[_calendar].grid = grid()

--  data[_calendar].calendar:set_focus_days_enter_callback({cb = print_info_enter, data = "yeah"})
--  data[_calendar].calendar:set_focus_days_leave_callback({cb = print_info_leave, data = "double yeah"})
  
  local title = text_box({text = os.date('%a %b %d, %H:%M')})
  data[_calendar].grid:add_child(title, 1, 1, 2, 1)

  data[_calendar].grid:add_child(data[_calendar].calendar, 1, 2, 1, 8)
  local events_label = text_box({text = "Events :"})
  
  data[_calendar].grid:add_child(events_label, 2, 2, 1, 1)
  _calendar.visible = true

  _calendar:set_widget(data[_calendar].grid)
  _calendar.visible = true
  
  return _calendar
end

function ext_calendar.mt:__call(...)
  return ext_calendar.new(...)
end

return setmetatable(ext_calendar, ext_calendar.mt)
