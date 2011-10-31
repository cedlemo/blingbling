local awful = require("awful") 
local helpers =require("blingbling.helpers")
local string = require("string")
local io = require("io")
local assert = assert
local setmetatable = setmetatable
local ipairs = ipairs
local math = math
local table = table
local tonumber=tonumber
local type=type
local cairo = require "oocairo"
local capi = { image = image, widget = widget, timer = timer }
local layout = require("awful.widget.layout")
 
module("blingbling.mpd_visualizer")

local data = setmetatable({}, { __mode = "k" })

local properties = { "width", "height", "v_margin","h_margin", "background_color", "graph_color", "line","show_text","label","background_text_color","text_color","font_size", "mpd_pass", "mpd_host","mpd_port","error_background_color","error_text_color" }

local function check_mpd()
  local mpd_state={}
  mpd_state["state"] = "Stop"
  local pass = "\"\""
  local host = "127.0.0.1"
  local port = "6600"

    -- MPD client command 
  local mpd_c = "mpc" .. " -h " .. host .. " -p " .. port .. " status 2>&1"

  -- Get data from MPD server
  local f = io.popen(mpd_c)

  num_line=1
  for line in f:lines() do
    --helpers.dbg({line})
    if string.find(line,'error:%sConnection%srefused') then
      mpd_state={}
    end
    if  num_line == 2 and string.find(line,'%[playing%]') then
      mpd_state["state"] = "Play"
    end

    num_line = num_line + 1
  end
  f:close()
  return mpd_state
end
local function get_song_infos(mpd_graph)
  local pass = "\"\""
  local host = "127.0.0.1"
  local port = "6600"
  
  if data[mpd_graph].mpd_pass then
    pass = data[mpd_graph].mpd_pass
  end
  if data[mpd_graph].mpd_host then
    host = data[mpd_graph].mpd_host
  end
  if data[mpd_graph].mpd_port then
    port = data[mpd_graph].mpd_port
  end
    -- MPD client command 
  local mpd_c = "mpc" .. " -h " .. host .. " -p " .. port .. " " .. 'current -f [%artist%]€[%title%]€[%album%]'

  -- Get data from MPD server
  data[mpd_graph].songinfos = ""
  local string =""
  local f = io.popen(mpd_c)
  for line in f:lines() do
    string= line .. string
  end
  f:close()
  local t={}  
  t=helpers.split(string,"€")
  data[mpd_graph].song_artist=t[1]
  data[mpd_graph].song_title=t[2]
  data[mpd_graph].song_album=t[3]
end
local function mpd_send(mpd_graph,command)

  local pass = "\"\""
  local host = "127.0.0.1"
  local port = "6600"
  
  if data[mpd_graph].mpd_pass then
    pass = data[mpd_graph].mpd_pass
  end
  if data[mpd_graph].mpd_host then
    host = data[mpd_graph].mpd_host
  end
  if data[mpd_graph].mpd_port then
    port = data[mpd_graph].mpd_port
  end
    -- MPD client command 
  local mpd_c = "mpc" .. " -h " .. host .. " -p " .. port .. " " ..command

  -- Get data from MPD server
  local f = io.popen(mpd_c)
  f:close()
end

local function moy_table_from_mpd_fifo(mpd_graph,nb_moy)
  local reduced_sample={}
  --check if mpd is running:
  --helpers.dbg({data[mpd_graph].mpdinfos["state"]})
  if data[mpd_graph].mpdinfos["state"] ~= nil then
    --Try to open fifo
    --check if fifo file exist and that mpd is playing music
    if data[mpd_graph].mpdinfos["state"]=="Play" then
    local f = assert(io.open("/tmp/mpd.fifo", "rb"))
      if f then
        local block = 2048 * 2 --2048 samples, 2 bytes per sample
        local bytes = f:read(block) --read a sample of block bytes
        --Find nb rows / moy 
        local rest=2048%nb_moy
        local range=(2048-rest)/nb_moy
        local sum=0
        local index=0
        local one_value=0

        for i=1, nb_moy do
          local adjust_rest=0
          for j=1, range do
            index=index +1
            one_value = string.format("%u", string.byte(bytes, index *2, (index * 2) +1))
            sum=((one_value/255)*100) + sum
          end

          if rest > 0 and (nb_moy - i) == rest then
            index=index + 1
            one_value = string.format("%u", string.byte(bytes, index *2, (index * 2) +1))
            sum=((one_value/255)*100) + sum
            adjust_rest=1
            rest = rest -1
          end
          table.insert(reduced_sample,sum/(adjust_rest+ range))
          sum = 0
        end
        f:close()
        return reduced_sample
      else
        f:close()
        data[mpd_graph].fifo_error = "no fifo ?"
        return reduced_sample
      end
    else
    --if MPD state is not "Play"
      --f:close()
      data[mpd_graph].fifo_error = data[mpd_graph].mpdinfos["state"] 
      return reduced_sample
    end
  else
  --if we can't get MPD infos (MPD is not running or MPD client configuration is bad)
    data[mpd_graph].fifo_error = "No MPD infos "
    return reduced_sample
  end
