local table = table
local awful =require("awful")
---Dialog menus for reboot/shutdown your system
module("blingbling.system")

local shutdown_cmd= 'dbus-send --system --print-reply --dest="org.freedesktop.ConsoleKit" /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Stop'
local reboot_cmd='dbus-send --system --print-reply --dest="org.freedesktop.ConsoleKit" /org/freedesktop/ConsoleKit/Manager org.freedesktop.ConsoleKit.Manager.Restart'


function shutdownmenu(button_image, accept_image, cancel_image)
  if not accept_image then
    accept_image = nil
  end
  if not cancel_image then
    cancel_image = nil
  end
  
  shutdownmenu= awful.menu({ items = { 
                                     { "Shutdown", shutdown_cmd, accept_image },
                                     { "Cancel", "", cancel_image }
                                  }
                        })



  shutdownbutton = awful.widget.launcher({ image =button_image,
                                             menu = shutdownmenu })
  return shutdownbutton
end

function rebootmenu(an_image, accept_image, cancel_image)
  if not accept_image then
    accept_image = nil
  end
  if not cancel_image then
    cancel_image = nil
  end
  rebootmenu= awful.menu({ items = { 
                                    { "Reboot", reboot_cmd, accept_image },
                                    { "Cancel", "" , cancel_image}
                                  }
                        })

  rebootbutton = awful.widget.launcher({ image =an_image,
                                           menu = rebootmenu })
  return rebootbutton
end


