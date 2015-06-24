-- @author cedlemo
local awful = require('awful')
local capi = { screen = screen, mouse = mouse }
local helpers = require('blingbling.helpers')
local text_box = require('blingbling.text_box')
local superproperties = require('blingbling.superproperties')
local math = math
local util = require('awful.util')
local wibox = require('wibox')
local pairs = pairs
local layout = require('wibox.layout')
local calendar = { mt = {} }
local data = setmetatable({}, { __mode = "k" })


---Calendar widget.
--Show current month user can navigate through previous or next month with two button. The top centered button with current mont string allow user to reload the current month.
--User can get events from remind and taskwarrior and can add their own events handler.
--@module blingbling.calendar

---Set the style of the previous and next month button.
--@usage mycalendar:set_prev_next_widget_style(style)
--@name set_prev_next_widget_style
--@class function
--@param style a table of parameters (see text_box widget in order to find which ones are available)

---Set the style of the current date text_box widget.
--@usage mycalendar:set_current_date_widget_style(style)
--@name set_current_date_widget_style
--@class function
--@param style a table of parameters (see text_box widget in order to find which ones are available)

---Define the style of the cells that contains the week days names.
--@usage mycalendar:set_days_of_week_widget_style(style)
--@name set_days_of_week_widget_style
--@class function
--@param style a table of parameters (see text_box widget in order to find which ones are available)

---Set the style of the days of the month widget.
--@usage mycalendar:set_days_of_month_widget_style(style)
--@name set_days_of_month_widget_style
--@class function
--@param style a table of parameters (see text_box widget in order to find which ones are available)

---Define the style of the cells that displays the week number (left column).
--@usage mycalendar:set_weeks_number_widget_style(style)
--@name set_weeks_number_widget_style
--@class function
--@param style a table of parameters (see text_box widget in order to find which ones are available)

---Set the style of the cell used as a corner between the week days line and the week number column.
--@usage mycalendar:set_corner_widget_style(style)
--@name set_corner_widget_style
--@class function
--@param style a table of parameters (see text_box widget in order to find which ones are available)

---Define the style used in order to show the current day.
--@usage mycalendar:set_current_day_widget_style(style)
--@name set_current_day_widget_style
--@class function
--@param style a table of parameters (see text_box widget in order to find which ones are available)

---Define the style used when the mouse pass on a cell (only active is set_link_to_external_calendar(true)).
--@usage mycalendar:set_focus_widget_style(style)
--@name set_focus_widget_style
--@class function
--@param style a table of parameters (see text_box widget in order to find which ones are available)

---Define the style of the big widget on the right that displays information (current day or external calendar events).
--@usage mycalendar:set_info_cell_style
--@name set_info_cell_style
--@class function
--@param style a table of parameters (see text_box widget in order to find which ones are available)

---Allow to get information from external calendar.
--@usage mycalendar:set_link_to_external_calendar(boolean)
--@name set_link_to_external_calendar
--@class function
--@param boolean true or false

---Use a specific locale for the week days.
--@usage mycalendar:set_locale(locale)
--@name set_locale
--@class function
--@param locale a string

---Add new function in order to get events from external application.
--This method let the taskwarrior and remind links intact and add your founction.
--@name append_function_get_events_from
--@usage mycalendar:append_function_get_events_from(function(day, month, year)
--s="third function ".. " " .. day .. " " .. month .." " ..year
--return s
--end)
--This  function display in the menu the string "third function 26 11 2011" for example.
--@class function
--@param my_function a function that you write

---Add new function in order to get events from external application and remove the existing function.
--@name clear_and_add_function_get_events_from
--@usage mycalendar:clear_and_add_function_get_events_from(my_function)
--@class function
--@param my_function a function that you write

local function apply_style(widget, style)
	for k,v in pairs(style) do
		if widget['set_'..k] ~= nil and type(widget['set_'..k]) == "function" then
			widget['set_' ..k](widget, v)
		end
	end
end

