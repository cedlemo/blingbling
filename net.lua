-- @author cedlemo  

local setmetatable = setmetatable
local ipairs = ipairs
local math = math
local table = table
local type = type
local string = string
local io = require("io")
local os = require("os")
local awful = require("awful")
local naughty = require("naughty")
local tonumber = tonumber
local color = require("gears.color")
local base = require("wibox.widget.base")
local helpers = require("blingbling.helpers")
local superproperties = require('blingbling.superproperties')

---Net widget displays two arrows as graph for download/upload activities
--@module blingbling.widget

---Set the net interface used to get information, default is eth0.
--@usage mynet:set_interface(string)
--@name set_interface
--@class function
--@param interface a string

---Define the top and bottom margin for the graph area.
--@usage mynet:set_v_margin(integer)
--@name set_v_margin
--@class function
--@param margin an integer for top and bottom margin

---Define the left and right margin for the graph area.
--@usage mynet:set_h_margin()
--@name set_h_margin
--@class function 
--@param margin an integer for left and right margin

---Fill all the widget (width * height) with this color (default is none ).
--@usage mynet:set_background_color(string) -->"#rrggbbaa"
--@name set_background_color
--@class function
--@param color a string "#rrggbbaa" or "#rrggbb"

---Fill the graph area background with this color (default is none).
--@usage mynet:set_background_graph_color(string) -->"#rrggbbaa"
--@name set_background_graph_color
--@class function
--@param color a string "#rrggbbaa" or "#rrggbb"

---Define the graph/arrows color.
--@usage mynet:set_graph_color(string) -->"#rrggbbaa"
--@name set_graph_color
--@class function
--@param color a string "#rrggbbaa" or "#rrggbb"

---Set an outline on the arrows with this color.
--@usage mynet:set_graph_line_color(string) -->"#rrggbbaa"
--@name set_graph_line_color
--@class function
--@param color a string "#rrggbbaa" or "#rrggbb"

---Display or not upload/download informations.
--@usage mynet:set_show_text(boolean) --> true or false
--@name set_show_text
--@class function
--@param boolean true or false default is false

---Define the text color.
--@usage mynet:set_text_color(string) -->"#rrggbbaa"
--@name set_text_color
--@class function
--@param color a string "#rrggbbaa" or "#rrggbb"

---Set a color behind the text.
--@usage mynet:set_text_background_color(string) -->"#rrggbbaa"
--@name set_text_background_color
--@class function
--@param color a string "#rrggbbaa" or "#rrggbb"

---Set the size of the font to use.
--@usage mynet:set_font_size(integer)
--@name set_font_size
--@class function
--@param size the font size

---Set the font to use.
--@usage mynet:set_font(string)
--@name set_font
--@class function
--@param font a string that contains the font name family and weight


local net = { mt = {} }

local data = setmetatable({}, { __mode = "k" })
local properties = {"interface", "width", "height", "v_margin", "h_margin", "background_color", "background_graph_color","graph_color", "graph_line_color","show_text", "text_color", "text_background_color" , "font_size","font" }

