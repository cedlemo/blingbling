--@author cedlemo
local table = table
local awful = require("awful")
local superproperties = require('blingbling.superproperties')

---launchers for reboot, shutdown, shutdown, logout or lock menus for your system.
--@module blingbling.system

local system = {}
local shutdown_cmd= 'systemctl poweroff'
local reboot_cmd='systemctl reboot'
local lock_cmd='xscreensaver-command -lock'

---Main menu launcher.
--Create a button which will spawn a menu allowing the user to shutdown, reboot, logout and lock screen
--Only the first parameter is mandatory. The other values can be nil and specified in the theme.lua via the theme.blingbling table. See the superproperties module documentation.
--@usage mymainmenu = system.mainmenu(main_image, shutdown_image, reboot_image, logout_image, lock_image)
--@param main_image the image that will be displayed with the shutdown option
--@param shutdown_image the image that will be displayed with the shutdown option
--@param reboot_image the image that will be displayed with the reboot option
--@param logout_image the image that will be displayed with the logout option
--@param lock_image the image that will be displayed with the lock option
function system.mainmenu(main_image, shutdown_image, reboot_image, logout_image, lock_image)
  if not shutdown_image then
    shutdown_image = superproperties.shutdown or nil
  end
  if not reboot_image then
    reboot_image = superproperties.reboot or nil
  end
  if not logout_image then
    logout_image = superproperties.logout or nil
  end
  if not lock_image then
    lock_image = nil
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

---Shutdown menu launcher.
--Create a button with an accept/cancel menu for shutdown the system 
--No mandatory parameter. All values can be nil and specified in the theme.lua via the theme.blingbling table. See the superproperties module documentation.
--@usage shutdown=blingbling.system.shutdownmenu(launcher_image, menu_dialog_image_ok, menu_.dialog_image_cancel)
--@param button_image an image file that will be displayed in the wibox
--@param accept_image an image file for the accept menu entry
--@param cancel_image an image file for the cancel menu entry
function system.shutdownmenu(button_image, accept_image, cancel_image)
  if not button_image then
		button_image = superproperties.shutdown or nil
	end
	if not accept_image then
    accept_image = superproperties.accept or nil
  end
  if not cancel_image then
    cancel_image = superproperties.cancel or nil
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

---Lock menu launcher.
--Create a button with an accept/cancel menu for locking the system: 
--No mandatory parameter. All values can be nil and specified in the theme.lua via the theme.blingbling table. See the superproperties module documentation.
--@usage shutdown=blingbling.system.lockmenu(launcher_image, menu_dialog_image_ok, menu_.dialog_image_cancel)
--@param button_image an image file that will be displayed in the wibox
--@param accept_image an image file for the accept menu entry
--@param cancel_image an image file for the cancel menu entry
function system.lockmenu(button_image, accept_image, cancel_image)
  if not button_image then
		button_image = superproperties.lock or nil
	end
	if not accept_image then
    accept_image = superproperties.accept or nil
  end
  if not cancel_image then
    cancel_image = superproperties.cancel or nil
  end
  
  shutdownmenu = awful.menu({ items = { 
                                        { "Lock", lock_cmd, accept_image },
                                        { "Cancel", "", cancel_image }
                                      }
                            })

  shutdownbutton = awful.widget.launcher({ image = button_image,
                                           menu = shutdownmenu })
  return shutdownbutton
end

---Reboot menu launcher.
--Create a button with an accept/cancel menu for reboot the system: 
--No mandatory parameter. All values can be nil and specified in the theme.lua via the theme.blingbling table. See the superproperties module documentation.
--@usage reboot=blingbling.system.rebootmenu(launcher_image, menu_dialog_image_ok, menu_.dialog_image_cancel)
--@param button_image an image file that will be displayed in the wibox
--@param accept_image an image file for the accept menu entry
--@param cancel_image an image file for the cancel menu entry
function system.rebootmenu(button_image, accept_image, cancel_image)
  if not button_image then
		button_image = superproperties.reboot or nil
	end
	if not accept_image then
    accept_image = superproperties.accept or nil
  end
  if not cancel_image then
    cancel_image = superproperties.cancel or nil
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
---Logout menu launcher.
--Create a button with an accept/cancel menu for reboot the system: 
--No mandatory parameter. All values can be nil and specified in the theme.lua via the theme.blingbling table. See the superproperties module documentation.
--@usage logout=blingbling.system.logouttmenu(launcher_image, menu_dialog_image_ok, menu_.dialog_image_cancel)
--@param button_image an image file that will be displayed in the wibox
--@param accept_image an image file for the accept menu entry
--@param cancel_image an image file for the cancel menu entry
function system.logoutmenu(button_image, accept_image, cancel_image)
  if not buttom_image then
		button_image = superproperties.logout or nil
	end
	if not accept_image then
    accept_image = superproperties.accept or nil
  end
  if not cancel_image then
    cancel_image = superproperties.cancel or nil
  end
  logoutmenu = awful.menu({ items = { 
                                      { "Logout", awesome.quit, accept_image },
                                      { "Cancel", "" , cancel_image}
                                    }
                          })

  logoutbutton = awful.widget.launcher({ image = button_image,
                                           menu = logoutmenu })
  return logoutbutton
end
return system
