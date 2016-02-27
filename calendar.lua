-- @author Cédric Le Moigne cedlemo
local helpers = require("blingbling.helpers")
local superproperties = require("blingbling.superproperties")
local grid = require("blingbling.grid")
local text_box = require("blingbling.text_box")
local awful = require("awful")
local util = awful.util 
local capi = { screen = screen, mouse = mouse }
local wibox = require("wibox")
local base = require("wibox.layout.base")
local pairs = pairs

local calendar = { mt = {} }
local data = setmetatable({}, { __mode = "k" })

local properties = { "prev_next_widget_style", "current_date_widget_style",
                     "days_of_week_widget_style", "days_of_month_widget_style",
                     "weeks_number_widget_style", "corner_widget_style", 
                     "current_day_widget_style", "focus_widget_style", 
                     "info_cell_style", "link_to_external_calendar" }

-- Build properties function
for _, prop in ipairs(properties) do
	if not calendar["set_" .. prop] then
		calendar["set_" .. prop] = function(cal, value)
			data[cal][prop] = value
			cal:emit_signal("widget::updated")
			return cal
    end
  end
end

local function generate_header_widgets(calendar)
  local props = data[calendar].props
  data[calendar].date = text_box(props.current_date_widget_style)
  data[calendar].date:set_text(os.date('%a %b %d, %H:%M'))

  data[calendar].prev_month = text_box(props.prev_month_widget_style)
  data[calendar].prev_month:set_text(util.escape("<<"))

  data[calendar].next_month = text_box(props.next_month_widget_style)
  data[calendar].next_month:set_text(util.escape(">>"))
end

local function generate_week_day_names()
  names = {}
	for i=6,12 do
		table.insert(names,(os.date("%a",os.time({month=2,day=i,year=2012}))))
	end
  return names
end

local function generate_week_days(calendar)
  names = generate_week_day_names()
  data[calendar].week_days = {}
  local props = data[calendar].props
  
  for i, n in ipairs(names) do
    data[calendar].week_days[i] = text_box(props.days_of_week_style)
    data[calendar].week_days[i]:set_text(n) 
  end
end
local function generate_weeks_numbers(calendar)
	local numbers = helpers.get_ISO8601_weeks_number_of_month(data[calendar].month,
                                                                  data[calendar].year)
  local props = data[calendar].props
	data[calendar].weeks_numbers = {}
  for i=1,6 do
    data[calendar].weeks_numbers[i] = text_box(props.weeks_number_style)
		data[calendar].weeks_numbers[i]:set_text(numbers[i])
	end
end

local function generate_days_of_month(calendar)
  data[calendar].days_of_month = {}
  for i=1,42 do
    data[calendar].days_of_month[i] = text_box(data[calendar].props.days_of_month_widget_style)
  end
end

local function generate_widgets(calendar)
  generate_header_widgets(calendar)
  generate_week_days(calendar)
  generate_weeks_numbers(calendar)
  generate_days_of_month(calendar)
end

local function add_header_widgets(calendar)
  calendar:add_child(data[calendar].prev_month, 1, 1, 1, 1)
  calendar:add_child(data[calendar].date, 3, 1, 4, 1)
  calendar:add_child(data[calendar].next_month, 8, 1, 1, 1)
end

local function add_week_days(calendar)
  for i,v in ipairs(data[calendar].week_days) do
    calendar:add_child(v, i + 1, 2, 1, 1)
  end
end

local function add_weeks_numbers(calendar)
  for i, w in ipairs(data[calendar].weeks_numbers) do
    calendar:add_child(w, 1, 2 + i, 1, 1)
  end
end

local function add_days_of_month(calendar)
  for y=1,6 do
    for x=1,7 do
      local index = x + ((y - 1 ) * 7)
      local child = data[calendar].days_of_month[index]
      calendar:add_child(child, 1 + x, 2 + y, 1, 1)
    end
  end
end

local function fill_grid(calendar)
  add_header_widgets(calendar)
  add_week_days(calendar)
  add_weeks_numbers(calendar)
  add_days_of_month(calendar)
end

local function get_current_month_year(calendar)
	data[calendar].month = tonumber(os.date("%m"))
	data[calendar].year = tonumber(os.date("%Y"))
end

local function find_first_last_days_of_month(calendar)
  --find the first week day of the month
  --it is the number used as start for displaying day in the 
  --table data[calendar].days_of_month
  local d = os.date('*t',
                    os.time{year = data[calendar].year,
                            month = data[calendar].month,
                            day = 01}
                    )
  --We use Monday as first day of week
  local day_1 = d['wday'] - 1 == 0 and 7 or d["wday"]
  
	local day_n = helpers.get_days_in_month(data[calendar].month, data[calendar].year)
  data[calendar].day_1 = day_1
  data[calendar].day_n = tonumber(day_n)
end

local function display_days_of_month(calendar)
  find_first_last_days_of_month(calendar)
  local days = data[calendar].days_of_month
  local day_1 = data[calendar].day_1
  local day_n = data[calendar].day_n
  local day_number = 0
  for i=1,42 do
    if i < day_1 then
      days[i]:set_text("-")
    elseif i> day_n then
      days[i]:set_text("-")
    else
      day_number = day_number + 1
      days[i]:set_text(day_number)
    end
  end
end

function calendar.new(args)
  local args = args or {}
  local _calendar = grid()
  
  if args.locale then
		os.setlocale(locale)
	end
  
  data[_calendar] = {}
  data[_calendar].props =  helpers.load_properties(properties,
                                                  data,
                                                  _calendar,
                                                  superproperties.calendar)

  get_current_month_year(_calendar)
  generate_widgets(_calendar)
  fill_grid(_calendar)
  display_days_of_month(_calendar)
  return _calendar
end

function calendar.mt:__call(...)
  return calendar.new(...)
end

return setmetatable(calendar, calendar.mt)
