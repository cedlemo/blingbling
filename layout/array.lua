-------------------------------------------------
-- @author Gregor Best <farhaven@googlemail.com>
-- @copyright 2009 Gregor Best
-- @release v3.4.10
-------------------------------------------------

-- Grab environment
local ipairs = ipairs
local pairs = pairs
local type = type
local table = table
local math = math
local helpers = require('blingbling.helpers')
local util = require("awful.util")
local default = require("awful.widget.layout.default")
local margins = awful.widget.layout.margins

--- Horizontal widget layout
module("blingbling.layout.array")


function line(direction, bounds, widgets, screen)
  local geometries = { }
  local initial_width = bounds.width 
  local initial_height = bounds.height
  local line_height = 0
  local x = 0
  local greatest_top_margin = 0
  local greatest_bottom_margin = 0
  -- we are only interested in tables and widgets
  local keys = util.table.keys_filter(widgets, "table", "widget")

  for _, k in ipairs(keys) do
    local v = widgets[k]
    if type(v) == "widget" then
      local g
      if v.visible then
        g = v:extents(screen)
      else
        g = {
              width  = 0,
              height = 0,
            }
      end

      if g.width > bounds.width then
        g.width = bounds.width
      end
      local widget_margins = {}
      if margins[v] then
        widget_margins = margins[v]
      else
        widget_margins.top = 0
        widget_margins.bottom = 0
      end
            
      if widget_margins.top and widget_margins.top > greatest_top_margin then
        greatest_top_margin = widget_margins.top
      end
      if widget_margins.bottom and widget_margins.bottom > greatest_bottom_margin then
        greatest_bottom_margin = widget_margins.bottom
      end
            
      g.y = widget_margins.top or 0

      if direction == "leftright" then
        g.x = x + (widget_margins.left or 0)
        x = x + g.width + (widget_margins.left or 0)
      else
        g.x = x + bounds.width - g.width + (widget_margins.left or 0)
      end
      line_height = g.height
      bounds.width = bounds.width - (g.width + (widget_margins.left or 0 ))
      table.insert(geometries, g)
    end
  end
  --The rest: a line use all width for it's y position but let all width for the next line.
  bounds.width = initial_width
  bounds.height = initial_height - (line_height + greatest_top_margin + greatest_bottom_margin)
  geometries.free = util.table.clone(bounds)
  geometries.free.x = 0
  geometries.free.y = line_height + greatest_top_margin + greatest_bottom_margin

  return geometries
end

function line_leftright( ... )
  return line("leftright",  ...)
end

function line_rightleft(...)
  return line("rightleft", ...)
end
function line_center(bounds, widgets, screen)
  -- we are only interested in tables and widgets
  local keys = util.table.keys_filter(widgets, "table", "widget")
  --Check How many widgets we have:
  local nb_elements = 0
    for _, k in ipairs(keys) do
      local v = widgets[k]
      if type(v) == "widget" then
        nb_elements = nb_elements + 1
      end
    end
    
  local fixed_width = bounds.width / nb_elements
  local geometries = { }
  local initial_width = bounds.width 
  local initial_height = bounds.height
  local line_height = 0
  local greatest_top_margin = 0
  local greatest_bottom_margin = 0
  local x = 0 
  local y = 0
  -- we are only interested in widgets
  local keys = util.table.keys_filter(widgets, "table", "widget")
  for _, k in ipairs(keys) do
    local v = widgets[k]
    if type(v) == "widget" then
      local g
      if v.visible then
        g = v:extents(screen)
      else
        g = {
              width  = 0,
              height = 0,
            }
      end

      if g.width > fixed_width then
        g.width = fixed_width
      end
            
      local widget_margins = {}
      if margins[v] then
        widget_margins = margins[v]
      else
        widget_margins.top = 0
        widget_margins.bottom = 0
      end
           
      g.y =  y + widget_margins.top
           
      if widget_margins.top and widget_margins.top > greatest_top_margin then
        greatest_top_margin = widget_margins.top
      end
      if widget_margins.bottom and widget_margins.bottom > greatest_bottom_margin then
        greatest_bottom_margin = widget_margins.bottom
      end
            
      g.x = x + ((fixed_width/2) - (g.width/2)) 
      x = x + fixed_width
      line_height = g.height
      bounds.width = bounds.width - fixed_width
      table.insert(geometries, g)
    end
  end
  --The rest: a line use all width for it's y position but let all width for the next line.
  bounds.width = initial_width
  bounds.height = initial_height - ( line_height + greatest_top_margin + greatest_bottom_margin)
  geometries.free = util.table.clone(bounds)
  geometries.free.x = x 
  geometries.free.y = line_height + greatest_top_margin + greatest_bottom_margin
   return geometries
end
function stack_lines(bounds, widgets, screen)
  local geometries = { }
  local x = 0
  local y = 0
  -- we are only interested in tables and widgets
  local keys = util.table.keys_filter(widgets, "table", "widget")

  for _, k in ipairs(keys) do
    local v = widgets[k]
    if type(v) == "table" then
      local layout = v.layout 
      local g = layout(bounds, v, screen)
      for _, v in ipairs(g) do
        v.x = v.x + x
        v.y = v.y + y 
        table.insert(geometries, v)
      end
      bounds = g.free
      x= 0 
      y= g.free.y + y
    end
  end
  geometries.free = util.table.clone(bounds)
  geometries.free.x = 0
  geometries.free.y = 0
  geometries.free.width = 0
  geometries.free.height = 0
  return geometries
  
end