function net.draw(n_graph, wibox, cr, width, height)

  local v_margin =  superproperties.v_margin 
  if data[n_graph].v_margin and data[n_graph].v_margin <= data[n_graph].height/4 then 
      v_margin = data[n_graph].v_margin 
  end
  
  local h_margin = superproperties.h_margin
  if data[n_graph].h_margin and data[n_graph].h_margin <= data[n_graph].width / 3 then 
      h_margin = data[n_graph].h_margin 
  end

  local background_border = data[n_graph].background_border or superproperties.background_border
  local background_color = data[n_graph].background_color or superproperties.background_color
  local rounded_size = data[n_graph].rounded_size or superproperties.rounded_size
  local graph_background_color = data[n_graph].graph_background_color or superproperties.graph_background_color
  local graph_background_border = data[n_graph].graph_background_border or superproperties.graph_background_border
  local graph_color = data[n_graph].graph_color or superproperties.graph_color
  local graph_line_color = data[n_graph].graph_line_color or superproperties.graph_line_color
  local text_color = data[n_graph].text_color or superproperties.text_color
  local text_background_color = data[n_graph].text_background_color or superproperties.text_background_color
  local font_size =data[n_graph].font_size or superproperties.font_size
  local font = data[n_graph].font or superproperties.font

  local interface=""
  if data[n_graph].interface == nil then
    data[n_graph].interface = "eth0"
  end
  interface = data[n_graph].interface 
  
  if data[n_graph].show_text then
    cr:set_font_size(font_size)

    if type(font) == "string" then
      cr:select_font_face(font,nil,nil)
    elseif type(font) == "table" then
      cr:select_font_face(font.family or "Sans", font.slang or "normal", font.weight or "normal")
    end
  --search the good width to display all text and graph and modify the widget width if necessary
    --Adapt widget width with max lenght text
    local text_reference="1.00mb"
    local ext=cr:text_extents(text_reference)
    local text_width=ext.width +1 
    local arrow_width = 6 
    local arrows_separator = 2
    local total_width = (2* text_width) +(2*arrow_width) +(2 * ext.x_bearing)+ arrows_separator + (2*h_margin) 

    data[n_graph].width = total_width
  else
    local arrow_width = 8
    local arrows_separator = 2
    data[n_graph].width = (arrow_width * 2) + arrows_separator + (2*h_margin)
  end
--TODO manage widget background
  ----Generate Background (background widget)
  if background_color then
    r,g,b,a = helpers.hexadecimal_to_rgba_percent(background_color)
    cr:set_source_rgba(r,g,b,a)
    cr:paint()
  end
  
--Prepare the Text  
  local unit = { "b", "kb","mb","gb"}
  local unit_range = { 1, 1024, 1024^2, 1024^3 }
  local down_value
  local down_unit
  local up_value
  local up_unit
  
  down_value=0
  down_unit="b"  
  
  up_value=0
  up_unit="b"

  if data[n_graph][interface.."_down"] ~= nil then
    for i,v in ipairs(unit_range) do
      if data[n_graph][interface.."_down"] >= v then
        down_value=data[n_graph][interface.."_down"]/v
        down_unit=unit[i]
      end
    end
  end
  if data[n_graph][interface.."_up"] ~= nil then
    for i,v in ipairs(unit_range) do
      if data[n_graph][interface .."_up"] >= v then
        up_value=data[n_graph][interface.."_up"]/v
        up_unit=unit[i]
      end
    end
  end
--we format the value
  if  down_value >=0 and down_value <10 then 
    down_text=string.format("%.2f",down_value)..down_unit
  end
  if down_value >= 10 and down_value < 100 then
     down_text=string.format("%.1f",down_value)..down_unit
  end
  if down_value >= 100 then
     down_text=string.format("%d",math.ceil(down_value))..down_unit
  end
  
  if data[n_graph][interface.."_up"] ~= nil then
    for i,v in ipairs(unit_range) do
      if data[n_graph][interface.."_up"] >= v then
        up_value=data[n_graph][interface.."_up"]/v
        up_unit=unit[i]
      end
    end
  end
  --we format the value
  if  up_value >=0 and up_value <10 then 
    up_text=string.format("%.2f",up_value)..up_unit
  end
  if up_value >= 10 and up_value < 100 then
     up_text=string.format("%.1f",up_value)..up_unit
  end
  if up_value >= 100 then
     uptext=string.format("%d",math.ceil(up_value))..up_unit
  end

