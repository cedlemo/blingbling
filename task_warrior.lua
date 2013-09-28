-- @author cedlemo  

local helpers = require("blingbling.helpers")
local awful = require("awful")
local naughty = require("naughty")
local wibox = require("wibox")
local superproperties = require("blingbling.superproperties")
local string = string
local math = math
local ipairs = ipairs
local next = next
local pairs = pairs
local type = type
local setmetatable = setmetatable
local table = table
local print = print

---Task warrior menu
--@module blingbling.task_warrior

local task_warrior = { mt = {} }

local data = setmetatable( {}, { __mode = "k"})

--Get projects list from task warrior
local function get_projects(tw_menu)
  data[tw_menu].projects={}
  local my_projects=awful.util.pread("task projects")
  --remove first line
  my_projects=string.gsub(my_projects,
                          "\nProject%s*Tasks%s*Pri%:None%s*Pri%:L%s*Pri%:M%s*Pri%:H%s*",
                          "")

  --generate the list of projects

  --if string.find(my_projects,"No Projects") ~= nil then
  --  data[tw_menu].projects=nil
  --end
  for project, project_tasks in string.gmatch(my_projects,"\n([%w%(%)%-%_%.]*)%s%s+(%d*)","%1 %2") do
    project=string.gsub(project,"\n","")
    table.insert(data[tw_menu].projects, {name =project, nb_tasks = project_tasks} )
  end

end

local function generate_tasks_management_submenu(tw_menu, task_id)
  management_submenu={}
  table.insert(management_submenu,{ "Task "..task_id..": set done", "task "..task_id .. " done > /dev/null 2>&1", data[tw_menu].task_done_icon })
 return management_submenu
end

local function get_tasks(tw_menu, project)
  local tasks={}
  if project=="(none)" then
    project=""
  end
  local my_tasks=awful.util.pread("task rc.defaultwidth=0 project:\"".. project.."\" minimal ")
  --escape specific char ( need to be extended)
  project_pattern=string.gsub(project,"%-","%%-") or ""
  project_pattern=string.gsub(project_pattern,"%_","%%_") or ""
  project_pattern=string.gsub(project_pattern,"%.","%%.") or ""

  each_tasks={}
  each_tasks=helpers.split(my_tasks,"\n")
  for i,v in ipairs(each_tasks) do
    for my_task_id, my_task in string.gmatch(v,"%s*(%d*)%s+"..project_pattern.."%s+(.*)$","%1 %2") do
    table.insert(tasks, {my_task ,generate_tasks_management_submenu(tw_menu,my_task_id),data[tw_menu].task_icon})
    end
  end
  return tasks
end

local function generate_menu(tw_menu)
  my_menu={}
  my_submenu={}
  
  get_projects(tw_menu)
  
  if data[tw_menu].projects ~= {} then
    for i,v in ipairs(data[tw_menu].projects) do
      my_submenu=get_tasks(tw_menu,v.name)
      table.insert(my_menu,{v.name .. " (" ..v.nb_tasks ..")", my_submenu, data[tw_menu].project_icon })
    end

    data[tw_menu].menu= awful.menu({ items = my_menu, theme = {width = data[tw_menu].width }})
  else
    data[tw_menu].menu = awful.menu({ items = { {"No projects"}}, theme = {width = data[tw_menu].width }})
  end
  return tw_menu 
end

local function display_menu(tw_menu)
  tw_menu:buttons(awful.util.table.join(
    awful.button({ }, 1, function()
      if data[tw_menu].menu_visible == "false" then
        data[tw_menu].menu_visible = "true"
        generate_menu(tw_menu )
        data[tw_menu].menu:show()
      else
        data[tw_menu].menu:hide()  
        data[tw_menu].menu_visible = "false" 
      end
    end),
    awful.button({ }, 3, function()
        data[tw_menu].menu:hide()  
        data[tw_menu].menu_visible = "false" 
    end)
))
end

---Set the icon for "set task done" menu item.
--@usage my_tasks:set_task_done_icon(an_image_file_name)
--@param tw_menu a task warrior menu
--@param an_image an image file name
function task_warrior.set_task_done_icon(tw_menu,an_image)
  data[tw_menu].task_done_icon=an_image
  return tw_menu
end

---Set the icon for project menu item.
--@usage my_tasks:set_project_icon(an_image_file_name)
--@param tw_menu a task warrior menu
--@param an_image an image file name
function set_project_icon(tw_menu,an_image)
  data[tw_menu].project_icon=an_image
  return tw_menu
end

---Set the icon for task menu item.
--@usage my_tasks:set_task_icon(an_image_file_name)
--@param tw_menu a task warrior menu
--@param an_image an image file name
function set_task_icon(tw_menu,an_image)
  data[tw_menu].task_icon=an_image
  return tw_menu
end
---Create new task warrior menu.
--@usage my_tasks=blingbling.task_warrior.new({ menu_icon = an_icon_file, width = integer --[[optional--]], project_icon = an_icon_file --[[optional--]], task_icon = an_icon_file --[[optional--]], task_icon_done = an_icon_file --[[optional--]]} )
--@param args a table 
--@return tw_menu a task warrior menu
function task_warrior.new(args)
  local args = args or {}
  local tw_menu = wibox.widget.imagebox()
  tw_menu:set_image(args.menu_icon)
  data[tw_menu]={ projects= {},
                  tasks={},
                  menu_visible = "false",
                  width = args.width or superproperties.menu_width,
                  menu={},
                  project_icon = args.project_icon or nil,
                  task_icon = args.task_icon or nil,
                  task_done_icon= args.task_done or nil,
                  } 
  tw_menu.set_task_done_icon = set_task_done_icon
  tw_menu.set_task_icon = set_task_icon
  tw_menu.set_project_icon = set_project_icon
  generate_menu(tw_menu)
  display_menu(tw_menu)
  return tw_menu 
end
function task_warrior.mt:__call(...)
    return task_warrior.new(...)
end

return setmetatable(task_warrior, task_warrior.mt)
