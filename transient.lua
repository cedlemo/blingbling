-- @author cedlemo
-- Modifications based on original work from Uli Schlachter
-- @copyright 2010 Uli Schlachter

local capi = {
    drawin = drawin,
    root = root,
    awesome = awesome,
    screen = screen,
    mouse = mouse
}
local setmetatable = setmetatable
local pairs = pairs
local type = type
local table = table
local string_format = string.format
local color = require("gears.color")
local object = require("gears.object")
local sort = require("gears.sort")
local beautiful = require("beautiful")
local surface = require("gears.surface")
local cairo = require("lgi").cairo

---Wibox with timeout
--@module blingbling.transient

--- This provides widget box windows. Every transient can also be used as if it were
-- a drawin. All drawin functions and properties are also available on transientes!
-- transient
local transient = { mt = {} }
transient.layout = require("wibox.layout")
transient.widget = require("wibox.widget")
transient.drawable = require("wibox.drawable")

--- Set the widget that the transient displays
function transient:set_widget(widget)
    self._drawable:set_widget(widget)
end

--- Set the background of the transient
-- @param c The background to use. This must either be a cairo pattern object,
--          nil or a string that gears.color() understands.
function transient:set_bg(c)
    self._drawable:set_bg(c)
end

--- Set the foreground of the transient
-- @param c The foreground to use. This must either be a cairo pattern object,
--          nil or a string that gears.color() understands.
function transient:set_fg(c)
    self._drawable:set_fg(c)
end

for _, k in pairs{ "buttons", "struts", "geometry", "get_xproperty", "set_xproperty" } do
    transient[k] = function(self, ...)
        return self.drawin[k](self.drawin, ...)
    end
end

local function setup_signals(_transient)
    local w = _transient.drawin

    local function clone_signal(name)
        _transient:add_signal(name)
        -- When "name" is emitted on transient.drawin, also emit it on transient
        w:connect_signal(name, function(_, ...)
            _transient:emit_signal(name, ...)
        end)
    end
    clone_signal("property::border_color")
    clone_signal("property::border_width")
    clone_signal("property::height")
    clone_signal("property::ontop")
    clone_signal("property::opacity")
    clone_signal("property::struts")
    clone_signal("property::visible")
    clone_signal("property::width")
    clone_signal("property::x")
    clone_signal("property::y")

    local d = _transient._drawable
    local function clone_signal(name)
        _transient:add_signal(name)
        -- When "name" is emitted on transient.drawin, also emit it on transient
        d:connect_signal(name, function(_, ...)
            _transient:emit_signal(name, ...)
        end)
    end
    clone_signal("property::surface")
end
--- Show the transient window according to the timeout set when creating the
-- transient window
function transient:show()
--    self:top_left()
    if not self.visible then
        self.visible = true
        local mytimer = timer({ timeout = self.timeout })
        mytimer:connect_signal("timeout", function () 
                                          if self.visible == true then
                                          self.visible=false
                                          mytimer:stop()
                                          end 
                                          end)
        mytimer:start()
    end
end
function transient:top_left()
    local current_screen = mouse.screen
    local geometry
    if self.parent then
       geometry = self.parent:geometry()
    else
       geometry = screen[current_screen].workarea
    end
    self:geometry({x=geometry.x, y=geometry.y}) 
end
function transient:top_center()
    local current_screen = mouse.screen
    local geometry
    if self.parent then
       geometry = self.parent:geometry()
    else
       geometry = screen[current_screen].workarea
    end
    local w = self.width
    local h = self.height
    local x = geometry.x + geometry.width/2 - w/2
    self:geometry({x=x, y=geometry.y}) 
end
function transient:top_right()
    local current_screen = mouse.screen
    local geometry
    if self.parent then
       geometry = self.parent:geometry()
    else
       geometry = screen[current_screen].workarea
    end
    local w = self.width
    local h = self.height
    local x = geometry.x + geometry.width - w
    self:geometry({x=x, y=geometry.y}) 
end
function transient:center()
    local current_screen = mouse.screen
    local geometry
    if self.parent then
       geometry = self.parent:geometry()
    else
       geometry = screen[current_screen].workarea
    end

    local w = self.width
    local h = self.height
    local x,y = 0
    x = ((geometry.width /2) + geometry.x) - w/2
    y = ((geometry.height /2) + geometry.y) - h/2
    self:geometry({x=x, y=y}) 