end

local function generate(mpd_graph)
  local mpd_graph_surface=cairo.image_surface_create("argb32",data[mpd_graph].width, data[mpd_graph].height)
  local mpd_graph_context = cairo.context_create(mpd_graph_surface)
  
  local v_margin = 2 
  if data[mpd_graph].v_margin then 
    v_margin = data[mpd_graph].v_margin 
  end
  local h_margin = 0 
  if data[mpd_graph].h_margin then 
    h_margin = data[mpd_graph].h_margin 
  end

  local w_pattern=0
  local h_pattern=0
  local x_pattern_separator=0
  local pattern_lenght=0
  
  if data[mpd_graph].line then
    pattern_lenght = 4
  else
    w_pattern=2
    h_pattern=1
    x_pattern_separator=1
    pattern_lenght=w_pattern + x_pattern_separator
  end

  --find nb columns to display
  nb_columns_to_display= math.floor((data[mpd_graph].width - 2* h_margin)/pattern_lenght)
  h_rest=(data[mpd_graph].width - 2* h_margin)%nb_columns_to_display
  h_rest=math.floor(h_rest/2)
  --helpers.dbg({h_rest, nb_columns_to_display})
  data[mpd_graph].values = {}

  --read mpd fifo
  --transform raw mpd fifo data to usable data for each columns 
  data[mpd_graph].values = moy_table_from_mpd_fifo(mpd_graph,nb_columns_to_display)
  --In case values are empty (fifo not found):
  if #data[mpd_graph].values == 0 then
    if data[mpd_graph].error_background_color then
      r,g,b,a = helpers.hexadecimal_to_rgba_percent(data[mpd_graph].error_background_color)
      mpd_graph_context:set_source_rgba(r,g,b,a)
      mpd_graph_context:paint()
    end

    if data[mpd_graph].font_size == nil then
      data[mpd_graph].font_size=9
    end

    mpd_graph_context:new_path()

    if data[mpd_graph].error_text_color == nil then
      data[mpd_graph].error_text_color = "#ff0000ff" 
    end
    if data[mpd_graph].background_text_color == nil then
      data[mpd_graph].background_text_color = "#000000dd" 
    end
    mpd_graph_context:show_text(data[mpd_graph].fifo_error)
    helpers.draw_text_and_background(mpd_graph_context, 
                                        data[mpd_graph].fifo_error, 
                                        h_margin, 
                                        (data[mpd_graph].height/2) + (data[mpd_graph].font_size)/2, 
                                        data[mpd_graph].background_text_color, 
                                        data[mpd_graph].error_text_color,
                                        false,
                                        false)
  else  
    --drawn the the graph
    if data[mpd_graph].background_color then
      r,g,b,a = helpers.hexadecimal_to_rgba_percent(data[mpd_graph].background_color)
      mpd_graph_context:set_source_rgba(r,g,b,a)
      mpd_graph_context:paint()
    end
    if data[mpd_graph].line then
      local x=0+h_margin+h_rest
      local y=data[mpd_graph].height / 2
      part_for_display=data[mpd_graph].height - (v_margin *2)
      mpd_graph_context:new_path()
      mpd_graph_context:move_to(x,y)
      for i=1,nb_columns_to_display do
        mpd_graph_context:line_to(x,data[mpd_graph].height -(v_margin + (part_for_display * (data[mpd_graph].values[i]/100))))
        x=x+pattern_lenght
      end
      mpd_graph_context:line_to(data[mpd_graph].width - h_margin,data[mpd_graph].height / 2)
      if data[mpd_graph].graph_color then
        r,g,b,a = helpers.hexadecimal_to_rgba_percent(data[mpd_graph].graph_color)
        mpd_graph_context:set_source_rgb(r,g,b,a)
      else
        mpd_graph_context:set_source_rgb(0.5,0.7,0.1)
      end
      mpd_graph_context:set_line_width(1)
      mpd_graph_context:stroke()
    else
      local x=h_margin+h_rest
      for i=1,nb_columns_to_display do
        mpd_graph_context:rectangle(x,data[mpd_graph].height -(data[mpd_graph].height*(data[mpd_graph].values[i]/100)),w_pattern,h_pattern)
        x=x+pattern_lenght
      end
      if data[mpd_graph].graph_color then
        r,g,b,a = helpers.hexadecimal_to_rgba_percent(data[mpd_graph].graph_color)
        mpd_graph_context:set_source_rgb(r,g,b,a)
      else
        mpd_graph_context:set_source_rgb(0.5,0.7,0.1)
      end
      mpd_graph_context:fill()
    end
    --Text
    if data[mpd_graph].show_text == true then
      --Draw Text and it's background
      if data[mpd_graph].font_size == nil then
        data[mpd_graph].font_size = 9
      end
      mpd_graph_context:set_font_size(data[mpd_graph].font_size)
    
      if data[mpd_graph].background_text_color == nil then
        data[mpd_graph].background_text_color = "#000000dd" 
      end
      if data[mpd_graph].text_color == nil then
        data[mpd_graph].text_color = "#ffffffff" 
      end    
      
      local text=''
      local title
      local artist
      local album
      
      if data[mpd_graph].song_title then
        title = data[mpd_graph].song_title
      else
        title="n/a"
      end
      if data[mpd_graph].song_artist then
        artist = data[mpd_graph].song_artist
      else
        artist="n/a"
      end
      if data[mpd_graph].song_album then
        album = data[mpd_graph].song_album
      else
        album="n/a"
      end
      if data[mpd_graph].label then
        text=string.gsub(data[mpd_graph].label,"$title", title)
        text=string.gsub(text,"$artist", artist)
        text=string.gsub(text,"$album", album)
        --helpers.dbg({text})
      else
        text=artist .. ">" ..title .. ">" .. album
      end
      helpers.draw_text_and_background(mpd_graph_context, 
                                        text, 
                                        h_margin, 
                                        (data[mpd_graph].height/2) + (data[mpd_graph].font_size)/2, 
                                        data[mpd_graph].background_text_color, 
                                        data[mpd_graph].text_color,
                                        false,
                                        false)
    end
  end
