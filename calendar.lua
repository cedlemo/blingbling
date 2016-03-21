-- @author Cédric Le Moigne cedlemo
local helpers = require("blingbling.helpers")
local superproperties = require("blingbling.superproperties")
local grid = require("blingbling.grid")
local text_box = require("blingbling.text_box")
local awful = require("awful")
local util = awful.util
local pairs = pairs

local calendar = { mt = {} }
local data = setmetatable({}, { __mode = "k" })

local properties = { "prev_next_widget_style", "current_date_widget_style",
                     "days_of_week_widget_style", "days_of_month_widget_style",
                     "weeks_number_widget_style", "current_day_widget_style",
                     "focus_widget_style", "focus_days", "focus_days_enter_callback",
                     "focus_days_leave_callback"}


local function get_month_name(calendar)
  local month_name = os.date("%B",
                             os.time{ year = data[calendar].year,
                                      month = data[calendar].month,
                                      day=01
                                    }
                            )
  return month_name
end

local function get_date_label(calendar)
  local year = tostring(data[calendar].year)
  return get_month_name(calendar) .. " " .. year
end

local function generate_header_widgets(calendar)
  local props = data[calendar].props
  data[calendar].date = text_box(props.current_date_widget_style)
  data[calendar].date:set_text(get_date_label(calendar))

  data[calendar].prev_month = text_box(props.prev_next_widget_style)
  data[calendar].prev_month:set_text(util.escape("<<"))

  data[calendar].next_month = text_box(props.prev_next_widget_style)
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

local function set_weeks_numbers(calendar)
	local numbers = helpers.get_ISO8601_weeks_number_of_month(data[calendar].month,
  data[calendar].year)
  for i,w in ipairs(data[calendar].weeks_numbers) do
    w:set_text(numbers[i])
  end
end

local function generate_weeks_numbers(calendar)
  local props = data[calendar].props
	data[calendar].weeks_numbers = {}
  for i=1,6 do
    data[calendar].weeks_numbers[i] = text_box(props.weeks_number_style)
	end
  set_weeks_numbers(calendar)
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
  -- TODO is it ok with other locale ?
  local day_1 = d['wday'] - 1 == 0 and 7 or d["wday"]

	local day_n = helpers.get_days_in_month(data[calendar].month, data[calendar].year)
  data[calendar].day_1 = day_1
  data[calendar].day_n = tonumber(day_n)
end

local function hide_day_of_month_cell(text_box)
  text_box:set_text("")
  text_box:set_background_color("#00000000")
  text_box:set_text_background_color("#00000000")
  text_box:set_background_text_border("#0000000")
end

local function apply_style(widget, style)
	for k,v in pairs(style) do
		if widget['set_'..k] ~= nil and type(widget['set_'..k]) == "function" then
			widget['set_' ..k](widget, v)
		end
	end
end
local function is_current_month(calendar)
  local current_month = tonumber(os.date("%m"))
  local current_year = tonumber(os.date("%Y"))
  if data[calendar].year == current_year and
     data[calendar].month == current_month then
    return true
  else
    return false
  end
end

local function display_days_of_month(calendar)
  find_first_last_days_of_month(calendar)
  local days = data[calendar].days_of_month
  local day_1 = data[calendar].day_1
  local day_n = data[calendar].day_n
  local day_number = 0

  for i=1,42 do
    if i < day_1 - 1 then
      hide_day_of_month_cell(days[i])
    elseif i >= (day_n + day_1 - 1)  then
      hide_day_of_month_cell(days[i])
    else
      day_number = day_number + 1
      local current_day = tonumber(os.date("%d"))
      days[i]:set_text(day_number)
      if is_current_month(calendar) and current_day == day_number then
        apply_style(days[i],
                    data[calendar].props.current_day_widget_style)
      else
        apply_style(days[i],
                    data[calendar].props.days_of_month_widget_style)
      end
    end
  end
end

local function add_focus_style(widget, focus, normal)
	widget:connect_signal("mouse::enter",
                        function()
                          if widget._layout.text ~= "" then
                            apply_style(widget, focus)
                          end
                        end)
	widget:connect_signal("mouse::leave",
                        function()
                          if widget._layout.text ~= "" then
                            apply_style(widget, normal)
                          end
                        end)
end

local function add_focus_style_with_ref(widget, focus, normal, refs)
	refs.mouse_enter[widget] = function()
                          if widget._layout.text ~= "" then
                            apply_style(widget, focus)
                          end
                        end
  widget:connect_signal("mouse::enter", refs.mouse_enter[widget])

  refs.mouse_leave[widget] = function()
                          if widget._layout.text ~= "" then
                            apply_style(widget, normal)
                          end
                        end
	widget:connect_signal("mouse::leave", refs.mouse_leave[widget])
end

local function add_focus_signals_on_date_prev_next(calendar, props)
  local focus = props.focus_widget_style
  local normal = props.prev_next_widget_style
  add_focus_style(data[calendar].prev_month, focus, normal)
  add_focus_style(data[calendar].next_month, focus, normal)
  normal = props.current_date_widget_style
  add_focus_style(data[calendar].date, focus, normal)
end

local function reset_focus(calendar, widget)
	local enter_fn = data[calendar].focus_handlers_ref.mouse_enter[widget]
	local leave_fn = data[calendar].focus_handlers_ref.mouse_leave[widget]

  if enter_fn then
    widget:disconnect_signal("mouse::enter", enter_fn)
  end
  if leave_fn then
    widget:disconnect_signal("mouse::leave", leave_fn)
  end
