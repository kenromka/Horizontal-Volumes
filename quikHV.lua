--
--Horizontal-Volumes for QUIK
--
--Written by kenromka in Lua, 2018



--include requirements
package.path = package.path..";"..getWorkingFolder().."\\modules\\quikHV\\".."?.lua"
local setting_window = require "setting_window"
local main_window = require "main_window"
local helps = require "helps"
local bmp = require "bmp"


is_run = true 

volumes = {}


--function to format time acceptable for adding labels
local function format_time(t)
	local hour = tostring(t.hour+tonumber(setting_window.Gmt))
	if tonumber(hour) < 10 then 
		hour = "0"..hour
	end
	local minute = tostring(math.floor(t.min/5)*5)
	if tonumber(minute) < 10 then
		minute = "0"..minute
	end
	return tonumber(hour..minute.."00")
end


--function redraw graph with new data
local function update_graph(t)
	local time_p = format_time(t)
	local diff = helps:table_difference(main_window.results, volumes)
	local maxi = helps:find_max(main_window.results)
	if diff ~= nil then
		for key, val in pairs(diff) do
			if not bmp:draw_bitmap(getWorkingFolder().."\\modules\\data\\"..key..".bmp", math.floor(tonumber(val)/maxi * 500), 5, setting_window.colors) then
				message("Smthng went wrong", 3)
			end
		end
	end
	volumes = helps:table_concat(volumes, diff)
	DelAllLabels("HV")
	for key, val in pairs(volumes) do
		helps:add_label(tonumber(key), getWorkingFolder().."\\modules\\data\\"..key..".bmp", date_p, time_p, setting_window.secCode.."\nQuantity: "..val.."\nPrice: "..key)
	end
end


--system function: initialization
function OnInit()	
	local buff = os.date("!*t", os.time())

	time_flag = false
	min_flag = 61
	
	local year = tostring(buff.year)
	local month = tostring(buff.month)
	if tonumber(month) < 10 then month = "0"..month end
	local day = tostring(buff.day)
	if tonumber(day) < 10 then day = "0"..day end
	date_p = tonumber(year..month..day)
end

--function search for data and draw graph
function Search()
	main_window:start_search()
	update_graph(os.date("!*t", os.time()))
	message("Graphic is constructed", 1)
end


--system function: catch changes in `alltrades` table
function OnAllTrade(alltrade)
	if main_window.working == false then
		return
	end
	local results = {}
	
	main_window:scan_table(alltrade.sec_code, alltrade.class_code, alltrade.qty, alltrade.price)
end

--system function: exiting
function OnStop()
	main_window:destruct()
	setting_window:destruct()
	is_run = false
	main_window.working = false
end

function main()

	main_window:window_construct()
	
	setting_window:window_construct()
	
	while is_run do
		--check should work or not
		is_run = main_window.is_run
		
		--check search start needed
		if (main_window.start == true) then
			main_window.start = false
			Search()
		end
		
		--clean data if settings were changed
		if setting_window.Submit == true then
			setting_window.Submit = false
			volumes = {}
		end
		
		local t = os.date("!*t", os.time())
		
		--update graph every even and every 5 minute
		if main_window.working == true then
				if time_flag == false then
					time_flag = true
					if t.min % 5 == 0 then volumes = {} end
					min_flag = t.min
					
					update_graph(t)
				elseif min_flag ~= t.min then
					time_flag = false 
				end
		end
		
		--not to overload processor
		sleep(500)
	end
end