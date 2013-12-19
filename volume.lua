-- @author cedlemo  

local setmetatable = setmetatable
local ipairs = ipairs
local math = math
local table = table
local type = type
local string = string
local color = require("gears.color")
local base = require("wibox.widget.base")
local helpers = require("blingbling.helpers")
local awful = require("awful")
local superproperties = require('blingbling.superproperties')

---Volume widget
--@module blingbling.volume

local volume = { mt = {} }

local data = setmetatable({}, { __mode = "k" })
local properties = {  "width", "height", "v_margin", "h_margin",
                      "background_color", "graph_background_color",
                      "graph_color","show_text", "text_color", 
                      "text_background_color" ,"label", "font_size","font", 
                      "bar", "graph_line_color"}

function volume.draw(volume_graph, wibox, cr, width, height)

  local v_margin =  superproperties.v_margin 
  if data[volume_graph].v_margin and data[volume_graph].v_margin <= data[volume_graph].height/4 then 
    v_margin = data[volume_graph].v_margin 
  end
    
  local h_margin = superproperties.h_margin
  if data[volume_graph].h_margin and data[volume_graph].h_margin <= data[volume_graph].width / 3 then 
    h_margin = data[volume_graph].h_margin 
  end
    
  local background_border = data[volume_graph].background_border or superproperties.background_border
  local background_color = data[volume_graph].background_color or superproperties.background_color
  local rounded_size = data[volume_graph].rounded_size or superproperties.rounded_size
  local graph_background_color = data[volume_graph].graph_background_color or superproperties.graph_background_color
  local graph_color = data[volume_graph].graph_color or superproperties.graph_color
  local graph_line_color = data[volume_graph].graph_line_color or superproperties.graph_line_color
  local text_color = data[volume_graph].text_color or superproperties.text_color
  local text_background_color = data[volume_graph].text_background_color or superproperties.text_background_color
  local font_size =data[volume_graph].font_size or superproperties.font_size
  local font = data[volume_graph].font or superproperties.font


  r,g,b,a = helpers.hexadecimal_to_rgba_percent(background_color)
  cr:set_source_rgba(r,g,b,a)
  cr:paint()

