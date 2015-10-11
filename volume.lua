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

-- Isolate and return the default sink info from the given string
local function default_sink_info(output)
   local defaultSinkIdx, endMatch = string.find(output, "%s+*%sindex:%s%d+")

   if (defaultSinkIdx == nil) then
      return nil
   end
   local nextSinkIdx = string.find(output, "%s+^*%sindex:%s%d+", endMatch)
   if (nextSinkIdx == nil) then
      nextSinkIdx = output:len()
   end
   return string.sub(output, defaultSinkIdx, nextSinkIdx)
end

-- Get volume and mute state
local function get_master_infos(volume_graph)
   local state, volume = nil, nil

   if (data[volume_graph].pulseaudio == true) then
      local pastatus = awful.util.pread("pacmd list-sinks")
      local defaultSinkInfo = default_sink_info(pastatus)
      if (defaultSinkInfo) then
	 volume = string.match(defaultSinkInfo, "volume:.-%/%s+(%d+)%%")
	 state = string.match(defaultSinkInfo, "muted:%s(%a+)")
      end
   else
      local f=io.popen(data[volume_graph].cmd .. " get Master")
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
   end
   if (not state or state == "yes" or state == "off") then
      state = true  -- output is mute
   else
      state = false
   end
   if (not volume) then
      volume = 0
   end
   return state, volume
end

local function update_master(volume_graph)
   local state, value = nil, nil
   data[volume_graph].mastertimer = timer({timeout = 0.5})
   data[volume_graph].mastertimer:connect_signal("timeout", function() 
      state, value = get_master_infos(volume_graph)
      volume_graph:set_value(value/100)
      if state == false then
	 volume_graph:set_label(data[volume_graph].label)
      else
	 volume_graph:set_label("off")
      end
    end)
   data[volume_graph].mastertimer:start()
   return volume_graph
end

local function get_mpd_volume()
  local mpd_volume = 0

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
    end
  end
  f:close()
  return mpd_volume
end
---Link the widget to mpd's volume level. 
--@usage myvolume:update_mpd()
local function update_mpd(volume_graph)
    local state
    local value
    data[volume_graph].mastertimer = timer({timeout = 0.5})
    data[volume_graph].mastertimer:connect_signal("timeout", function() 
      value = get_mpd_volume(); volume_graph:set_value(value/100) 
    end)
        data[volume_graph].mastertimer:start()
end

-- Alsa command
local function set_alsa_master(mixer_cmd, parameters)
   local cmd = mixer_cmd .. " --quiet set Master " .. parameters
   local f=io.popen(cmd)
   f:close()
end

local function set_alsa_control(volume_graph)
   volume_graph:buttons(awful.util.table.join(
	   awful.button({ }, 1, function()
		 set_alsa_master(data[volume_graph].cmd, "toggle")
	   end),
	   awful.button({ }, 5, function()
		 set_alsa_master(data[volume_graph].cmd, data[volume_graph].increment .. "%-")
	   end),
	   awful.button({ }, 4, function()
		 set_alsa_master(data[volume_graph].cmd, data[volume_graph].increment .. "%+")
   end)))
end

local function set_pa_control(volume_graph)
   volume_graph:buttons(awful.util.table.join(
        awful.button({ }, 1, function()
	      awful.util.spawn_with_shell("pactl set-sink-mute @DEFAULT_SINK@ toggle")
	end),
	awful.button({ }, 5, function()
	      awful.util.spawn_with_shell("pactl set-sink-volume @DEFAULT_SINK@ -" .. data[volume_graph].increment .. "%")
	end),
	awful.button({ }, 4, function()
	      awful.util.spawn_with_shell("pactl set-sink-volume @DEFAULT_SINK@ +" .. data[volume_graph].increment .. "%")
   end)))
end

--- Link the widget to the master channel of your system.
--a left clic toggle mute/unmute, wheel up to increase the volume and wheel down to decrease the volume
--@usage myvolume:set_master_control()
local function set_master_control(volume_graph)
   if (data[volume_graph].pulseaudio == true) then
      set_pa_control(volume_graph)
   else
      set_alsa_control(volume_graph)
   end
end

--- Create a volume_graph widget.
-- @param args Standard widget() arguments. This is a table that accepts
-- different keys:
--
--    <code>{ cmd = "amixer -c 1", label = "$percent%", graph_color = "#005500" }</code>
--
--    The default cmd is "amixer" which should be good enough if you only have one audio output.
--    You can provide another command based on your need. For example, the "amixer -c 1" command
--    has been given by k3rni contributor and allow to select the audio card. (see 
--    https://github.com/cedlemo/blingbling/pull/30 for more information.
--
--    The other keys are those related to the graph itself and are the same that those
--    used with the triangular_progress_graph
-- @return A graph widget.
function volume.new(args)
   local args = args or {}
   local volume_graph = triangular_progress_graph(args)
    data[volume_graph] = {}
    data[volume_graph].label = args.label or "$percent%"
    data[volume_graph].cmd = args.cmd or "amixer"
    data[volume_graph].increment = args.increment or 2
    data[volume_graph].pulseaudio = args.pulseaudio or false
    volume_graph.update_master = update_master
    volume_graph.update_mpd= update_mpd
    volume_graph.set_master_control = set_master_control
    return volume_graph
end

function volume.mt:__call(...)
    return volume.new(...)
end

return setmetatable(volume, volume.mt)