--Drawn up arrow 
  helpers.draw_up_down_arrows(
      cr,
      math.floor(data[n_graph].width/2 -1),
      height - v_margin,
      v_margin, 
      up_value, 
      graph_background_color, 
      graph_color,
      graph_line_color , 
      true)
  --Drawn down arrow
  helpers.draw_up_down_arrows(
      cr,
      math.floor(data[n_graph].width/2)+1,
      v_margin,
      data[n_graph].height - v_margin,
      down_value,
      graph_background_color, 
      graph_color,
      graph_line_color , 
      false)
  
  if data[n_graph][interface.."_state"] ~= "up" or data[n_graph][interface.."_carrier"] ~= "1" then
     cr:move_to(data[n_graph].width*2/5, v_margin)
     cr:line_to(data[n_graph].width*3/5,data[n_graph].height - v_margin)
     cr:move_to(data[n_graph].width *4/7, 2*v_margin)
     cr:line_to(data[n_graph].width*3/7,height - 2*v_margin)
     cr:set_source_rgb(1,0,0)
     cr:set_line_width(1)
     cr:stroke()
  end

  if data[n_graph].show_text == true then
  --Draw Text and it's background
    cr:set_font_size(font_size)
    
    helpers.draw_text_and_background(cr, 
                                        down_text, 
                                        data[n_graph].width -h_margin, 
                                        v_margin , 
                                        text_background_color, 
                                        text_color,
                                        false,
                                        false,
                                        true,
                                        true)
    
    helpers.draw_text_and_background(cr, 
                                        up_text, 
                                        h_margin, 
                                        height -v_margin , 
                                        text_background_color, 
                                        text_color,
                                        false,
                                        false,
                                        false,
                                        false)
    
  end

end

function net.fit(n_graph, width, height)
    return data[n_graph].width, data[n_graph].height
end

local function get_net_infos(n_graph)
  -- Variable definitions
  for line in io.lines("/proc/net/dev") do
    local device = string.match(line, "^[%s]?[%s]?[%s]?[%s]?([%w]+):")
    if device ~= nil then
    -- Received bytes, first value after the name
      local recv = tonumber(string.match(line, ":[%s]*([%d]+)"))
    -- Transmited bytes, 7 fields from end of the line
      local send = tonumber(string.match(line,
      "([%d]+)%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d+%s+%d$"))
      --check if interface is up or down
      local state
      for line in io.lines("/sys/class/net/"..string.gsub(device,"%s","").."/operstate") do
        state = line
      end
      data[n_graph][device.."_state"]=state
      --check if wire is connected
      local carrier
      if data[n_graph][device.."_state"] == "up" then
        for line in io.lines("/sys/class/net/"..string.gsub(device,"%s","").."/carrier") do
          carrier = line
        end
        data[n_graph][device.."_carrier"]=carrier
      else
        data[n_graph][device.."_carrier"]="0"
      end
      
      local now =os.time()
        if data[n_graph][device.."_down"] == nil or data[n_graph][device.."_up"] == nil then
            data[n_graph][device.."_down"] = 0
            data[n_graph][device.."_up"] = 0
        else 
          local interval = now - data[n_graph][device.."_time"]
          if interval <= 0 then interval =1 end

          local down = (recv -data[n_graph][device.."_last_recv"]) / interval
          local up = (send - data[n_graph][device.."_last_send"]) / interval
            data[n_graph][device.."_down" ] = down
            data[n_graph][device.."_up"] = up
        end

        data[n_graph][device.."_time"] = now

        data[n_graph][device.."_last_recv"] = recv
        data[n_graph][device.."_last_send"] = send
      end
  end
end

local function update_net(n_graph)
if not n_graph then return end
  data[n_graph].timer_update = timer({timeout = 2})
  data[n_graph].timer_update:connect_signal("timeout", function()
    get_net_infos(n_graph);
    n_graph:emit_signal("widget::updated")
  end)
  data[n_graph].timer_update:start()
  return n_graph
end

local function hide_ippopup_infos(n_graph)
  if data[n_graph].ippopup ~= nil then
    naughty.destroy(data[n_graph].ippopup)
    data[n_graph].ippopup = nil
  end
end

