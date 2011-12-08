local base = require("wibox.layout.base")
local fixed = require("wibox.layout.fixed")
local widget_base = require("wibox.widget.base")
local table = table
local pairs = pairs
local floor = math.floor
local helpers = require('blingbling.helpers')
---Dispatch widgets horizontaly, positions are not fixed
module("blingbling.wibox.layout.flex")

local function round(x)
    return floor(x + 0.5)
end

--Difference with original:
--if a widget size is > to mean size then some widgets are placed on other with the original flex layout.

--- Draw a flex layout. Each widget gets an equal share of the available space
-- @param dir "x" for a horizontal layout and "y" for vertical.
-- @param widgets The widgets to draw.
-- @param cr The cairo context to use.
-- @param width The available width.
-- @param height The available height.
-- @return The total space needed by the layout.
function draw_flex(widgets_align, widgets, wibox, cr, width, height)
    local pos = 0

    local num = #widgets
    local space_per_item
    space_per_item = width / num
--Check if one widget have a width > space_per_item
    local one_item_has_width_bigger_than_space_per_item = false
    for k, v in pairs(widgets) do
        widget_width,_ = v:fit(width ,height)
        if widget_width > space_per_item then
            one_item_has_width_bigger_than_space_per_item = true
        end
    end
    if one_item_has_width_bigger_than_space_per_item == true then
        local total_width=0
        total_width, _ = fixed.fit_fixed(dir, widgets, width, height)
        local remaining_space = width - total_width
        local separator = remaining_space / (num +1)
        pos=separator
        for k, v in pairs(widgets) do
            local x, y, w, h
            widget_width,widget_height = v:fit(width ,height)
            x, y = round(pos), 0
            w, h = widget_width , height
            base.draw_widget(wibox, cr, v, x, y, w, h)

            pos = pos + widget_width +separator

            if pos >= width then
                break
            end
        end
    elseif one_item_has_width_bigger_than_space_per_item == false then
        if widgets_align == "left" then
            for k, v in pairs(widgets) do
                local x, y, w, h
                widget_width,widget_height = v:fit(width ,height)
                x, y = round(pos), 0
                w, h = widget_width, height
                base.draw_widget(wibox, cr, v, x, y, w, h)

                pos = pos + space_per_item

                if pos >= width then
                    break
                end
            end
        elseif widgets_align == "middle" then
            for k, v in pairs(widgets) do
                local x, y, w, h
                widget_width,widget_height = v:fit(width ,height)
                x, y = pos + (space_per_item/2 - widget_width/2), 0
                w, h = widget_width, height
                base.draw_widget(wibox, cr, v, x, y, w, h)

                pos = pos + space_per_item

                if pos >= width then
                    break
                end
            end
        
        elseif widgets_align == "right" then
            for k, v in pairs(widgets) do
                local x, y, w, h
                widget_width,widget_height = v:fit(width ,height)
                x, y = pos + (space_per_item - widget_width), 0
                w, h = widget_width, height
                base.draw_widget(wibox, cr, v, x, y, w, h)

                pos = pos + space_per_item

                if pos >= width then
                    break
                end
            end

        end
    end
end

local function add(layout, widget)
    widget_base.check_widget(widget)
    table.insert(layout.widgets, widget)
    widget:connect_signal("widget::updated", layout._emit_updated)
    layout._emit_updated()
end

local function reset(layout)
    for k, v in pairs(layout.widgets) do
        v:disconnect_signal("widget::updated", layout._emit_updated)
    end
    layout.widgets = {}
    layout:emit_signal("widget::updated")
end

local function get_layout( widgets_align)
    local function draw(layout, wibox, cr, width, height)
        draw_flex(widgets_align, layout.widgets, wibox, cr, width, height)
    end

    local function fit(layout, width, height)
        return fixed.fit_fixed("x", layout.widgets, width, height)
    end

    local ret = widget_base.make_widget()
    ret.draw = draw
    ret.fit = fit
    ret.add = add
    ret.reset = reset
    ret.widgets = {}
    ret.get_dir = function () return dir end
    ret._emit_updated = function()
        ret:emit_signal("widget::updated")
    end

    return ret
end

--- Returns a new horizontal flex layout. A flex layout shares the available space
-- equally among all widgets and the widgets are left aligned in this space. Widgets can be added via :add(widget).
--Note:if a widget width is greater than the space per widgets defined, then the
-- flex layout use the remaining space and calculate the mean space between each
-- widgets
function horizontal_left()
    return get_layout("left")
end
--- Returns a new horizontal flex layout. A flex layout shares the available space
-- equally among all widgets and the widgets are centered in this space. Widgets can be added via :add(widget).
--Note:if a widget width is greater than the space per widgets defined, then the
-- flex layout use the remaining space and calculate the mean space between each
-- widgets
function horizontal_middle()
    return get_layout("middle")
end
--- Returns a new horizontal flex layout. A flex layout shares the available space
-- equally among all widgets and the widgets are right aligned in this space. Widgets can be added via :add(widget).
--Note:if a widget width is greater than the space per widgets defined, then the
-- flex layout use the remaining space and calculate the mean space between each
-- widgets
function horizontal_right()
    return get_layout("x", "right")
end
