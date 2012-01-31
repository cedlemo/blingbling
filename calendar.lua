local table = table
local type = type
local os = require('os')
local string =string
local pairs = pairs
local ipairs = ipairs
local tonumber = tonumber
local mouse = mouse
local screen = screen
local setmetatable = setmetatable

local util = require('awful.util') 
local button = require('awful.button') 
local wibox = require("wibox") --awesome wibox layout
local awful = require("awful") --create wibox
local imagebox = require("wibox.widget.imagebox")
local beautiful = require('beautiful')
local helpers = require('blingbling.helpers')
local blingbling = { layout = require('blingbling.wibox.layout'), text_box= require('blingbling.text_box')}

module('blingbling.calendar')

local data = setmetatable( {}, { __mode = "k"})

local properties = { "width","margin", "inter_margin", "cell_background_color", "cell_padding", "rounded_size", "text_color", "font_size", "title_background_color", "title_text_color", "title_font_size", "columns_lines_titles_background_color", "columns_lines_titles_text_color", "columns_lines_titles_font_size", "link_to_external_calendar"}

function bind_click_to_toggle_visibility(calendar)
  calendar:buttons(util.table.join(
    button({ }, 1, function()
      if data[calendar].calendarbox then
        if data[calendar].calendarbox.visible ~= true then 
          generate_cal(calendar)
          add_focus(calendar)
          data[calendar].calendarbox.visible = true
        else 
          data[calendar].calendarbox.visible = false
        end
      else
        generate_cal(calendar)
        add_focus(calendar)
        data[calendar].calendarbox.visible= true
      end
      return calendar
    end
    )
))
end
function display_new_month( calendar,month, year)
  local month_label = os.date("%B", os.time{year=year, month=month, day=01})
  local padding = data[calendar].cell_padding or 4 
  local background_color = data[calendar].cell_background_color or "#00000066"
  local rounded_size = data[calendar].rounded_size or 0.4
  local text_color = data[calendar].text_color or "#ffffffff"
  local font_size = data[calendar].font_size or 9
  local title_background_color = data[calendar].title_background_color or background_color
  local title_text_color = data[calendar].title_text_color or text_color
  local title_font_size = data[calendar].title_font_size or font_size + 1 
  
  data[calendar].displayed_month_year:set_text(month_label)
  
  local last_day_of_current_month = tonumber(helpers.get_days_in_month(month, year))
  local current_day_of_month= tonumber(os.date("%d")) 
  local current_month = tonumber(os.date("%m"))
  
  local d=os.date('*t',os.time{year=year,month=month,day=01})
  --We use Monday as first day of week
  first_day_of_month = d['wday'] - 1
  if first_day_of_month == 0 then first_day_of_month = 7 end 
  data[calendar].first_day_widget = first_day_of_month
  
  local day_of_month = 0 
  for i=1,42 do
  --generate cells  before the first day
    if i < first_day_of_month then
      data[calendar].days_of_month[i].widget:set_text("--")
      data[calendar].days_of_month[i].text = "--" 
    end
    if i>= first_day_of_month and i < last_day_of_current_month + first_day_of_month then
      if i == current_day_of_month + first_day_of_month -1 and current_month == month then
        background = beautiful.bg_focus
        color = beautiful.fg_focus
      else  
        background = background_color
        color = text_color
      end
      day_of_month = day_of_month + 1
      --Had 0 before the day if the day is inf to 10
      if day_of_month < 10 then
        day_of_month = "0" .. day_of_month
      else
        day_of_month = day_of_month ..""
      end
      data[calendar].days_of_month[i].widget:set_text(day_of_month)
      data[calendar].days_of_month[i].text = day_of_month
      data[calendar].days_of_month[i].widget:set_background_color(background)
      data[calendar].days_of_month[i].widget:set_text_color(color)
    end
    if i >= last_day_of_current_month  + first_day_of_month then
      data[calendar].days_of_month[i].widget:set_text("--")
      data[calendar].days_of_month[i].text = "--" 
    end
  end
end

function see_prev_month(calendar, month, year)
  if month == 1 then
    month = 12 
    year = year -1 
  else
    month = month - 1
  end
  data[calendar].month = month
  data[calendar].year = year
  display_new_month(calendar,month, year)
end
function see_next_month(calendar, month, year)
  if month == 12 then
    month = 1 
    year = year +1 
  else
    month = month + 1
  end
  data[calendar].month = month
  data[calendar].year = year
  display_new_month(calendar,month, year)
