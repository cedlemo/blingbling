local helpers = require("blingbling.helpers")
local awful = require("awful")
local naughty = require("naughty")
local string = string
local math = math
local ipairs = ipairs
local next = next
local pairs = pairs
local type = type
local setmetatable = setmetatable
local table = table
local wibox = require("wibox")

local udisks_glue = { mt = {} }

local data = setmetatable( {}, { __mode = "k"})


local function udisks_send(ud_menu,command,a_device)
  local s=""
  data[ud_menu].menu_visible = "false"
  s=s .. "udisks --"..command.." "..a_device 
  return s
end

local function mounted_submenu(ud_menu, a_device)
  local my_submenu= {
    { "umount",udisks_send(ud_menu,"unmount", a_device),data[ud_menu].umount_icon}--,
  }
  return my_submenu
end

local function unmounted_submenu(ud_menu,a_device)
  local my_submenu= {
    { "mount",udisks_send(ud_menu,"mount", a_device),data[ud_menu].mount_icon}--, 
  }
  return my_submenu
end
local function unmount_multiple_partitions(ud_menu, mount_points)
  for _,m in ipairs(mount_points) do
      awful.util.pread(udisks_send(ud_menu, "unmount", m))
  end
end
local function generate_menu(ud_menu)
--all_devices={device_name={partition_1,partition_2}
--devices_type={device_name=Usb or Cdrom}
--partition_state={partition_name = mounted or unmounted}
  my_menu={}
  debug=1 
  if next(data[ud_menu].all_devices) ~= nil then
    for k,v in pairs(data[ud_menu].all_devices) do
      local device_type=data[ud_menu].devices_type[k]
      local action=""
      if device_type == "USB" then
        action="detach"
      else
        action="eject"
      end
      local check_remain_mounted_partition =0
      my_submenu={}
      local mounted_partitions = {}
      for j,x in ipairs(v) do
        if data[ud_menu].partition_state[x] == "mounted" then
          check_remain_mounted_partition = 1
          table.insert(my_submenu,{x, mounted_submenu(ud_menu, x), data[ud_menu][device_type.."_icon"]})
          table.insert(mounted_partitions,x)
        else
          table.insert(my_submenu,{x, unmounted_submenu(ud_menu, x), data[ud_menu][device_type.."_icon"]})
        end
      end
      if check_remain_mounted_partition == 1 then
        table.insert(my_submenu,{"unmount all", unmount_multiple_partitions(ud_menu, mounted_partitions ), data[ud_menu]["umount_icon"]})
        --table.insert(my_submenu,{"Can\'t "..action, {{k .." busy"}}, data[ud_menu][action.."_icon"]})
      else
        table.insert(my_submenu,{action, udisks_send(ud_menu, action, k), data[ud_menu][action.."_icon"]})
      end
      table.insert(my_menu, {k, my_submenu, data[ud_menu][device_type.."_icon"]})
    end
  else 
    my_menu={{"No media",""}}
  end
  data[ud_menu].menu= awful.menu({ items = my_menu,
  })
  return ud_menu 
end

local function display_menu(ud_menu)
  ud_menu:buttons(awful.util.table.join(
    awful.button({ }, 1, function()
      if data[ud_menu].menu_visible == "false" then
        data[ud_menu].menu_visible = "true"
        generate_menu(ud_menu )
        data[ud_menu].menu:show()
      else
        data[ud_menu].menu:hide()  
        data[ud_menu].menu_visible = "false" 
      end
    end),
    awful.button({ }, 3, function()
        data[ud_menu].menu:hide()  
        data[ud_menu].menu_visible = "false" 
    end)
))
end

function mount_device(ud_menu,device, mount_point, device_type, filesystem) 
--  generate the device_name
  if device_type == "USB" then
    device_name = string.gsub(device,"%d*","")
  else 
    device_name=device
  end
--  add all_devices entry:
--  check if device is already registred
  if data[ud_menu].all_devices[device_name] == nil then
--      device not yet registred
      data[ud_menu].all_devices[device_name]={device}
      data[ud_menu].devices_type[device_name] = device_type
  else
--      device, registred, check if partition already registred      
      partition_already_registred = 0
      for i, v in ipairs(data[ud_menu].all_devices[device_name]) do
        if v == device then
          partition_already_registred = 1
        end
      end
      if partition_already_registred == 0 then
        table.insert(data[ud_menu].all_devices[device_name],device)
      end
  end
  data[ud_menu].partition_state[device]="mounted"
  data[ud_menu].menu:hide()  
  data[ud_menu].menu_visible = "false"
  -- naughty.notify({title = device_type..":", text =device .. " mounted on" .. mount_point, timeout = 10})
  naughty.notify({title = "Udisks " .. device_type .. " " .. filesystem .. ":", text =device .. " mounted on" .. mount_point, icon="/home/michael/.config/icons/usb_eject.png", timeout = 10, width = 300})

end

function unmount_device(ud_menu, device, mount_point, device_type)
  data[ud_menu].partition_state[device]="unmounted"
  data[ud_menu].menu:hide()  
  data[ud_menu].menu_visible = "false"
  -- naughty.notify({title = device_type..":", text = device .." unmounted", timeout = 10})
  naughty.notify({title = device_type ..":", text = device .." removed", icon="/home/michael/.config/icons/usb_unmount.png", timeout = 10, width = 300})

end

function remove_device(ud_menu, device, mount_point, device_type )
  local device_name=""
  if device_type == "USB" then
    device_name=string.gsub(device,"%d*","")
  else
    device_name = device
  end
--Remove the partitions
  if data[ud_menu].all_devices[device_name] ~= nil then 
    for i,v in ipairs(data[ud_menu].all_devices[device_name]) do
      if v == device then
        table.remove(data[ud_menu].all_devices[device_name],i)
        helpers.hash_remove(data[ud_menu].partition_state, device)
      end
    end
  end
--Remove the device if no remaining partition
  if data[ud_menu].all_devices[device_name] ~= nil and  #data[ud_menu].all_devices[device_name] == 0 then
    helpers.hash_remove(data[ud_menu].all_devices, device_name)
    helpers.hash_remove(data[ud_menu].devices_type, device_name)
  end
  data[ud_menu].menu:hide()  
  data[ud_menu].menu_visible = "false"
  -- naughty.notify({title = device_type ..":", text = device .." removed", timeout = 10})
  naughty.notify({title = device_type ..":", text = device .." removed", icon="/home/michael/.config/icons/usb_remove.png", timeout = 10, width = 300})
end

function set_mount_icon(ud_menu,an_image)
  data[ud_menu].mount_icon=an_image
  return ud_menu
end
function set_umount_icon(ud_menu,an_image)
  data[ud_menu].umount_icon=an_image
  return ud_menu
end
function set_detach_icon(ud_menu,an_image)
  data[ud_menu].detach_icon=an_image
  return ud_menu
end
function set_eject_icon(ud_menu,an_image)
  data[ud_menu].eject_icon=an_image
  return ud_menu
end
function set_Usb_icon(ud_menu,an_image)
  data[ud_menu].Usb_icon=an_image
  return ud_menu
end
function set_Cdrom_icon(ud_menu,an_image)
  data[ud_menu].Cdrom_icon=an_image
  return ud_menu
end

function udisks_glue.new(args)
  local args = args or {}
  local ud_menu
  ud_menu = wibox.widget.imagebox()
  ud_menu:set_image(args.menu_icon)
   
  data[ud_menu]={ image = menu_icon, 
                  all_devices= {},
                  devices_type={},
                  partition_state={}, 
                  menu_visible = "false", 
                  menu={},
                  Cdrom_icon=args.Cdrom_icon,
                  Usb_icon=args.Usb_icon,
                  mount_icon=args.mount_icon,
                  umount_icon=args.umount_icon,
                  detach_icon=args.detach_icon,
                  eject_icon=args.eject_icon,
                  } 
  ud_menu.mount_device = mount_device
  ud_menu.unmount_device = unmount_device
  ud_menu.remove_device = remove_device
  ud_menu.set_mount_icon = set_mount_icon
  ud_menu.set_umount_icon = set_umount_icon
  ud_menu.set_detach_icon = set_detach_icon
  ud_menu.set_eject_icon = set_eject_icon
  ud_menu.set_Usb_icon = set_Usb_icon
  ud_menu.set_Cdrom_icon = set_Cdrom_icon
  generate_menu(ud_menu)
  display_menu(ud_menu)
  return ud_menu 
end

function udisks_glue.mt:__call(...)
    return udisks_glue.new(...)
end

return setmetatable(udisks_glue, udisks_glue.mt)
