local naughty= require("naughty")
local string = require("string")

module("blingbling.helpers")

function dbg(vars)
  local text = ""
  for i=1, #vars do text = text .. vars[i] .. " | " end
  naughty.notify({ text = text, timeout = 15 })
end

function hexadecimal_to_rgba_percent(my_color)
  --check if color is a valid hex color else return white
  if string.find(my_color,"#[0-f][0-f][0-f][0-f][0-f]") then
  --delete #
    my_color=string.gsub(my_color,"^#","")
    r=string.format("%d", "0x"..string.sub(my_color,1,2))
    v=string.format("%d", "0x"..string.sub(my_color,3,4))
    b=string.format("%d", "0x"..string.sub(my_color,5,6))
    if string.sub(my_color,7,8) == "" then
      a=255
    else
      a=string.format("%d", "0x"..string.sub(my_color,7,8))
    end
  else
    r=255
    v=255
    b=255
    a=255
   end
  return r/255,v/255,b/255,a/255
end

function split(str, pat)
  local t = {}  -- NOTE: use {n = 0} in Lua-5.0
  local fpat = "(.-)" .. pat
  local last_end = 1
  local s, e, cap = string.find(str,fpat, 1)
  while s do
    if s ~= 1 or cap ~= "" then
      table.insert(t,cap)
    end
    last_end = e+1
    s, e, cap = string.find(str,fpat, last_end)
  end
  if last_end <= #str then
    cap = string.sub(str,last_end)
    table.insert(t, cap)
  end
  return t
end