mpd_graph.widget.image = capi.image.argb32(data[mpd_graph].width, data[mpd_graph].height, mpd_graph_surface:get_data())
end

function update(mpd_graph)
  data[mpd_graph].update_timer = capi.timer({timeout = 0.2})
  data[mpd_graph].update_timer:add_signal("timeout", function() data[mpd_graph].mpdinfos=check_mpd();generate(mpd_graph) end)
  data[mpd_graph].update_timer:start()
end

--local function mpd_info(mpd_graph)
--  data[mpd_graph].mpdinfos=check_mpd()
--  update_infos= capi.timer({timeout = 0.1 })
--  update_infos:add_signal("timeout", function() data[mpd_graph].mpdinfos=check_mpd() end)
--end

local function update_song_infos(mpd_graph)
  a_timer=capi.timer({timeout = 1 })
  a_timer:add_signal("timeout", function() get_song_infos(mpd_graph) end)
  a_timer:start()
end

function set_height(mpd_graph, height)
    if height >= 5 then
        data[mpd_graph].height = height
        generate(mpd_graph)
    end
    return mpd_graph
end

function set_width(mpd_graph, width)
    if width >= 5 then
        data[mpd_graph].width = width
        generate(mpd_graph)
    end
    return mpd_graph
end

function set_mpc_commands(mpd_graph)

  mpd_graph.widget:buttons(awful.util.table.join(
--toggle stop/start
    awful.button({ }, 1, function()

      if data[mpd_graph].mpdinfos["state"] == "Play" then
        mpd_send(mpd_graph,"stop")
        elseif data[mpd_graph].mpdinfos["state"] == "Stop" then
        mpd_send(mpd_graph,"play")
      end
    end),
--volume management
    awful.button({ }, 5, function()
      mpd_send(mpd_graph,"volume -5")
    end),
    awful.button({ }, 4, function()
      mpd_send(mpd_graph,"volume +5")
    end),
    awful.button({"Control"}, 5, function()
      mpd_send(mpd_graph,"prev")
    end),
awful.button({ "Control"}, 4, function()
      mpd_send(mpd_graph,"next")
    end)))
end
for _, prop in ipairs(properties) do
    if not _M["set_" .. prop] then
        _M["set_" .. prop] = function(mpd_graph, value)
            data[mpd_graph][prop] = value
            generate(mpd_graph)
            return mpd_graph
        end
    end
end

function new(args)
    local args = args or {}
    args.type = "imagebox"

    local width = args.width or 100
    local height = args.height or 20

    if width < 5 or height < 5 then return end

    local mpd_graph = {}
    mpd_graph.widget = capi.widget(args)
    mpd_graph.widget.resize = false

    data[mpd_graph] = { width = width, height = height, values = {}, mpdinfos = {}  }
    
    update_song_infos(mpd_graph)
    -- Set methods
    mpd_graph.update = update
    mpd_graph.set_mpc_commands = set_mpc_commands
    
    for _, prop in ipairs(properties) do
        mpd_graph["set_" .. prop] = _M["set_" .. prop]
    end

    mpd_graph.layout = args.layout or layout.horizontal.leftright
    return mpd_graph
end

setmetatable(_M, { __call = function(_, ...) return new(...) end })