local function show_ippopup_infos(n_graph)
  local ip_addr
  local gateway
  local all_infos=awful.util.pread("ip route show")
  local interface = data[n_graph].interface
  if data[n_graph][interface.."_state"] == "up" then
    if data[n_graph][interface.."_carrier"] == "1" then --get local ip configuration
      ip_addr=string.match(string.match(all_infos, "%sdev%s".. interface .. "%s+proto%skernel.*" .."%ssrc%s[%d]+%.[d%]+%.[%d]+%.[%d]+"), "[%d]+%.[d%]+%.[%d]+%.[%d]+")
      --get gateway
      gateway= string.match(string.match(all_infos,"default%svia%s[%d]+%.[d%]+%.[%d]+%.[%d]+"), "[%d]+%.[d%]+%.[%d]+%.[%d]+")
      --get external ip configuration
      local ext_ip = awful.util.pread("curl --silent --connect-timeout 3 -S http://ipecho.net/plain 2>&1")
      --if time out then no external ip
      if string.match(ext_ip,"timed%sout%!") then
        data[n_graph].ext_ip = "n/a" 
      else
        data[n_graph].ext_ip = ext_ip
      end

      --get tor external configuration
      local tor_ext_ip
      --we check that the tor address have not been checked or that the elapsed time from the last request is not < 300 sec. whereas whatsmyip block the request
      if (data[n_graph].tor_ext_ip_timer == nil or data[n_graph].tor_ext_ip_timer + 300 < os.time()) and data[n_graph].ext_ip ~= "n/a" then
        if awful.util.pread("pgrep -x tor") ~= "" then
          tor_ext_ip = awful.util.pread("curl --silent -S -x socks4a://localhost:9050 http://ipecho.net/plain 2>&1") 
        else
          tor_ext_ip = "No tor"
        end
        data[n_graph].tor_ext_ip=tor_ext_ip
        data[n_graph].tor_ext_ip_timer=os.time()
      --if local ip is ok but not the external ip, then we can't get external tor ip
      elseif data[n_graph].ext_ip == "n/a" then
        tor_ext_ip="n/a"
      --we get the last value of tor_ext_ip of the last recent check.
      else
        tor_ext_ip= data[n_graph].tor_ext_ip
      end
      local separator ="\n|\n"
      text="Local Ip:\t"..ip_addr..separator.."Gateway:\t".. gateway..separator .."External Ip:\t"..data[n_graph].ext_ip .. separator .. "Tor External Ip:\t" .. tor_ext_ip
    else
      text="Wire is not connected on " .. interface
    end
  else 
      text ="Interface : "..interface .. " is down."
  end
  data[n_graph].ippopup=naughty.notify({
      title = interface .. " informations:",
      text = text,
      timeout= 0,
      hover_timeout = 0.5
      })

end

---Add a popup on the widget that displays informations on the current network connection.
--@usage mynet:set_ippopup()
function net:set_ippopup()
  self:connect_signal("mouse::enter", function()
      show_ippopup_infos(self)
    end)
  self:connect_signal("mouse::leave", function()
        hide_ippopup_infos(self)
    end)
end

--- Set the n_graph height.
-- @param height The height to set.
function net:set_height( height)
    if height >= 5 then
        data[self].height = height
        self:emit_signal("widget::updated")
    end
    return self
end

--- Set the graph width.
-- @param width The width to set.
function net:set_width( width)
    if width >= 5 then
        data[self].width = width
        self:emit_signal("widget::updated")
    end
    return self
end

-- Build properties function
for _, prop in ipairs(properties) do
    if not net["set_" .. prop] then
        net["set_" .. prop] = function(n_graph, value)
            data[n_graph][prop] = value
            n_graph:emit_signal("widget::updated")
            return n_graph
        end
    end
end

--- Create a n_graph widget.
--@usage mynet = blingbling.net({width = 100, height = 20, interface = "eth0"})
-- @param args Standard widget() arguments. You should add width and height and interface
-- @return A graph widget.
function net.new(args)
    
    local args = args or {}

    args.width = args.width or 100
    args.height = args.height or 20

    if args.width < 5 or args.height < 5 then return end

    local n_graph = base.make_widget()
    
    data[n_graph] = {}

    for _, v in ipairs(properties) do
      data[n_graph][v] = args[v] 
    end
    if args.interface then
      data[n_graph].interface = args.interface
    end
    data[n_graph].nets = {}
    --or
    data[n_graph].value = 0
    data[n_graph].max_value = 1

    n_graph.draw = net.draw
    n_graph.fit = net.fit
    n_graph.set_ippopup = net.set_ippopup

    for _, prop in ipairs(properties) do
        n_graph["set_" .. prop] = net["set_" .. prop]
    end
    update_net(n_graph)
    return n_graph
end

function net.mt:__call(...)
    return net.new(...)
end

return setmetatable(net, net.mt)

