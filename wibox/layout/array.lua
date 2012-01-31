local setmetatable = setmetatable
local table = table
local pairs = pairs
local type = type
local base = require("wibox.layout.base")
local widget_base = require("wibox.widget.base")
local helpers = require("blingbling.helpers")
module("blingbling.wibox.layout.array")

-- Draw the given align layout. dir describes the orientation of the layout, "x"
-- means horizontal while "y" is vertical.
local function draw(dir, layout, wibox, cr, width, height)
    local x=0
    local y=0
    local max_line_height=0
    local line_width = 0
    for i=1, #layout.line do
        local w, h = width, height
        _,max_line_height = layout.line[i]:fit(w,h)
        base.draw_widget(wibox, cr, layout.line[i], x, y, w, max_line_height)
        y = y +  max_line_height
    end
end

local function widget_changed(layout, old_w, new_w)
    if old_w then
        old_w:disconnect_signal("widget::updated", layout._emit_updated)
    end
    if new_w then
        widget_base.check_widget(new_w)
        new_w:connect_signal("widget::updated", layout._emit_updated)
    end
    layout._emit_updated()
end

function add_line(layout, widget)
    if layout.line == nil or #layout.line == 0 then
        layout.line = {}
        widget_changed(layout, layout.line[1], widget)
        table.insert(layout.line, 1, widget)
    else
        local nb_lines=#layout.line
        widget_changed(layout, layout.line[nb_lines + 1], widget)
        table.insert(layout.line, nb_lines+1, widget)
    end
end
function reset(layout)
    layout.line = nil
    layout:emit_signal("widget::updated")
end

local function get_layout(dir)
    local function draw_dir(layout, wibox, cr, width, height)
        draw(dir, layout, wibox, cr, width, height)
    end

    local ret = widget_base.make_widget()
    ret.draw = draw_dir
    ret.fit = function(box, ...) return ... end
    ret.get_dir = function () return dir end
    ret._emit_updated = function()
        ret:emit_signal("widget::updated")
    end

    for k, v in pairs(_M) do
        if type(v) == "function" then
            ret[k] = v
        end
    end

    return ret
end

function stack()
    local ret = get_layout("x")
    return ret
end