function show_events(calendarbutton,day_label, month, year, function_index)
  local day = tonumber(day_label)
  local month = month
  local year = year

  if function_index == nil then
    data[calendarbutton].get_events_function_index = 1
  elseif function_index == 1 and data[calendarbutton].get_events_function_index == #data[calendarbutton].get_events_from then
    data[calendarbutton].get_events_function_index = 1
  elseif function_index == -1 and data[calendarbutton].get_events_function_index == 1 then
    data[calendarbutton].get_events_function_index = #data[calendarbutton].get_events_from
  else
    data[calendarbutton].get_events_function_index = data[calendarbutton].get_events_function_index + function_index
  end

  local day_events=data[calendarbutton].get_events_from[data[calendarbutton].get_events_function_index](day,month,year)
  data[calendarbutton].info:set_text(day_events)
end

local function add_focus(calendarbutton)
	data[calendarbutton].next_month.widget:connect_signal("mouse::enter", function() apply_style(data[calendarbutton].next_month.widget,data[calendarbutton].focus_widget_style) end)
	data[calendarbutton].next_month.widget:connect_signal("mouse::leave", function() apply_style(data[calendarbutton].next_month.widget,data[calendarbutton].prev_next_widget_style) end)
	data[calendarbutton].prev_month.widget:connect_signal("mouse::enter", function() apply_style(data[calendarbutton].prev_month.widget,data[calendarbutton].focus_widget_style) end)
	data[calendarbutton].prev_month.widget:connect_signal("mouse::leave", function() apply_style(data[calendarbutton].prev_month.widget,data[calendarbutton].prev_next_widget_style) end)
	data[calendarbutton].date.widget:connect_signal("mouse::enter", function() apply_style(data[calendarbutton].date.widget,data[calendarbutton].focus_widget_style) end)
	data[calendarbutton].date.widget:connect_signal("mouse::leave", function() apply_style(data[calendarbutton].date.widget,data[calendarbutton].current_date_widget_style) end)

	if data[calendarbutton].link_to_external_calendar == true then
		--remove all previous handlers :
		for i=1,42 do
			if data[calendarbutton].month_days_cells[i].focus_handler ~= nil then
				data[calendarbutton].month_days_cells[i].widget:disconnect_signal("mouse::enter", data[calendarbutton].month_days_cells[i].focus_handler )
				data[calendarbutton].month_days_cells[i].widget:buttons({})
			end
		end
		--get current day cell if we are in current month view
		local	current_day_cell = tonumber(os.date("%d")) + data[calendarbutton].first_day_widget -1

		for i=data[calendarbutton].first_day_widget,data[calendarbutton].last_day_widget -1 do
			data[calendarbutton].month_days_cells[i].focus_handler =function()
				apply_style(data[calendarbutton].month_days_cells[i].widget, data[calendarbutton].focus_widget_style)
				show_events(calendarbutton,i -data[calendarbutton].first_day_widget +1  , data[calendarbutton].month, data[calendarbutton].year)
			end
			data[calendarbutton].month_days_cells[i].widget:connect_signal("mouse::enter",
				data[calendarbutton].month_days_cells[i].focus_handler
			)
			data[calendarbutton].month_days_cells[i].widget:buttons(util.table.join(
				awful.button({ }, 4, function()
					show_events(calendarbutton,i -data[calendarbutton].first_day_widget +1  , data[calendarbutton].month, data[calendarbutton].year, 1)
				end),
				awful.button({ }, 5, function()
					show_events(calendarbutton,i -data[calendarbutton].first_day_widget +1  , data[calendarbutton].month, data[calendarbutton].year, -1)
				end)
			))
			if current_day_cell ~= nil and i == current_day_cell then
				data[calendarbutton].month_days_cells[i].widget:connect_signal("mouse::leave",
					function()
						if tonumber(os.date("%m")) == data[calendarbutton].month and data[calendarbutton].year == tonumber(os.date("%Y")) then
							apply_style(data[calendarbutton].month_days_cells[i].widget, data[calendarbutton].current_day_widget_style)
						else
							apply_style(data[calendarbutton].month_days_cells[i].widget, data[calendarbutton].days_of_month_widget_style)
						end
            local text_info = nil
            if data[calendarbutton].default_info == nil then
						  text_info = os.date("%A %B %d %Y")
            end
            if type(data[calendarbutton].default_info) == "string" then
              text_info = data[calendarbutton].default_info
            end
            if type(data[calendarbutton].default_info) == "function" then
              text_info = data[calendarbutton].default_info()
            end
            data[calendarbutton].info:set_text(text_info)
					end
				)
			else
				data[calendarbutton].month_days_cells[i].widget:connect_signal("mouse::leave",
					function()
						apply_style(data[calendarbutton].month_days_cells[i].widget, data[calendarbutton].days_of_month_widget_style)
						local text_info = nil
            if data[calendarbutton].default_info == nil then
						  text_info = os.date("%A %B %d %Y")
            end
            if type(data[calendarbutton].default_info) == "string" then
              text_info = data[calendarbutton].default_info
            end
            if type(data[calendarbutton].default_info) == "function" then
              text_info = data[calendarbutton].default_info()
            end
            data[calendarbutton].info:set_text(text_info)
            --data[calendarbutton].info:set_text(data[calendarbutton].default_info or os.date("%A %B %d %Y"))
					end
				)
			end
		end
	end
