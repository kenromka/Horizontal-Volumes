--
--Main window for quikHV.lua
--
--Written by kenromka in Lua, 2018

--include requirements
package.path = package.path..";"..getWorkingFolder().."\\modules\\common\\".."?.lua"
package.path = package.path..";"..getWorkingFolder().."\\modules\\quikHV\\".."?.lua"
local helps = require "helps"
local window = require "window"
local setting_window = require "setting_window"

--`main_window` definition
local main_window = {
	is_run = true,
	working = false,
	start = false,
	results = {}
}
main_window.__index = main_window

--private function for switching buttons
local function switch_button(t_id, name, color)
	SetCell(t_id, 1, 1, name)
	SetColor(t_id, 1, 1, color, RGB(0, 0, 0), color, RGB(0, 0, 0))
end


--scan table for data
function main_window:scan_table(sec_code, class_code, qty, pric)
	quantity = tonumber(qty)
	if tostring(sec_code) == tostring(setting_window.secCode) and tostring(class_code) == tostring(setting_window.classCode) then 
		price = tonumber(pric)
		round_price = math.floor(price / tonumber(setting_window.Delta)) * tonumber(setting_window.Delta)			
		if main_wind:existence(tostring(round_price)) == true then
			curr_quantity = main_wind:get_value(tostring(round_price))+quantity
			main_wind:set_value(tostring(round_price), tostring(curr_quantity))
			
			main_window.results[tostring(round_price)] = tostring(curr_quantity)
		elseif main_wind:existence(tostring(round_price)) == false then
			main_wind:add_row_inline({tostring(round_price), tostring(quantity)}, tostring(round_price))
			
			main_window.results[tostring(round_price)] = tostring(quantity)
		end
	end
end


--get data for the first time
function main_window:start_search()
	main_window.results = {}
	for i = 0, getNumberOf("all_trades")-1 do
		local trade = getItem("all_trades", i)
		if trade ~= nil then
			main_window:scan_table(trade.sec_code, trade.class_code, trade.qty, trade.price)
		end
	end
	message("Search finished", 1)
end

--callback function for actions with `main_window` table
local table_callback = function(t_id,  msg,  par1, par2)
	x = GetCell(t_id, par1, par2)
	if x ~= nil then
		if msg == QTABLE_LBUTTONDOWN then
			if x.image == "START" then
				main_wind:delete_rows(2)
				switch_button(t_id, "STOP", RGB(255, 0, 0))
				main_window.working = true
				main_window.start = true
			elseif x.image == "STOP" then
				switch_button(t_id, "START", RGB(0, 255, 0))
				main_window.working = false
			end
		end
	end
	if msg == QTABLE_CLOSE then
		main_window:destruct()
		setting_window:destruct()
		message("Stop", 1)
		main_window.is_run = false
		main_window.start = false
		main_window.working = false
	end
end

--construct the window
function main_window:window_construct()
	main_wind = {}
	setmetatable(main_wind, window)
	main_wind:init("Horizontal Volumes",{'Price','Quantity'})
	main_wind:add_button("START", 1, {RGB(0, 255, 0), RGB(0, 0, 0)})
	SetTableNotificationCallback (main_wind.t_id, table_callback) 
end

--destruct the window
function main_window:destruct()
	main_wind:Close()
	
	helps:delete_files_from_dir(getWorkingFolder()..'\\modules\\data\\')
end

return main_window