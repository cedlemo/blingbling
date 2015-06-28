-- @author cedlemo  

local setmetatable = setmetatable
local math = math
local type = type
local string = string
local awful = require("awful")
local triangular_progress_graph = require('blingbling.triangular_progress_graph')

---Volume widget
--@module blingbling.volume

local volume = { mt = {} }

local data = setmetatable({}, { __mode = "k" })

local function get_master_infos()
  local state, volume = nil, nil
  local f=io.popen("amixer get Master")
  for line in f:lines() do
    if string.match(line, "%s%[%d+%%%]%s") ~= nil then
      volume=string.match(line, "%s%[%d+%%%]%s")
      volume=string.gsub(volume, "[%[%]%%%s]","")
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
    local state, value = nil, nil
    data[volume_graph].mastertimer = timer({timeout = 0.5})
    data[volume_graph].mastertimer:connect_signal("timeout", function() 
      state, value = get_master_infos()
      volume_graph:set_value(value/100)
      if state == "off" then
        volume_graph:set_label("off")
      else
        volume_graph:set_label(data[volume_graph].label) 
      end
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
      value = get_mpd_volume(); volume_graph:set_value(value/100) 
    end)
        data[volume_graph].mastertimer:start()
end

---Link the widget to the master channel of your system (uses amixer).
--a left clic toggle mute/unmute, wheel up to increase the volume and wheel down to decrease the volume
--@usage myvolume:set_master_control()
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

---Create a volume_graph widget.
-- @param args Standard widget() arguments. You should add width and height
-- key to set graph geometry.
-- @return A graph widget.
function volume.new(args)
    local args = args or {}
    local volume_graph = triangular_progress_graph(args)    
    data[volume_graph] = {}
    data[volume_graph].label = args.label or "$percent%"
    volume_graph.update_master = update_master
    volume_graph.update_mpd= update_mpd
    volume_graph.set_master_control = set_master_control

    return volume_graph
end

function volume.mt:__call(...)
    return volume.new(...)
end

return setmetatable(volume, volume.mt)