end

local function fill_calendar(calendarbutton)
	local month_label = os.date("%B", os.time{year=data[calendarbutton].year, month=data[calendarbutton].month, day=01})
	data[calendarbutton].date.widget:set_text(month_label .. " " .. data[calendarbutton].year)

	local weeks_numbers = helpers.get_ISO8601_weeks_number_of_month(data[calendarbutton].month,data[calendarbutton].year)
	for i=1,6 do
		data[calendarbutton].weeks_number[i].widget:set_text(weeks_numbers[i])
	end

	local first_day_of_current_month = 0
  --find the first week day of the month it is the number used as start for displaying day in the table data[calendar].days_of_month
  local d=os.date('*t',os.time{year=data[calendarbutton].year,month=data[calendarbutton].month,day=01})
  --We use Monday as first day of week
  first_day_of_current_month = d['wday'] - 1
  if first_day_of_current_month == 0 then first_day_of_current_month = 7 end
  data[calendarbutton].first_day_widget = first_day_of_current_month
	local last_day_of_current_month = tonumber(helpers.get_days_in_month(data[calendarbutton].month, data[calendarbutton].year))
	data[calendarbutton].last_day_widget = last_day_of_current_month +first_day_of_current_month
	local y=1
	for i=1,42 do
		if i< first_day_of_current_month then
			data[calendarbutton].month_days_cells[i].widget:set_text(util.escape("--"))
			apply_style(data[calendarbutton].month_days_cells[i].widget, data[calendarbutton].days_of_month_widget_style)
		elseif i>= first_day_of_current_month and i < last_day_of_current_month +first_day_of_current_month  then
			data[calendarbutton].month_days_cells[i].widget:set_text(y)
			--TODO After seeing current month, next or prev month let the current date cell with the style of current date event for different month
			--Better if we check that if we are not in current month and set the current day cell to normal color rather than applying normal color to all cell each time
			apply_style(data[calendarbutton].month_days_cells[i].widget, data[calendarbutton].days_of_month_widget_style)
			y=y+1
		else
			data[calendarbutton].month_days_cells[i].widget:set_text(util.escape("--"))
			apply_style(data[calendarbutton].month_days_cells[i].widget, data[calendarbutton].days_of_month_widget_style)
		end
	end
	--mark current day if it's current month
	if tonumber(os.date("%m")) == data[calendarbutton].month and data[calendarbutton].year == tonumber(os.date("%Y")) then
		local current_day = tonumber(os.date("%d"))
		apply_style(data[calendarbutton].month_days_cells[current_day + first_day_of_current_month -1].widget, data[calendarbutton].current_day_widget_style)
	end
	--mark events from specific function
	if data[calendarbutton].link_to_external_calendar == true then
	--TODO get the days events and mark them with a style modification
	end
	--set current date in the info panel
	local text_info = nil
            if data[calendarbutton].default_info == nil then
						  text_info = os.date("%A %B %d %Y")
            end
            if type(data[calendarbutton].default_info) == "string" then
              text_info = data[calendarbutton].default_info
            end
            if type(data[calendarbutton].default_info) == "function" then
              text_info = data[calendarbutton].default_info()
            end

           data[calendarbutton].info:set_text(text_info)