--Drawn the volume_graph
  
  if data[volume_graph].bar == true then
    --4 bar are use to represent data:
    --bar width:
    local nb_bar=5
    local bar_separator = 2
    local bar_width 
    bar_width=math.floor((data[volume_graph].width -((2*h_margin) + ((nb_bar - 1) * bar_separator)))/nb_bar)
    local h_rest =data[volume_graph].width -( 2*h_margin +((nb_bar -1)*bar_separator) + nb_bar * bar_width)
    if h_rest ==2 or h_rest == 3 then 
      h_rest = 1
    end
    if h_rest == 4 then
      h_rest = 2
    end
    --Drawn background graph
    x=h_margin+h_rest
    y=data[volume_graph].height - v_margin
    for i=1, nb_bar do
      cr:rectangle(x,y-((0.2*i)*(data[volume_graph].height - 2*v_margin)),bar_width,((0.2*i)*(data[volume_graph].height - 2*v_margin)))
      x=x+(bar_width + bar_separator)
    end

    r,g,b,a=helpers.hexadecimal_to_rgba_percent(graph_background_color)
    cr:set_source_rgba(r, g, b, a)
    cr:fill()

    --Drawn the graph
    if data[volume_graph].value > 0 then
      --find nb column to drawn:
      local ranges={0,0.2,0.4,0.6,0.8,1,1.2}
      nb_bar=0
      for i,  limite in ipairs(ranges) do
        if data[volume_graph].value < limite then
        --helpers.dbg({data[volume_graph].value, limite})
          nb_bar = i-1
          break
        end
      end
      x=h_margin+h_rest
      y=data[volume_graph].height - v_margin
      for i=1, nb_bar do
        if i ~= nb_bar then
          cr:rectangle(x,y-((0.2*i)*(data[volume_graph].height - 2*v_margin)),bar_width,(0.2*i)*(data[volume_graph].height - 2*v_margin))
          x=x+(bar_width + bar_separator)
        else
          val_to_display =data[volume_graph].value - ((nb_bar-1) * 0.2)

          cr:rectangle(x,y-((0.2*i)*(data[volume_graph].height - 2*v_margin)),bar_width * (val_to_display/0.2),(0.2*i)*(data[volume_graph].height - 2*v_margin))
        end
      end

      r,g,b,a=helpers.hexadecimal_to_rgba_percent(graph_color)
      cr:set_source_rgba(r, g, b, a)

      cr:fill()
    end  
  else  
    x=h_margin 
    y=data[volume_graph].height-(v_margin) 
    cr:new_path()
    cr:move_to(x,y)
    cr:line_to(x,y)
    y_range=data[volume_graph].height - (2 * v_margin)
    cr:line_to(data[volume_graph].width + h_margin,data[volume_graph].height -( v_margin + y_range ))
    cr:line_to(data[volume_graph].width  + h_margin, data[volume_graph].height - (v_margin ))
    cr:line_to(h_margin,data[volume_graph].height-(v_margin))
    cr:close_path()
    
    r,g,b,a = helpers.hexadecimal_to_rgba_percent(graph_background_color)
    cr:set_source_rgba(r, g, b,a)

    cr:fill()
    if data[volume_graph].value > 0 then
      x=h_margin 
      y=data[volume_graph].height-(v_margin) 
  
      cr:new_path()
      cr:move_to(x,y)
      cr:line_to(x,y)
      y_range=data[volume_graph].height - (2 * v_margin)
      cr:line_to(data[volume_graph].width * data[volume_graph].value + h_margin,data[volume_graph].height -( v_margin + (y_range * data[volume_graph].value)))
      cr:line_to(data[volume_graph].width * data[volume_graph].value + h_margin, data[volume_graph].height - (v_margin ))
      cr:line_to(0+h_margin,data[volume_graph].height-(v_margin))
  
      cr:close_path()

      r,g,b,a=helpers.hexadecimal_to_rgba_percent(graph_color)
      cr:set_source_rgba(r, g, b, a)
      
      cr:fill()

      x=0+h_margin 
      y=data[volume_graph].height-(v_margin) 

      cr:new_path()
      cr:move_to(x,y)
      cr:line_to(x,y)
      y_range=data[volume_graph].height - (2 * v_margin)
      cr:line_to((data[volume_graph].width * data[volume_graph].value) + h_margin  ,data[volume_graph].height -( v_margin +  (y_range * data[volume_graph].value)))
      cr:line_to((data[volume_graph].width * data[volume_graph].value) - h_margin, data[volume_graph].height - (v_margin ))
      cr:set_antialias("subpixel") 
      cr:set_line_width(1)
 
      r,g,b,a=helpers.hexadecimal_to_rgba_percent(graph_line_color)
      cr:set_source_rgb(r, g, b)
      
      cr:stroke()
      end
    end
--Draw Text and it's background
  if data[volume_graph].show_text == true  then 

    cr:set_font_size(font_size)

    if type(font) == "string" then
      cr:select_font_face(font,nil,nil)
    elseif type(font) == "table" then
      cr:select_font_face(font.family or "Sans", font.slang or "normal", font.weight or "normal")
    end
        
    local value = data[volume_graph].value * 100
    
    if data[volume_graph].label then
      text=string.gsub(data[volume_graph].label,"$percent", value)
    else
      text=value .. "%"
    end
    helpers.draw_text_and_background(cr, 
                                      text, 
                                      h_margin, 
                                      (data[volume_graph].height/2) , 
                                      text_background_color, 
                                      text_color,
                                      false,
                                      true,
                                      false,
                                      false)
  end
end

function volume.fit(volume_graph, width, height)
    return data[volume_graph].width, data[volume_graph].height
end

--- Set the graphtype value.
-- @param volume_graph The progress bar.
-- @param value The progress bar value between 0 and 1.
local function set_value(volume_graph, value)
    if not volume_graph then return end
    local value = value or 0
    local max_value = data[volume_graph].max_value
    data[volume_graph].value = math.min(max_value, math.max(0, value))
    volume_graph:emit_signal("widget::updated")
    return volume_graph
end

local function get_master_infos()
  local f=io.popen("amixer get Master")
  for line in f:lines() do
    if string.match(line, "%s%[%d+%%%]%s") ~= nil then
      volume=string.match(line, "%s%[%d+%%%]%s")
      volume=string.gsub(volume, "[%[%]%%%s]","")
      --helpers.dbg({volume})
    end
    if string.match(line, "%s%[[%l]+%]$") then
      state=string.match(line, "%s%[[%l]+%]$")
      state=string.gsub(state,"[%[%]%%%s]","")
    end
  end
  f:close()
  return state, volume
