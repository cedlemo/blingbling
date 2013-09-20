local os = os
local string = string
local awful = require("awful")
local textbox = require("wibox.widget.textbox")

local days_of_week_in_kanji={"日曜日", "月曜日","火曜日","水曜日","木曜日","金曜日","土曜日"}
local days_of_week_in_kana={"にちようび","げつようび","かようび","すいようび","もくようび","きんようび","どようび"}

local kanji_numbers={"一","ニ","三","四","五","六","七","八","九","十"}
local kanas_numbers={"いち","に","さん","し","ご","ろく","しち","はち","く","じゅう"}
local days_of_month_in_kanas={"ついたち","ふつか","みっか","よっか","いつか","むいか","なのか","ようか","ここのか","とおか",
											"ジュウイチニチ","ジュウニニチ","ジュウサンニチ","じゅうよっか", "ジュウゴニチ","ジュウロクニチ","ジュウシチニチ","ジュウハチニチ","ジュウクニチ","はつか",
											"ニジュウイチニチ","ニジュウニニチ","ニジュウサンニチ","にじゅうよっか", "ニジュウゴニチ","ニジュウロクニチ","ニジュウシチニチ","ニジュウハチニチ","ニジュウクニチ","サンジュウニチ","サンジュウイチニチ"
}
--kanas_days_of_month={}

local function get_day_of_month_in_kanji(n)
	if n<=10 then
		return kanji_numbers[n]
	elseif n<20 then
		return kanji_numbers[10]..(kanji_numbers[n-10] or "") .. "日"
	elseif n<30 then
		return kanji_numbers[2]..kanji_numbers[10]..(kanji_numbers[n-20] or "").. "日"
	elseif n<=31 then
		return kanji_numbers[3]..kanji_numbers[10]..(kanji_numbers[n-30] or "").. "日"
	end
end
local function get_month_in_kanji(n)
	if n<=10 then
		return kanji_numbers[n].."月"
	elseif n<=12 then
		return kanji_numbers[10]..(kanji_numbers[n-10] or "").."月"
	end
end
romajis_days_of_month={}
local function get_current_day_of_week_in_kanji()
	return days_of_week_in_kanji[tonumber(os.date("%w") + 1)]
end
local function get_current_day_of_month_in_kanji()
	return get_day_of_month_in_kanji(tonumber(os.date("%d")))
end
local function get_current_month_in_kanji()
	return get_month_in_kanji(tonumber(os.date("%m")))
end
local function get_current_hour()
	return os.date("%H")
end
local function get_current_minutes()
	return os.date("%M")
end
local function get_current_time_in_japanese( string)
	if type(string) ~= "string" then
		return nil
	end
	local result = string 
	result = string.gsub(result,"%%w",get_current_day_of_week_in_kanji())
	result = string.gsub(result,"%%d",get_current_day_of_month_in_kanji())
	result = string.gsub(result,"%%m",get_current_month_in_kanji())
	result = os.date(result)
	return result
end

local function japanese_clock(string)
	local clock = textbox()
	local string = string or "%m、%d、%w、%H時%M分"
	
	clock:set_markup(get_current_time_in_japanese( string ))
	clocktimer = timer({ timeout = 60 })
	clocktimer:connect_signal("timeout", function() clock:set_markup(get_current_time_in_japanese( string )) end)
	clocktimer:start()
	clock_tooltip= awful.tooltip({
		objects = { clock },
		timer_function= function()
			return os.date("%B, %d, %A, %H:%M")
		end,
		})
	return clock
end
return {
	japanese = japanese_clock
}