end
function transient:bottom_left()
    local current_screen = mouse.screen
    local geometry
    if self.parent then
       geometry = self.parent:geometry()
    else
       geometry = screen[current_screen].workarea
    end
    local w = self.width
    local h = self.height
    local x = geometry.x
    local y = geometry.y + geometry.height - h
    self:geometry({x=x, y=y}) 
end
function transient:bottom_center()
    local current_screen = mouse.screen
    local geometry
    if self.parent then
       geometry = self.parent:geometry()
    else
       geometry = screen[current_screen].workarea
    end
    local w = self.width
    local h = self.height
    local x = geometry.x + geometry.width/2 - w/2
    local y = geometry.y + geometry.height - h
    self:geometry({x=x, y=y}) 
end
function transient:bottom_right()
    local current_screen = mouse.screen
    local geometry
    if self.parent then
       geometry = self.parent:geometry()
    else
       geometry = screen[current_screen].workarea
    end
    local w = self.width
    local h = self.height
    local x = geometry.x + geometry.width - w
    local y = geometry.y + geometry.height - h
    self:geometry({x=x, y=y}) 
end
function transient:center_right()
    local current_screen = mouse.screen
    local geometry
    if self.parent then
       geometry = self.parent:geometry()
    else
       geometry = screen[current_screen].workarea
    end
    local w = self.width
    local h = self.height
    local x = geometry.x + geometry.width - w
    local y = geometry.y + geometry.height/2 - h/2
    self:geometry({x=x, y=y}) 
end
function transient:center_left()
    local current_screen = mouse.screen
    local geometry
    if self.parent then
       geometry = self.parent:geometry()
    else
       geometry = screen[current_screen].workarea
    end
    local w = self.width
    local h = self.height
    local x = geometry.x
    local y = geometry.y + geometry.height/2 - h/2
    self:geometry({x=x, y=y}) 
end
local function new(args)
    local ret = object()
    local w = capi.drawin(args)
    ret.drawin = w
    ret._drawable = transient.drawable(w.drawable, ret)
    
    if args.parent then
        ret.parent = args.parent
    end
    if args.timeout then
        ret.timeout = args.timeout
    else
        ret.timeout = 2
    end
    for k, v in pairs(transient) do
        if type(v) == "function" then
            ret[k] = v
        end
    end
    setup_signals(ret)
    ret.draw = ret._drawable.draw
    ret.widget_at = function(_, widget, x, y, width, height)
        return ret._drawable:widget_at(widget, x, y, width, height)
    end

    -- Set the default background
    ret:set_bg(args.bg or beautiful.bg_normal)
    ret:set_fg(args.fg or beautiful.fg_normal)

    -- Make sure the transient is drawn at least once
    ret.draw()

    -- Redirect all non-existing indexes to the "real" drawin
    setmetatable(ret, {
        __index = w,
        __newindex = w
    })
    ret.visible=false
--    if args.position then
--        if position == "center" then
--            self:center()
--        elseif position == "top-left" then
--            self:top_left()
--        elseif position == "top-center" then
--            self:top_center()
--        elseif position == "top-right" then
--            self:top_right()
--        elseif position == "bottom-left" then
--            self:bottom_left()
--        elseif position == "bottom-center" then
--            self:bottom_center()
--        elseif position == "bottom-right" then
--            self:bottom_right()
--        end
--    end
    return ret
end

--- Redraw a transient. You should never have to call this explicitely because it is
-- automatically called when needed.
-- @param transient
-- @name draw
-- @class function

--- Widget box object.
-- Every transient "inherits" from a drawin and you can use all of drawin's
-- functions directly on this as well. When creating a transient, you can specify a
-- "fg" and a "bg" color as keys in the table that is passed to the constructor.
-- All other arguments will be passed to drawin's constructor.
-- @class table
-- @name drawin

function transient.mt:__call(...)
    return new(...)
end

return setmetatable(transient, transient.mt)

-- vim: filetype=lua:expandtab:shiftwidth=4:tabstop=8:softtabstop=4:textwidth=80