--data[calendarbutton].info:set_text(data[calendarbutton].default_info or os.date("%A %B %d %Y"))
end

local function reload_and_fill(calendarbutton)
	fill_calendar(calendarbutton)
	add_focus(calendarbutton)
end

local function see_current_month(calendarbutton)
	data[calendarbutton].month = tonumber(os.date("%m"))
	data[calendarbutton].year = tonumber(os.date("%Y"))
	fill_calendar(calendarbutton)
	add_focus(calendarbutton)
end

local function see_prev_month(calendarbutton)
  if data[calendarbutton].month == 1 then
    data[calendarbutton].month = 12
    data[calendarbutton].year = data[calendarbutton].year -1
  else
    data[calendarbutton].month = data[calendarbutton].month - 1
  end
  fill_calendar(calendarbutton)
	add_focus(calendarbutton)
end

local function see_next_month(calendarbutton)
  if data[calendarbutton].month == 12 then
    data[calendarbutton].month = 1
    data[calendarbutton].year = data[calendarbutton].year +1
  else
    data[calendarbutton].month = data[calendarbutton].month + 1
  end
  fill_calendar(calendarbutton)
	add_focus(calendarbutton)
end

local function generate_calendar_box(calendarbutton)
	data[calendarbutton].title = layout.fixed.horizontal()
	--data[calendarbutton].title:fill_space(false)
	data[calendarbutton].column = layout.fixed.vertical()
	--data[calendarbutton].column:fill_space(true)
	data[calendarbutton].week_days_line = layout.flex.horizontal()
	--data[calendarbutton].week_days_line:fill_space(true)
	data[calendarbutton].week_days_cells = {}
	local line_height = 0
	local line_width = 0
	local max_line_width = 0
	local all_lines_height = 0
	local w,h =0
	local title_line_length = 0
	--margins left, right, top, bottom
	local ml = 2
	local mr = 2
	local mt = 2
	local mb = 2
		--create first line with prev, current date and next widget
	data[calendarbutton].date = {}
	data[calendarbutton].next_month = {}
	data[calendarbutton].prev_month = {}

	data[calendarbutton].prev_month.widget = text_box(data[calendarbutton].prev_next_widget_style)
	data[calendarbutton].prev_month.widget:set_text(util.escape("<<"))
	data[calendarbutton].prev_month.widget:buttons(util.table.join(
	        awful.button({ }, 1, function()
						see_prev_month(calendarbutton)
					end)
	))

	data[calendarbutton].prev_month.margin = layout.margin(data[calendarbutton].prev_month.widget, ml,mr,mt,mb)

	data[calendarbutton].date.widget = text_box(data[calendarbutton].current_date_widget_style)
	data[calendarbutton].date.widget:set_text(os.date('%a %b %d, %H:%M'))
	data[calendarbutton].date.widget:buttons(util.table.join(
	        awful.button({ }, 1, function()
						see_current_month(calendarbutton)
					end)
	))

	data[calendarbutton].date.margin = layout.margin(data[calendarbutton].date.widget, ml,mr,mt,mb)

	data[calendarbutton].next_month.widget = text_box(data[calendarbutton].prev_next_widget_style)
	data[calendarbutton].next_month.widget:set_text(util.escape(">>"))
	data[calendarbutton].next_month.widget:buttons(util.table.join(
	        awful.button({ }, 1, function()
						see_next_month(calendarbutton)
					end)
	))
	data[calendarbutton].next_month.margin = layout.margin(data[calendarbutton].next_month.widget, ml,mr,mt,mb)

	--add those 3 widgets and margins in the title line
	data[calendarbutton].title:add(data[calendarbutton].prev_month.margin)
	data[calendarbutton].title:add(data[calendarbutton].date.margin)
	data[calendarbutton].title:add(data[calendarbutton].next_month.margin)

	--create the days of week line
	line_width = 0
	line_height = 0
	max_height = 0
	max_width =0 --used as reference in order to calculate the width of the wibox
	data[calendarbutton].corner = {}
	data[calendarbutton].corner.widget = text_box(data[calendarbutton].corner_widget_style)
	data[calendarbutton].corner.widget:set_text(util.escape('/'))
	data[calendarbutton].corner.margin = layout.margin(data[calendarbutton].corner.widget, ml,mr,mt,mb)
	data[calendarbutton].week_days_line:add(data[calendarbutton].corner.margin)
	for i=1,7 do
		data[calendarbutton].week_days_cells[i] = {}
		data[calendarbutton].week_days_cells[i].widget = text_box(data[calendarbutton].days_of_week_widget_style)
		data[calendarbutton].week_days_cells[i].widget:set_text(data[calendarbutton].week_days[i])
		data[calendarbutton].week_days_cells[i].margin = layout.margin(data[calendarbutton].week_days_cells[i].widget, ml,mr,mt,mb)
	  w,h = data[calendarbutton].week_days_cells[i].margin:fit(0,0)
		max_width = max_width > w and max_width or w
		max_height = max_height > h and max_height or h
		data[calendarbutton].week_days_line:add(data[calendarbutton].week_days_cells[i].margin)
	end

	--Now that we have the longer width, we apply it to all the days of week widgets:
	data[calendarbutton].corner.widget:set_width(max_width)
	data[calendarbutton].corner.widget:set_height(max_height)
	for i=1,7 do
		data[calendarbutton].week_days_cells[i].widget:set_width(max_width)
		data[calendarbutton].week_days_cells[i].widget:set_height(max_height)
	end
	-- And we can calculate and set the width for the next, prev and current date widget:
	data[calendarbutton].date.widget:set_width(max_width *4)
	data[calendarbutton].date.widget:set_height(max_height)
	w,h = data[calendarbutton].date.margin:fit(0,0)
	local remains = math.floor((math.ceil((max_width + ml + mr )* 8 ) - (w + (ml+mr)*2))/2)
	data[calendarbutton].prev_month.widget:set_width(remains )
	data[calendarbutton].prev_month.widget:set_height(max_height )
	data[calendarbutton].next_month.widget:set_width(remains )
	data[calendarbutton].next_month.widget:set_height(max_height )

	--We create the month day cells
	data[calendarbutton].month_days_cells={}
	for i=01,42 do
		data[calendarbutton].month_days_cells[i]={}
		data[calendarbutton].month_days_cells[i].widget = text_box(data[calendarbutton].days_of_month_widget_style)
		data[calendarbutton].month_days_cells[i].widget:set_text(i)
		data[calendarbutton].month_days_cells[i].widget:set_width(max_width)
		data[calendarbutton].month_days_cells[i].widget:set_height(max_height)
		data[calendarbutton].month_days_cells[i].margin = layout.margin(data[calendarbutton].month_days_cells[i].widget, ml,mr,mt,mb)
	end
	--Week numbers
	data[calendarbutton].weeks_number={}
	for i=1,6 do
		data[calendarbutton].weeks_number[i]={}
		data[calendarbutton].weeks_number[i].widget = text_box(data[calendarbutton].weeks_number_widget_style)
		data[calendarbutton].weeks_number[i].widget:set_text(i)
		data[calendarbutton].weeks_number[i].widget:set_width(max_width)
		data[calendarbutton].weeks_number[i].widget:set_height(max_height)
		data[calendarbutton].weeks_number[i].margin = layout.margin(data[calendarbutton].weeks_number[i].widget,ml,mr,mt,mb)
	end
	--day cells are displayed in lines
	data[calendarbutton].month_days_lines = {}
	for i=1,6 do
		data[calendarbutton].month_days_lines[i] = layout.flex.horizontal()
		data[calendarbutton].month_days_lines[i]:add(data[calendarbutton].weeks_number[i].margin)
		for y=1,7 do
			data[calendarbutton].month_days_lines[i]:add(data[calendarbutton].month_days_cells[y +((i-1) *7)].margin)
		end
	end

	--All the previous stuff are displayed in a column
	data[calendarbutton].column:add(data[calendarbutton].title)
	data[calendarbutton].column:add(data[calendarbutton].week_days_line)
	for i=1,6 do
		data[calendarbutton].column:add(data[calendarbutton].month_days_lines[i])
	end
	data[calendarbutton].fullview = layout.flex.horizontal()
	data[calendarbutton].info = text_box( data[calendarbutton].info_cell_style)
	local text_info = nil
           if data[calendarbutton].default_info == nil then
						  text_info = os.date("%A %B %d %Y")
            end
            if type(data[calendarbutton].default_info) == "string" then
              text_info = data[calendarbutton].default_info
            end
            if type(data[calendarbutton].default_info) == "function" then
              text_info = data[calendarbutton].default_info()
            end

