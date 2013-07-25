local table = table
local awful = require("awful")
local awesome = require("awesome")
---Three menu launchers for main, reboot and shutdown your system.

local shutdown_cmd= 'systemctl poweroff'
local reboot_cmd='systemctl reboot'
local lock_cmd='xscreensaver-command -lock'

--- Main menu launcher
--Create a button which will spawn a menu allowing the user to shutdown, reboot, logout and lock screen
--@param shutdown_image the image that will be displayed with the shutdown option
--@param reboot_image the image that will be displayed with the reboot option
--@param logout_image the image that will be displayed with the logout option
--@param lock_image the image that will be displayed with the lock option
local function mainmenu(main_image, shutdown_image, reboot_image, logout_image, lock_image)
  if not shutdown_image then
    shutdown_image = nil
  end
  if not reboot_image then
    reboot_image = nil
  end
  if not logout_image then
    logout_image = nil
  end
  if not shutdown_image then
    logout_image = nil
  end

  powermenu = awful.menu({ items = { 
                                     { "Shutdown", shutdown_cmd, shutdown_image }, 
                                     { "Reboot", reboot_cmd, reboot_image }, 
                                     { "Logout", function() awesome.quit() end, logout_image },
                                     { "Lock", lock_cmd, lock_image } 
                                   }
                         })
  return awful.widget.launcher({ image = main_image, 
                                 menu = powermenu })
end

---Shutdown menu launcher
--Create a button with an accept/cancel menu for shutdown the system: shutdown=blingbling.system.shutdownmenu(launcher_image, menu_dialog_image_ok, menu_.dialog_image_cancel)
--@param button_image an image file that will be displayed in the wibox
--@param accept_image an image file for the accept menu entry
--@param cancel_image an image file for the cancel menu entry
local function shutdownmenu(button_image, accept_image, cancel_image)
  if not accept_image then
    accept_image = nil
  end
  if not cancel_image then
    cancel_image = nil
  end
  
  shutdownmenu = awful.menu({ items = { 
                                        { "Shutdown", shutdown_cmd, accept_image },
                                        { "Cancel", "", cancel_image }
                                      }
                            })

  shutdownbutton = awful.widget.launcher({ image = button_image,
                                           menu = shutdownmenu })
  return shutdownbutton
end

---Reboot menu launcher
--Create a button with an accept/cancel menu for reboot the system: reboot=blingbling.system.rebootmenu(launcher_image, menu_dialog_image_ok, menu_.dialog_image_cancel)
--@param button_image an image file that will be displayed in the wibox
--@param accept_image an image file for the accept menu entry
--@param cancel_image an image file for the cancel menu entry
local function rebootmenu(button_image, accept_image, cancel_image)
  if not accept_image then
    accept_image = nil
  end
  if not cancel_image then
    cancel_image = nil
  end
  rebootmenu = awful.menu({ items = { 
                                      { "Reboot", reboot_cmd, accept_image },
                                      { "Cancel", "" , cancel_image}
                                    }
                          })

  rebootbutton = awful.widget.launcher({ image = button_image,
                                           menu = rebootmenu })
  return rebootbutton
end

return {
  shutdownmenu = shutdownmenu;
  rebootmenu = rebootmenu;
  mainmenu = mainmenu
}