end

local function add_focus_leave_enter_callbacks(widget, calendar)
  local enter_cb = data[calendar].focus_days_enter_callback
  local leave_cb = data[calendar].focus_days_leave_callback
	local m = data[calendar].month
	local y = data[calendar].year
  if enter_cb ~= nil then
    widget:connect_signal("mouse::enter",
                          function()
                            if widget._layout.text ~= "" then
                              local callback = enter_cb.cb
                              local data = enter_cb.data
                              callback(widget, m, y, data)
                            end
                          end)
  end
  if leave_cb ~= nil then
    widget:connect_signal("mouse::leave",
                          function()
                            if widget._layout.text ~= "" then
                              local callback = leave_cb.cb
                              local data = leave_cb.data
                              callback(widget, m, y, data)
                            end
                          end)
  end
end

local function add_focus_signals_on_days_of_month(calendar, props)
  local focus = props.focus_widget_style
  local normal = props.days_of_month_widget_style
  local current = props.current_day_widget_style

  find_first_last_days_of_month(calendar)
  local days = data[calendar].days_of_month
  local day_1 = data[calendar].day_1
  local day_n = data[calendar].day_n
  local day_number = 0
  for i=1,42 do
    add_focus_leave_enter_callbacks(days[i], calendar)
    if i < day_1 - 1 then
      reset_focus(calendar, days[i])
    elseif i >= (day_n + day_1 - 1)  then
      reset_focus(calendar, days[i])
    else
      reset_focus(calendar, days[i])
      day_number = day_number + 1
      local current_day = tonumber(os.date("%d"))
      if is_current_month(calendar) and current_day == day_number then
        add_focus_style_with_ref(days[i], focus, current,
                                 data[calendar].focus_handlers_ref)
      else
        add_focus_style_with_ref(days[i], focus, normal,
                                 data[calendar].focus_handlers_ref)
      end
    end
  end

end

local function add_focus_signals(calendar)
  local props = data[calendar].props
  add_focus_signals_on_date_prev_next(calendar, props)
  if data[calendar].focus_days == true then
    add_focus_signals_on_days_of_month(calendar, props)
  end
end

local function next_month(calendar)
  if data[calendar].month == 12 then
    data[calendar].month = 1
    data[calendar].year = data[calendar].year + 1
  else
    data[calendar].month = data[calendar].month + 1
  end
end

local function prev_month(calendar)
  if data[calendar].month == 1 then
    data[calendar].month = 12
    data[calendar].year = data[calendar].year - 1
  else
    data[calendar].month = data[calendar].month - 1
  end
end

local function add_change_month_signals(calendar)
  data[calendar].prev_month:buttons(util.table.join(
	        awful.button({ }, 1, function()
					  prev_month(calendar)
            display_days_of_month(calendar)
            set_weeks_numbers(calendar)
            data[calendar].date:set_text(get_date_label(calendar))
            if data[calendar].focus_days == true then
              add_focus_signals_on_days_of_month(calendar, data[calendar].props)
            end
          end)
          ))
  data[calendar].next_month:buttons(util.table.join(
	        awful.button({ }, 1, function()
					  next_month(calendar)
            display_days_of_month(calendar)
            set_weeks_numbers(calendar)
            data[calendar].date:set_text(get_date_label(calendar))
            if data[calendar].focus_days == true then
              add_focus_signals_on_days_of_month(calendar, data[calendar].props)
            end
          end)
          ))
  data[calendar].date:buttons(util.table.join(
	        awful.button({ }, 1, function()
            get_current_month_year(calendar)
            display_days_of_month(calendar)
            set_weeks_numbers(calendar)
            data[calendar].date:set_text(get_date_label(calendar))
            if data[calendar].focus_days == true then
              add_focus_signals_on_days_of_month(calendar, data[calendar].props)
            end
          end)
          ))
end

function calendar.new(args)
  local args = args or {}
  local _calendar = grid()

  if args.locale then
    os.setlocale(args.locale)
	end

  data[_calendar] = {}
  data[_calendar].focused_day = nil

  -- Used to keep tracks of the function used to change the focus
  -- in order to be able to delete them and change them
  -- a text_box can be an empty day, a normal day or the current
  -- day depending on the month we choose to display
  data[_calendar].focus_handlers_ref = {}
  data[_calendar].focus_handlers_ref.mouse_enter = {}
  data[_calendar].focus_handlers_ref.mouse_leave = {}

  for _, prop in ipairs(properties) do
    data[_calendar][prop] = args[prop]
  end

  data[_calendar].props =  helpers.load_properties(properties,
                                                  data,
                                                  _calendar,
                                                  superproperties.calendar)

  get_current_month_year(_calendar)
  generate_widgets(_calendar)
  fill_grid(_calendar)
  display_days_of_month(_calendar)
  add_focus_signals(_calendar)
  add_change_month_signals(_calendar)

  -- Build properties function
  for _, prop in ipairs(properties) do
	  if not _calendar["set_" .. prop] then
		  _calendar["set_" .. prop] = function(cal, value)
			  data[cal][prop] = value
			  return cal
      end
    end
  end

  return _calendar
end

function calendar.mt:__call(...)
  return calendar.new(...)
end

return setmetatable(calendar, calendar.mt)