--data[calendarbutton].info:set_text(os.date("%A %B %d %Y"))
  data[calendarbutton].info:set_text(text_info)
	data[calendarbutton].info:set_height((max_height + mt +mr) * 8 )
	data[calendarbutton].info:set_width(math.ceil((max_width + ml + mr )* 8 ))
	data[calendarbutton].fullview:add(data[calendarbutton].column)
	data[calendarbutton].fullview:add(data[calendarbutton].info)
	--dirty hack in order to get the good layout size
	data[calendarbutton].info:fit(math.ceil((max_width + ml + mr )* 8 ), (max_height + mt +mr) * 8 )
	data[calendarbutton].calendarbox = wibox(	{ontop = true, width = math.ceil((max_width + ml + mr )* 8 ) *2,
																													height = (max_height + mt +mr) * 8})
	data[calendarbutton].calendarbox.visible =false
	data[calendarbutton].calendarbox:set_widget(data[calendarbutton].fullview)
	see_current_month(calendarbutton)
end

local function show_wibox(wibox)
	local current_screen = capi.mouse.screen
  local screen_geometry = capi.screen[current_screen].workarea
  local screen_w = screen_geometry.x + screen_geometry.width
  local screen_h = screen_geometry.y + screen_geometry.height
  local mouse_coords = capi.mouse.coords()
	local x,y =0
	y = mouse_coords.y < screen_geometry.y and screen_geometry.y or mouse_coords.y
	x = mouse_coords.x < screen_geometry.x and screen_geometry.x or mouse_coords.x
  y = y + wibox.height > ( screen_h - 10)and  screen_h - (wibox.height + 10) or y + 10
  x = x + wibox.width > ( screen_w - 10) and screen_w - ( wibox.width + 10) or x + 10
	wibox:geometry({	--width = wibox.width,
										--height = wibox.height,
										x = x ,
										y = y })
	wibox.visible = true