end

local function set_master(parameters)
    local cmd = "amixer --quiet set Master " ..parameters
    local f=io.popen(cmd)
    f:close()
end
local function update_master(volume_graph)
    local state
    local value
    data[volume_graph].mastertimer = timer({timeout = 0.5})
    data[volume_graph].mastertimer:connect_signal("timeout", function() 
      data[volume_graph].state, value = get_master_infos(); set_value(volume_graph,value/100) 
    end)
    data[volume_graph].mastertimer:start()
    return volume_graph
end

local function get_mpd_volume()
  local mpd_volume=0

  local pass = "\"\""
  local host = "127.0.0.1"
  local port = "6600"

    -- MPD client command 
  local mpd_c = "mpc" .. " -h " .. host .. " -p " .. port .. " status 2>&1"

  -- Get data from MPD server
  local f = io.popen(mpd_c)

  for line in f:lines() do
    --helpers.dbg({line})
    if string.find(line,'error:%sConnection%srefused') then
      mpd_vol="-1"
    end
    if string.find(line,"volume:.%d%d%%") then
      mpd_volume = string.match(line,"[%s%d]%d%d")
      --mpd_volume = line
    end
  end
  f:close()
  return mpd_volume
end
---Link the widget to mpd's volume level. 
--@usage myvolume:update_mpd()
--@param volume_graph the volume graph
local function update_mpd(volume_graph)
    local state
    local value
    data[volume_graph].mastertimer = timer({timeout = 0.5})
    data[volume_graph].mastertimer:connect_signal("timeout", function() 
      value = get_mpd_volume(); set_value(volume_graph,value/100) 
    end)
        data[volume_graph].mastertimer:start()
end

---Link the widget to the master channel of your system (uses amixer).
--a left clic toggle mute/unmute, wheel up to increase the volume and wheel down to decrease the volume
--@usage myvolume:set_master_control()
--@class function
--@param volume_graph the volume graph
function set_master_control(volume_graph)
    volume_graph:buttons(awful.util.table.join(
    awful.button({ }, 1, function()
      set_master("toggle")
    end),
    awful.button({ }, 5, function()
      set_master("2%-")
    end),
    awful.button({ }, 4, function()
      set_master("2%+")
    end)))
end

---Set the volume_graph height.
--@param height The height to set.
function volume:set_height( height)
    if height >= 5 then
        data[self].height = height
        self:emit_signal("widget::updated")
    end
    return self
end

---Set the graph width.
--@param width The width to set.
function volume:set_width( width)
    if width >= 5 then
        data[self].width = width
        self:emit_signal("widget::updated")
    end
    return self
end

-- Build properties function
for _, prop in ipairs(properties) do
    if not volume["set_" .. prop] then
        volume["set_" .. prop] = function(volume_graph, value)
            data[volume_graph][prop] = value
            volume_graph:emit_signal("widget::updated")
            return volume_graph
        end
    end
end

---Create a volume_graph widget.
-- @param args Standard widget() arguments. You should add width and height
-- key to set graph geometry.
-- @return A graph widget.
function volume.new(args)
    local args = args or {}
    args.type = "imagebox"

    args.width = args.width or 100
    args.height = args.height or 20

    if args.width < 5 or args.height < 5 then return end

    local volume_graph = base.make_widget()
    
    data[volume_graph] = {}

    for _, v in ipairs(properties) do
      data[volume_graph][v] = args[v] 
    end

    data[volume_graph].value = 0
    data[volume_graph].max_value = 1
    -- Set methods
    volume_graph.set_value = set_value
    volume_graph.update_master = update_master
    volume_graph.update_mpd= update_mpd
    volume_graph.set_master_control = set_master_control
    volume_graph.draw = volume.draw
    volume_graph.fit = volume.fit

    for _, prop in ipairs(properties) do
        volume_graph["set_" .. prop] = volume["set_" .. prop]
    end

    return volume_graph
end

function volume.mt:__call(...)
    return volume.new(...)
end

return setmetatable(volume, volume.mt)