end

function generate_cal(calendar)
  --all data that we put in data[calendar] that can be access for  each instance of calendar objetcs:
  --data[calendar].displayed_month_year the widget image for month year title displayed
  --data[calendar].month = the month displayed
  --data[calendar].year = the year displayed
  --data[calendar].days_of_month a table containing the widget of the day of month (empty or not )
  --data[calendar].first_day_widget the number used as start for displaying day in the table data[calendar].days_of_month
  --data[calendar].prev_month widget used to change displayed month to previous month
  --data[calendar].next_month widget used to change displayed month to next month

  local wibox_margin = data[calendar].margin or 2
  local padding = data[calendar].cell_padding or 4 
  local inter_margin = data[calendar].inter_margin or 2
  local background_color = data[calendar].cell_background_color or "#00000066"
  local rounded_size = data[calendar].rounded_size or 0.4
  local text_color = data[calendar].text_color or "#ffffffff"
  local font_size = data[calendar].font_size or 9
  local title_background_color = data[calendar].title_background_color or background_color
  local title_text_color = data[calendar].title_text_color or text_color
  local title_font_size = data[calendar].title_font_size or font_size + 2
  local columns_lines_titles_background_color = data[calendar].columns_lines_titles_background_color or background_color
  local columns_lines_titles_text_color = data[calendar].columns_lines_titles_text_color or text_color
  local columns_lines_titles_font_size = data[calendar].columns_lines_titles_font_size or font_size
  --Get screen and position informations
  local current_screen = mouse.screen
  local screen_geometry = screen[current_screen].workarea
  local screen_w = screen_geometry.x + screen_geometry.width
  local screen_h = screen_geometry.y + screen_geometry.height
  local mouse_coords = mouse.coords()
  local all_lines_height = 0

  local day_labels = { "Mo", "Tu", "We", "Th", "Fr","Sa" , "Su"}
  data[calendar].days_of_month={}
  local weeks_of_year={}
  local current_day_of_month= tonumber(os.date("%d")) 
  local month_displayed = tonumber(os.date("%m"))
  local year_displayed = tonumber(os.date("%Y"))
  
  data[calendar].month = month_displayed
  data[calendar].year = year_displayed
  
  local first_day_of_month = 0
  --find the first week day of the month it is the number used as start for displaying day in the table data[calendar].days_of_month
  local d=os.date('*t',os.time{year=year_displayed,month=month_displayed,day=01})
  --We use Monday as first day of week
  first_day_of_month = d['wday'] - 1
  if first_day_of_month == 0 then first_day_of_month = 7 end 
  data[calendar].first_day_widget = first_day_of_month
  
  local last_day_of_current_month = tonumber(helpers.get_days_in_month(month_displayed, year_displayed))
  local max_day_cells = 42 
  local day_of_month = 0 
  local day_widgets={}
  
  --generate title cells with displayed month and year
  data[calendar].displayed_month_year = blingbling.text_box.new({text = os.date("%B %Y")})
  data[calendar].displayed_month_year:set_padding(padding)
  data[calendar].displayed_month_year:set_rounded_size(rounded_size)
  data[calendar].displayed_month_year:set_background_color(title_background_color)
  data[calendar].displayed_month_year:set_font_size(title_font_size)
  data[calendar].displayed_month_year:set_text_color(title_color)    
  --generate cells for precedent month and next month:
  data[calendar].prev_month = blingbling.text_box.new({text = "<<"})
  data[calendar].prev_month:set_padding(padding)
  data[calendar].prev_month:set_rounded_size(rounded_size)
  data[calendar].prev_month:set_background_color(title_background_color)
  data[calendar].prev_month:set_font_size(title_font_size)
  data[calendar].prev_month:set_text_color(title_color)    
  --Add focus on the widget:
  data[calendar].prev_month:connect_signal("mouse::enter", function(widget)
    widget:set_background_color(beautiful.bg_focus)
    widget:set_text_color(beautiful.fg_focus)    
  end)
  data[calendar].prev_month:connect_signal("mouse::leave", function(widget)
    widget:set_background_color(title_background_color)
    widget:set_text_color(title_text_color)    
  end)
  --Link action on the widget:
  data[calendar].prev_month:buttons(util.table.join(
       button({ }, 1, function()
        see_prev_month(calendar, data[calendar].month, data[calendar].year)      
       end)
  ))
  data[calendar].next_month = blingbling.text_box.new({text = ">>"})
  data[calendar].next_month:set_padding(padding)
  data[calendar].next_month:set_rounded_size(rounded_size)
  data[calendar].next_month:set_background_color(title_background_color)
  data[calendar].next_month:set_font_size(title_font_size)
  data[calendar].next_month:set_text_color(title_color)    
  --Add focus on the widget:
  data[calendar].next_month:connect_signal("mouse::enter", function(widget)
    widget:set_background_color(beautiful.bg_focus)
    widget:set_text_color(beautiful.fg_focus)    
  end)
  data[calendar].next_month:connect_signal("mouse::leave", function(widget)
    widget:set_background_color(title_background_color)
    widget:set_text_color(title_text_color)    
  end)
  --Link action on the widget:
  data[calendar].next_month:buttons(util.table.join(
       button({ }, 1, function()
        see_next_month(calendar, data[calendar].month, data[calendar].year)      
       end)
  ))
 
  --generate cells with day label
  local days_widgets_line_height = 0
  for i=1,7 do 
    local cell_day = blingbling.text_box.new({text = day_labels[i]})
    cell_day:set_padding(padding)
    cell_day:set_rounded_size(rounded_size)
    cell_day:set_background_color(columns_lines_titles_background_color)
    cell_day:set_font_size(columns_lines_titles_font_size)
    cell_day:set_text_color(columns_lines_titles_text_color)    
    table.insert(day_widgets,cell_day)
  end
  
  --generate empty cell (corner of days of week line and weeks of year column
  local  corner_cell = blingbling.text_box.new({text = "__|"})
  corner_cell:set_padding(padding)
  corner_cell:set_rounded_size(rounded_size)
  corner_cell:set_background_color(columns_lines_titles_background_color)
  corner_cell:set_font_size(columns_lines_titles_font_size)
  corner_cell:set_text_color(columns_lines_titles_text_color)    
 
 
  --generate cells for weeks numbers  
  data[calendar].weeks_numbers_widgets={}
  local weeks_numbers = helpers.get_ISO8601_weeks_number_of_month(month_displayed,year_displayed)
  for i=1,6 do 
    cell_week = blingbling.text_box.new({text = weeks_numbers[i]})
    cell_week:set_padding(padding)
    cell_week:set_rounded_size(rounded_size)
    cell_week:set_background_color(columns_lines_titles_background_color)
    cell_week:set_font_size(columns_lines_titles_font_size)
    cell_week:set_text_color(columns_lines_titles_text_color)     
    table.insert(data[calendar].weeks_numbers_widgets,cell_week)
  end

  for i=1,42 do
  --generate cells  before the first day
    if i < first_day_of_month then
      local cell_widget = blingbling.text_box.new({text = "--"})
      cell_widget:set_padding(padding)
      cell_widget:set_rounded_size(rounded_size)
      cell_widget:set_background_color(background_color)
      cell_widget:set_font_size(font_size)
      cell_widget:set_text_color(color)
      --set in a table need to keep trace of initial color when hover
      table.insert(data[calendar].days_of_month, {text = "--", widget = cell_widget, bg_color = background_color, fg_color = text_color})
    end
    if i>= first_day_of_month and i < last_day_of_current_month + first_day_of_month then
      if i == current_day_of_month + first_day_of_month -1 then
        background = beautiful.bg_focus
        color = beautiful.fg_focus
      else  
        background = background_color
        color = text_color
      end
      day_of_month = day_of_month + 1
      --Had 0 before the day if the day is inf to 10
      if day_of_month < 10 then
        day_of_month = "0" .. day_of_month
      else
        day_of_month = day_of_month ..""
      end
      local cell_widget = blingbling.text_box.new({text = day_of_month})
      cell_widget:set_padding(padding)
      cell_widget:set_rounded_size(rounded_size)
      cell_widget:set_background_color(background)
      cell_widget:set_font_size(font_size)
      cell_widget:set_text_color(color)
      table.insert(data[calendar].days_of_month, {text = day_of_month, widget = cell_widget, bg_color = background, fg_color = color})
    end
    if i >= last_day_of_current_month  + first_day_of_month then
      local cell_widget = blingbling.text_box.new({text = "--"})
      cell_widget:set_padding(padding)
      cell_widget:set_rounded_size(rounded_size)
      cell_widget:set_background_color(background_color)
      cell_widget:set_font_size(font_size)
      cell_widget:set_text_color(color)
      table.insert(data[calendar].days_of_month, {text = "--", widget = cell_widget, bg_color = background_color, fg_color = text_color})
    end
  end
  data[calendar].calendarbox=awful.wibox({height = 140, width= 200, screen = current_screen })
    --set the position of the wibox
  data[calendar].calendarbox.y = mouse_coords.y < screen_geometry.y and screen_geometry.y or mouse_coords.y
  data[calendar].calendarbox.x = mouse_coords.x < screen_geometry.x and screen_geometry.x or mouse_coords.x
  data[calendar].calendarbox.y = data[calendar].calendarbox.y + data[calendar].calendarbox.height > screen_h and screen_h - data[calendar].calendarbox.height or data[calendar].calendarbox.y
  data[calendar].calendarbox.x = data[calendar].calendarbox.x + data[calendar].calendarbox.width > screen_w and screen_w - data[calendar].calendarbox.width or data[calendar].calendarbox.x
  
data[calendar].calendarbox.ontop =true

  local title_line = blingbling.layout.flex.horizontal_left()
  title_line:add(data[calendar].prev_month)
  title_line:add(data[calendar].displayed_month_year)
  title_line:add(data[calendar].next_month)

  local d_o_w_line = blingbling.layout.flex.horizontal_middle() --(days of week)
  --wibox.layout.margin(data[calendar].weeks_numbers_widgets[1], 5,5,3,3)
  d_o_w_line:add(corner_cell)
  for i=1,7 do
    d_o_w_line:add(day_widgets[i])
  end
  local d_o_m_lines = {}  --(days of month)
  for i=1,6 do
    d_o_m_lines[i]=blingbling.layout.flex.horizontal_middle()
    d_o_m_lines[i]:add(data[calendar].weeks_numbers_widgets[i])
    d_o_m_lines[i]:add(data[calendar].days_of_month[(7*(i-1))+1].widget)
    d_o_m_lines[i]:add(data[calendar].days_of_month[(7*(i-1))+2].widget)
    d_o_m_lines[i]:add(data[calendar].days_of_month[(7*(i-1))+3].widget)
    d_o_m_lines[i]:add(data[calendar].days_of_month[(7*(i-1))+4].widget)
    d_o_m_lines[i]:add(data[calendar].days_of_month[(7*(i-1))+5].widget)
    d_o_m_lines[i]:add(data[calendar].days_of_month[(7*(i-1))+6].widget)
    d_o_m_lines[i]:add(data[calendar].days_of_month[(7*(i-1))+7].widget)
  end
  local my_table=blingbling.layout.array.stack()
  my_table:add_line(title_line)
  my_table:add_line(d_o_w_line)
  my_table:add_line(d_o_m_lines[1])
  my_table:add_line(d_o_m_lines[2])
  my_table:add_line(d_o_m_lines[3])
  my_table:add_line(d_o_m_lines[4])
  my_table:add_line(d_o_m_lines[5])
  my_table:add_line(d_o_m_lines[6])

  data[calendar].calendarbox:set_widget(my_table)

  return calendar
end

function show_events(calendar,day_label, month, year, function_index)
--Part that will be used to display events (not using awful.menu)
  --the wibox for the events
  --data[calendar].events_box
  --the textbox
  --data[calendar].events_text
  
  --if not already created we create them
 -- if data[calendar].events_box == nil then
    
    --Get screen and position informations and create wibox
 --   local current_screen = mouse.screen
 --   events_text_box = wibox.widget.textbox()
 --   events_text_box:set_font(beautiful.font)
 --   events_text_box:set_markup()
 --   data[calendar].events_box = awful.wibox({screen = current_screen})
 --   
 --   local screen_geometry = screen[current_screen].workarea
 --   local screen_w = screen_geometry.x + screen_geometry.width
 --   local screen_h = screen_geometry.y + screen_geometry.height
 --   local mouse_coords = mouse.coords()    data[calendar].events_box = awful.wibox
 --   data[calendar].events_box.y = mouse_coords.y < screen_geometry.y and screen_geometry.y or mouse_coords.y
 --  data[calendar].events_box.x = mouse_coords.x < screen_geometry.x and screen_geometry.x or mouse_coords.x
 --   data[calendar].events_box.y = data[calendar].events_box.y + data[calendar].events_box.height > screen_h and screen_h - data[calendar].events_box.height or data[calendar].events_box.y
 --   data[calendar].events_box.x = data[calendar].events_box.x + data[calendar].events_box.width > screen_w and screen_w - data[calendar].events_box.width or data[calendar].events_box.x
  
 --   data[calendar].events_box.ontop =true
 -- end
  
  local day = tonumber(day_label)
  local month = month
  local year = year

  if function_index == nil then 
    data[calendar].get_events_function_index = 1 
  elseif function_index == 1 and data[calendar].get_events_function_index == #data[calendar].get_events_from then
    data[calendar].get_events_function_index = 1
  elseif function_index == -1 and data[calendar].get_events_function_index == 1 then
    data[calendar].get_events_function_index = #data[calendar].get_events_from 
  else
    data[calendar].get_events_function_index = data[calendar].get_events_function_index + function_index
  end
  
  day_events=data[calendar].get_events_from[data[calendar].get_events_function_index](day,month,year)
  data[calendar].menu_events = awful.menu({ items = { {day_events,""}  }})
  data[calendar].menu_events:show()
end
function hide_events(calendar)
  if data[calendar].menu_events ~= nil then
  data[calendar].menu_events:hide()
  data[calendar].menu_events = nil
  end
end
function add_focus(calendar)
  local padding = data[calendar].cell_padding or 4 
  local background_color = data[calendar].cell_background_color or "#00000066"
  local rounded_size = data[calendar].rounded_size or 0.4
  local text_color = data[calendar].text_color or "#ffffffff"
  local font_size = data[calendar].font_size or 9
  local title_background_color = data[calendar].title_background_color or background_color
  local title_text_color = data[calendar].title_text_color or text_color
  local title_font_size = data[calendar].title_font_size or font_size + 2
  if data[calendar].link_to_external_calendar and data[calendar].link_to_external_calendar == true then
    for i=1,42 do
      data[calendar].days_of_month[i].widget:connect_signal("mouse::enter", function(widget)
        if data[calendar].days_of_month[i].text ~= "--" then
          widget:set_background_color(beautiful.bg_focus)
          widget:set_text_color(beautiful.fg_focus)    
          show_events(calendar,data[calendar].days_of_month[i].text, data[calendar].month, data[calendar].year)
            
          widget:buttons(util.table.join(
              button({ }, 4, function()
              hide_events(calendar)
              show_events(calendar,data[calendar].days_of_month[i].text, data[calendar].month, data[calendar].year, 1)
              end),
              button({ }, 5, function()
              hide_events(calendar)
              show_events(calendar,data[calendar].days_of_month[i].text, data[calendar].month, data[calendar].year, (-1))
              end)
            ))
        end
      end)
          
      data[calendar].days_of_month[i].widget:connect_signal("mouse::leave", function(widget)
        if data[calendar].days_of_month[i].text ~= "--" then
            
            widget:set_background_color(data[calendar].days_of_month[i].bg_color)
            widget:set_text_color(data[calendar].days_of_month[i].fg_color)    
            hide_events(calendar)
        end
      end)
    end
  end
end
-- Build properties function
for _, prop in ipairs(properties) do
    if not _M["set_" .. prop] then
         _M["set_" .. prop] = function(calendar, value)
             data[calendar][prop] = value
             bind_click_to_toggle_visibility(calendar)
             return calendar
       end
   end
end

function append_function_get_events_from(calendar, my_function)
  table.insert(data[calendar].get_events_from, my_function)
  return calendar
end

function clear_and_add_function_get_events_from(calendar, my_function)
  data[calendar].get_events_from={}
  table.insert(data[calendar].get_events_from, my_function)
  return calendar
end

function new(args)
  local args =args or {}
  local calendar=imagebox()
  calendar:set_image(args.image)
  calendar:set_resize(false)
  data[calendar]={}
  for _, prop in ipairs(properties) do
    calendar["set_" .. prop] = _M["set_" .. prop]
  end
  data[calendar].get_events_from={
  --reminds
  function(day,month,year)
  local day_events=util.pread('remind ~/.reminders ' .. day .. " " .. os.date("%B",os.time{year=year,month=month,day=day}) .." " .. year)
  day_events = string.gsub(day_events,"\n\n+","\n")
  day_events  =string.gsub(day_events,"\n*$","")
  day_events="Remind:\n\n toto" .. day_events
  return day_events
  end,
  --task_warrior
  function(day,month,year)
  local day_events=util.pread('task overdue due:' .. os.date("%m",os.time{year=year,month=month,day=day}) .."/"..day.."/" .. year)
  local day_events = "Task warrior:\n" .. day_events 
  return day_events
  end,
  }
  bind_click_to_toggle_visibility(calendar)
  return calendar
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