end

local function toggle_visibility(calendarbutton)
	calendarbutton:buttons( awful.util.table.join(
		awful.button({}, 1, function()
			if data[calendarbutton].calendarbox then
				if data[calendarbutton].calendarbox.visible ~= true then
					reload_and_fill(calendarbutton)
						--w,h = data[calendarbutton].info:fit(0,0)
	--helpers.dbg({w,h})
show_wibox(data[calendarbutton].calendarbox)
				else
					data[calendarbutton].calendarbox.visible = false
				end
			else
				generate_calendar_box(calendarbutton)
					--w,h = data[calendarbutton].info:fit(0,0)
	--helpers.dbg({w,h})
					reload_and_fill(calendarbutton)
show_wibox(data[calendarbutton].calendarbox)
			end
		end)
		)
	)
end
local properties = { "prev_next_widget_style", "current_date_widget_style", "days_of_week_widget_style", "days_of_month_widget_style", "weeks_number_widget_style", "corner_widget_style", "current_day_widget_style", "focus_widget_style", "info_cell_style", "link_to_external_calendar" }

-- Build properties function
for _, prop in ipairs(properties) do
	if not calendar["set_" .. prop] then
		calendar["set_" .. prop] = function(calendarbutton, value)
			data[calendarbutton][prop] = value
			calendarbutton:emit_signal("widget::updated")
			return calendarbutton
    end
  end
