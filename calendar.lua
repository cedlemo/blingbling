local capi = { keygrabber = keygrabber, mouse=mouse, screen = screen, image = image} 
local util = require('awful.util') 
local button = require('awful.button') 
local table = table
local type = type
local os = require('os')
local wibox = wibox
local widget = widget
local layout = require('awful.widget.layout')
local pairs = pairs
local ipairs = ipairs
local tonumber = tonumber
local helpers = require('blingbling.helpers')
local blingbling = { layout = require('blingbling.layout') }
local margins = awful.widget.layout.margins
local setmetatable = setmetatable
local beautiful = require('beautiful')
module('blingbling.calendar')

local data = setmetatable( {}, { __mode = "k"})

local properties = { "width","margin", "inter_margin", "cell_background_color", "cell_padding", "rounded_size", "text_color", "font_size", "title_background_color", "title_text_color", "title_font_size", "columns_lines_titles_background_color", "columns_lines_titles_text_color", "columns_lines_titles_font_size"}

menu_keys = { up = { "Up" },
              down = { "Down" },
              exec = { "Return", "Right" },
              back = { "Left" },
              close = { "Escape" } }

--need to add widget selection possibility
--local function grabber(mod, key, event)
--    if event == "release" then
--       return true
--    end

--    local sel = cur_menu.sel or 0
--    if util.table.hasitem(menu_keys.up, key) then
--        local sel_new = sel-1 < 1 and #cur_menu.items or sel-1
--        item_enter(cur_menu, sel_new)
--    elseif util.table.hasitem(menu_keys.down, key) then
--        local sel_new = sel+1 > #cur_menu.items and 1 or sel+1
--        item_enter(cur_menu, sel_new)
--    elseif sel > 0 and util.table.hasitem(menu_keys.exec, key) then
--        exec(cur_menu, sel)
--    elseif util.table.hasitem(menu_keys.back, key) then
--        cur_menu:hide()
--    elseif util.table.hasitem(menu_keys.close, key) then
--        get_parents(cur_menu):hide()
--    else
--        check_access_key(cur_menu, key)
--    end
--   
--    return true
--end
function bind_click_to_toggle_visibility(calendar)
  calendar.widget:buttons(util.table.join(
    button({ }, 1, function()
      if data[calendar].wibox then
        if data[calendar].wibox.visible ~= true then 
          calendar = generate_cal(calendar)
          data[calendar].wibox = calendar.wibox
          data[calendar].wibox.visible = true
        else 
          data[calendar].wibox.visible = false
        end
      else
        calendar = generate_cal(calendar)
        data[calendar].wibox = calendar.wibox
        data[calendar].wibox.visible= true
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
  local title_font_size = data[calendar].title_font_size or font_size + 2
  
  local cell =helpers.generate_rounded_rectangle_with_text_in_image(month_label.." "..year, 
                                                                    padding, 
                                                                    title_background_color, 
                                                                    title_text_color, 
                                                                    title_font_size, 
                                                                    rounded_size)
  data[calendar].displayed_month_year.image = capi.image.argb32(cell.width, cell.height, cell.raw_image)
  
  local last_day_of_current_month = tonumber(helpers.get_days_in_month(month, year))
  local current_day_of_month= tonumber(os.date("%d")) 
  local current_month = tonumber(os.date("%m"))
  local d=os.date('*t',os.time{year=year,month=month,day=01})
  first_day_of_month = d['wday'] - 1
  if first_day_of_month == 0 then first_day_of_month = 7 end 
  local day_of_month = 0 
  
  for i=1,42 do
  --generate cells  before the first day
    if i < first_day_of_month then
      local cell = helpers.generate_rounded_rectangle_with_text_in_image( "--", 
                                                                        padding, 
                                                                        background_color, 
                                                                        text_color, 
                                                                        font_size, 
                                                                        rounded_size)
      data[calendar].days_of_month[i].image = capi.image.argb32(cell.width, cell.height, cell.raw_image)
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
      local cell = helpers.generate_rounded_rectangle_with_text_in_image( day_of_month, 
                                                                        padding, 
                                                                        background, 
                                                                        color, 
                                                                        font_size, 
                                                                        rounded_size)
      data[calendar].days_of_month[i].image = capi.image.argb32(cell.width, cell.height, cell.raw_image)
    end
    if i >= last_day_of_current_month  + first_day_of_month then
      local cell = helpers.generate_rounded_rectangle_with_text_in_image( "--", 
                                                                        padding, 
                                                                        background_color, 
                                                                        text_color, 
                                                                        font_size, 
                                                                        rounded_size)
      data[calendar].days_of_month[i].image = capi.image.argb32(cell.width, cell.height, cell.raw_image)
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
  local current_screen = capi.mouse.screen
  local screen_geometry = capi.screen[current_screen].workarea
  local screen_w = screen_geometry.x + screen_geometry.width
  local screen_h = screen_geometry.y + screen_geometry.height
  local mouse_coords = capi.mouse.coords()
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
  local d=os.date('*t',os.time{year=year_displayed,month=month_displayed,day=01})
  first_day_of_month = d['wday'] - 1
  local last_day_of_current_month = tonumber(helpers.get_days_in_month(month_displayed, year_displayed))
  local max_day_cells = 42 
  local day_of_month = 0 
  local day_widgets={}
  
  --generate title cells with displayed month and year
  local cell_month_year =helpers.generate_rounded_rectangle_with_text_in_image(os.date("%B %Y"), 
                                                                    padding, 
                                                                    title_background_color, 
                                                                    title_text_color, 
                                                                    title_font_size, 
                                                                    rounded_size)
  data[calendar].displayed_month_year= widget({ type ="imagebox", width=cell_month_year.width, height=cell_month_year.height })
  data[calendar].displayed_month_year.image = capi.image.argb32(cell_month_year.width, cell_month_year.height, cell_month_year.raw_image)
  margins[data[calendar].displayed_month_year]={top = wibox_margin + inter_margin, bottom = inter_margin + 2}
  
  --generate cells for precedent month and next month:
  local cell_prev = helpers.generate_rounded_rectangle_with_text_in_image("<<", 
                                                                    padding, 
                                                                    title_background_color, 
                                                                    title_text_color, 
                                                                    title_font_size, 
                                                                    rounded_size)
  local prev_month= widget({ type ="imagebox", width=cell_prev.width, height=cell_prev.height })
  prev_month.image = capi.image.argb32(cell_prev.width, cell_prev.height, cell_prev.raw_image)
  margins[prev_month]={top = wibox_margin + inter_margin, bottom = inter_margin + 2}
  --Link action on the widget:
  prev_month:buttons(util.table.join(
       button({ }, 1, function()
        see_prev_month(calendar, data[calendar].month, data[calendar].year)      
       end)
  ))

  
  local cell_next = helpers.generate_rounded_rectangle_with_text_in_image(">>", 
                                                                    padding, 
                                                                    title_background_color, 
                                                                    title_text_color, 
                                                                    title_font_size, 
                                                                    rounded_size)
  local next_month= widget({ type ="imagebox", width=cell_next.width, height=cell_next.height })
  next_month.image = capi.image.argb32(cell_next.width, cell_next.height, cell_next.raw_image)
  margins[next_month]={top = wibox_margin + inter_margin, bottom = inter_margin + 2}
  --Link action on the widget:
  next_month:buttons(util.table.join(
       button({ }, 1, function()
        see_next_month(calendar, data[calendar].month, data[calendar].year)      
       end)
  ))
  
  all_lines_height = margins[data[calendar].displayed_month_year].top + margins[data[calendar].displayed_month_year].bottom + cell_month_year.height+ all_lines_height

  --generate cells with day label
  local days_widgets_line_height = 0
  for i=1,7 do 
    local cell = helpers.generate_rounded_rectangle_with_text_in_image(day_labels[i], 
                                                                        padding, 
                                                                        columns_lines_titles_background_color, 
                                                                        columns_lines_titles_text_color, 
                                                                        columns_lines_titles_font_size, 
                                                                        rounded_size)
    local cell_widget= widget({ type ="imagebox", width=cell.width, height=cell.height })
    cell_widget.image = capi.image.argb32(cell.width, cell.height, cell.raw_image)
    margins[cell_widget]={top = inter_margin, bottom = inter_margin + 2}
    table.insert(day_widgets,cell_widget)
    if cell.height + margins[cell_widget].top + margins[cell_widget].bottom > days_widgets_line_height then
      days_widgets_line_height = cell.height+ margins[cell_widget].top + margins[cell_widget].bottom
    end
  end
  
  all_lines_height = all_lines_height + days_widgets_line_height
  --generate empty cell (corner of days of week line and weeks of year column
    local cell = helpers.generate_rounded_rectangle_with_text_in_image("__|", 
                                                                        padding, 
                                                                        columns_lines_titles_background_color, 
                                                                        columns_lines_titles_text_color, 
                                                                        columns_lines_titles_font_size, 
                                                                        rounded_size)
    local corner_widget= widget({ type ="imagebox", width=cell.width, height=cell.height })
    corner_widget.image = capi.image.argb32(cell.width, cell.height, cell.raw_image)
    margins[corner_widget]={top = inter_margin, bottom = inter_margin + 2}

  --generate cells for weeks numbers  
  local weeks_numbers_widgets={}
  local weeks_numbers = helpers.get_ISO8601_weeks_number_of_month(month_displayed,year_displayed)
  for i=1,6 do 
    local cell = helpers.generate_rounded_rectangle_with_text_in_image(weeks_numbers[i], 
                                                                        padding, 
                                                                        columns_lines_titles_background_color, 
                                                                        columns_lines_titles_text_color, 
                                                                        columns_lines_titles_font_size, 
                                                                        rounded_size)
    local cell_widget= widget({ type ="imagebox", width=cell.width, height=cell.height })
    cell_widget.image = capi.image.argb32(cell.width, cell.height, cell.raw_image)
    margins[cell_widget]={top = inter_margin}
    table.insert(weeks_numbers_widgets,cell_widget)
  end

  local classic_cell_height = 0
  for i=1,42 do
  --generate cells  before the first day
    if i < first_day_of_month then
      local cell = helpers.generate_rounded_rectangle_with_text_in_image( "--", 
                                                                        padding, 
                                                                        background_color, 
                                                                        text_color, 
                                                                        font_size, 
                                                                        rounded_size)
      local cell_widget= widget({ type ="imagebox", width=cell.width, height=cell.height })
      cell_widget.image = capi.image.argb32(cell.width, cell.height, cell.raw_image)
      margins[cell_widget]={top = inter_margin}
      table.insert(data[calendar].days_of_month, cell_widget)
      if cell.height + margins[cell_widget].top  > classic_cell_height then
        classic_cell_height = cell.height+ margins[cell_widget].top 
      end
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
      local cell = helpers.generate_rounded_rectangle_with_text_in_image( day_of_month, 
                                                                        padding, 
                                                                        background, 
                                                                        color, 
                                                                        font_size, 
                                                                        rounded_size)
      local cell_widget= widget({ type ="imagebox", width=cell.width, height=cell.height })
      cell_widget.image = capi.image.argb32(cell.width, cell.height, cell.raw_image)
      margins[cell_widget]={top = inter_margin}
      table.insert(data[calendar].days_of_month, cell_widget)
      if cell.height + margins[cell_widget].top  > classic_cell_height then
        classic_cell_height = cell.height+ margins[cell_widget].top 
      end
    end
    if i >= last_day_of_current_month  + first_day_of_month then
      local cell = helpers.generate_rounded_rectangle_with_text_in_image( "--", 
                                                                        padding, 
                                                                        background_color, 
                                                                        text_color, 
                                                                        font_size, 
                                                                        rounded_size)
      local cell_widget= widget({ type ="imagebox", width=cell.width, height=cell.height })
      cell_widget.image = capi.image.argb32(cell.width, cell.height, cell.raw_image)
      margins[cell_widget]={top = inter_margin}
      table.insert(data[calendar].days_of_month, cell_widget)
      if cell.height + margins[cell_widget].top  > classic_cell_height then
        classic_cell_height = cell.height+ margins[cell_widget].top 
      end
    end
  end
  all_lines_height =wibox_margin  +all_lines_height + classic_cell_height * 6 
  calendarbox=wibox({height = all_lines_height, width=(data[calendar].width or 200) })
  calendarbox.widgets={}
  calendarbox.ontop =true

  calendarbox.widgets={
      {prev_month, data[calendar].displayed_month_year, next_month, layout = blingbling.layout.array.line_center },
      {corner_widget, day_widgets[1], day_widgets[2], day_widgets[3], day_widgets[4], 
       day_widgets[5], day_widgets[6], day_widgets[7], layout =blingbling.layout.array.line_center},
      {weeks_numbers_widgets[1], data[calendar].days_of_month[1],data[calendar].days_of_month[2], data[calendar].days_of_month[3], data[calendar].days_of_month[4],
       data[calendar].days_of_month[5],data[calendar].days_of_month[6],data[calendar].days_of_month[7],layout =blingbling.layout.array.line_center}, 
      {weeks_numbers_widgets[2], data[calendar].days_of_month[8],data[calendar].days_of_month[9], data[calendar].days_of_month[10], data[calendar].days_of_month[11],
       data[calendar].days_of_month[12],data[calendar].days_of_month[13],data[calendar].days_of_month[14],layout =blingbling.layout.array.line_center}, 
      {weeks_numbers_widgets[3], data[calendar].days_of_month[15],data[calendar].days_of_month[16], data[calendar].days_of_month[17], data[calendar].days_of_month[18],
       data[calendar].days_of_month[19],data[calendar].days_of_month[20],data[calendar].days_of_month[21],layout =blingbling.layout.array.line_center}, 
      {weeks_numbers_widgets[4], data[calendar].days_of_month[22],data[calendar].days_of_month[23], data[calendar].days_of_month[24], data[calendar].days_of_month[25],
       data[calendar].days_of_month[26],data[calendar].days_of_month[27],data[calendar].days_of_month[28],layout =blingbling.layout.array.line_center}, 
      {weeks_numbers_widgets[5], data[calendar].days_of_month[29],data[calendar].days_of_month[30], data[calendar].days_of_month[31], data[calendar].days_of_month[32],
       data[calendar].days_of_month[33],data[calendar].days_of_month[34],data[calendar].days_of_month[35],layout =blingbling.layout.array.line_center},    
      {weeks_numbers_widgets[6], data[calendar].days_of_month[36],data[calendar].days_of_month[37], data[calendar].days_of_month[38], data[calendar].days_of_month[39],
       data[calendar].days_of_month[40],data[calendar].days_of_month[41],data[calendar].days_of_month[42],layout =blingbling.layout.array.line_center},    
       layout = blingbling.layout.array.stack_lines 
                    }
   
  calendar_top_margin=0
  calendarbox.screen = current_screen

  --set the position of the wibox
  calendarbox.y = mouse_coords.y < screen_geometry.y and screen_geometry.y or mouse_coords.y
  calendarbox.x = mouse_coords.x < screen_geometry.x and screen_geometry.x or mouse_coords.x
  calendarbox.y = calendarbox.y + calendarbox.height > screen_h and screen_h - calendarbox.height or calendarbox.y
  calendarbox.x = calendarbox.x + calendarbox.width > screen_w and screen_w - calendarbox.width or calendarbox.x
  
  calendar.wibox = calendarbox
  return calendar
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

function new(args)
  local args =args or {}
  local calendar={}
  data[calendar]={}
  if  args == nil or args.type == "textbox" then
    calendar.widget=widget({ type = "textbox" })
    calendar.widget.text = args.text or "Calendar"
  elseif args.type == "imagebox" then
    calendar.widget=widget({ type = "imagebox" })
    calendar.widget.image=capi.image(args.image)
  end
  for _, prop in ipairs(properties) do
    calendar["set_" .. prop] = _M["set_" .. prop]
  end
  
  bind_click_to_toggle_visibility(calendar)
  return calendar
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