end

function append_function_get_events_from(calendarbutton, my_function)
   table.insert(data[calendarbutton].get_events_from, my_function)
   return self
end

function clear_and_add_function_get_events_from(calendarbutton, my_function)
  data[calendarbutton].get_events_from={}
  table.insert(data[calendarbutton].get_events_from, my_function)
   return calendar
end

function set_locale(calendarbutton, locale)
	os.setlocale(locale)
	data[calendarbutton].week_days = {}
	for i=6,12 do
		table.insert(data[calendarbutton].week_days,(os.date("%a",os.time({month=2,day=i,year=2012}))))
	end
	data[calendarbutton].months = {}
	for i=1,12 do
		table.insert(data[calendarbutton].months,os.date("%B",os.time({month=i,day=1,year=2012})))
	end
end

function set_default_info(calendarbutton, text)
  data[calendarbutton].default_info = text
end

function calendar.new(args)
	local args = args or {}

  local calendarbutton = args.widget or awful.widget.textclock(" %a %b %d, %H:%M")
  data[calendarbutton] = {}
	--get days and month labels
	if args.locale then
		os.setlocale(locale)
	end
	data[calendarbutton].week_days = {}
	for i=6,12 do
		table.insert(data[calendarbutton].week_days,(os.date("%a",os.time({month=2,day=i,year=2012}))))
	end
	data[calendarbutton].months = {}
	for i=1,12 do
		table.insert(data[calendarbutton].months,os.date("%B",os.time({month=i,day=1,year=2012})))
	end
	data[calendarbutton].prev_next_widget_style = superproperties.calendar.prev_next_widget_style
	data[calendarbutton].current_date_widget_style = superproperties.calendar.current_date_widget_style
	data[calendarbutton].days_of_week_widget_style = superproperties.calendar.days_of_week_widget_style
	data[calendarbutton].days_of_month_widget_style = superproperties.calendar.days_of_month_widget_style
	data[calendarbutton].weeks_number_widget_style = superproperties.calendar.weeks_number_widget_style
	data[calendarbutton].corner_widget_style = superproperties.calendar.corner_widget_style
	data[calendarbutton].current_day_widget_style = superproperties.calendar.current_day_widget_style
	data[calendarbutton].focus_widget_style = superproperties.calendar.focus_widget_style
	data[calendarbutton].info_cell_style = superproperties.calendar.info_cell_style

	toggle_visibility(calendarbutton)

	data[calendarbutton].link_to_external_calendar = false
  --This table contains the functions to access event from different agenda, can be extended.
	data[calendarbutton].get_events_from={
	--reminds
	function(day,month,year)
		local day_events=util.pread('remind -k\'echo %s\' ~/.reminders ' .. day .. " " .. os.date("%B",os.time{year=year,month=month,day=day}) .." " .. year)
	  day_events = string.gsub(day_events,"\n\n+","\n")
	  day_events  =string.gsub(day_events,"\n*$","")
	  day_events="Remind:\n" .. day_events
	  return day_events
	 end,
	--task_warrior
	function(day,month,year)
		local day_events=util.pread('task overdue due:' .. os.date("%m",os.time{year=year,month=month,day=day}) .."/"..day.."/" .. year)
		local day_events = "Task warrior:\n" .. day_events
	  return day_events
	 end,
	}
	for _, prop in ipairs(properties) do
	       calendarbutton["set_" .. prop] = calendar["set_" .. prop]
	end
	calendarbutton.clear_and_add_function_get_events_from = clear_and_add_function_get_events_from
	calendarbutton.append_function_get_events_from =append_function_get_events_from
	calendarbutton.set_locale = set_locale
	calendarbutton.set_default_info = set_default_info
	return calendarbutton
end

function calendar.mt:__call(...)
  return calendar.new(...)
end

return setmetatable(calendar, calendar.mt)

