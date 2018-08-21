--
--Settings window for quikHV.lua
--
--Written by kenromka in Lua, 2018

--include requirements
package.path = package.path..";"..getWorkingFolder().."\\modules\\common\\".."?.lua"
package.path = package.path..";"..getWorkingFolder().."\\modules\\quikHV\\".."?.lua"
local helps = require "helps"
local window = require "window"


--`setting_window` definition
local setting_window = {
	classCode = "",
	className = "",
	secCode = "",
	secName = "",
	Delta = 0.01,
	Color = "Purple",
	colors = {128, 0, 128},
	Gmt = "+3",
	Submit = false
}
setting_window.__index = setting_window


--private function to get lists of class names and codes
local function get_class()
	local class_info = helps:get_classes_info()
	
	-- get list of classes' names
	class_names = {}
	class_codes = {}
	for key, value in pairs(class_info) do
		table.insert(class_names, class_info[key].name)
		table.insert(class_codes, class_info[key].code)
	end
end

--private function to get lists of secuirities names and codes
local function get_sec()
	sec_names = {}
	sec_codes = {}
	local buf = {}
		
	for i = 0, getNumberOf("securities")-1 do
		table.insert(buf, getItem("securities", i).code)
	end
		
	buf = helps:del_dupl(buf)
		
	for _, value in pairs(buf) do
		local x = getSecurityInfo("", value)
		if x ~= nil then
			table.insert(sec_names, x.short_name)
			table.insert(sec_codes, x.code)
		end
	end
end


get_class()
	
get_sec()

--private function to clean 5-7 rows from data
local function clean_table()
	sett_window:update_row({""}, 7, RGB(253, 216, 22))
	sett_window:update_row({""}, 6, RGB(253, 216, 22))
	sett_window:update_row({""}, 5, RGB(253, 216, 22))
end


--private function to set apprporiate color
local function coloring(row)
	--red
	SetCell(sett_window.t_id, row, 1, "Red")
	SetColor(sett_window.t_id, row, 1, RGB(255, 57, 57), RGB(0,0,0), RGB(255, 97, 57), RGB(0,0,0))
	
	--green
	SetCell(sett_window.t_id, row, 2, "Green")
	SetColor(sett_window.t_id, row, 2, RGB(97, 255, 57), RGB(0,0,0), RGB(97, 255, 57), RGB(0,0,0))
	
	--blue
	SetCell(sett_window.t_id, row, 3, "Blue")
	SetColor(sett_window.t_id, row, 3, RGB(57, 57, 255), RGB(0,0,0), RGB(57, 57, 255), RGB(0,0,0))
	
	--cyan
	SetCell(sett_window.t_id, row, 4, "Cyan")
	SetColor(sett_window.t_id, row, 4, RGB(0,255,255), RGB(0,0,0), RGB(0,255,255), RGB(0,0,0))
	
	--purple
	SetCell(sett_window.t_id, row, 5, "Purple")
	SetColor(sett_window.t_id, row, 5, RGB(128,0,128), RGB(0,0,0), RGB(128,0,128), RGB(0,0,0))
	
	--silver
	SetCell(sett_window.t_id, row, 6, "Silver")
	SetColor(sett_window.t_id, row, 6, RGB(192,192,192), RGB(0,0,0), RGB(192,192,192), RGB(0,0,0))
	
	--olive
	SetCell(sett_window.t_id, row, 7, "Olive")
	SetColor(sett_window.t_id, row, 7, RGB(128,128,0), RGB(0,0,0), RGB(128,128,0), RGB(0,0,0))
	
	
end


--private function to convert color to table[3]
local function set_color()
	if setting_window.Color == "Red" then 
		setting_window.colors = {255, 57, 57}
	elseif setting_window.Color == "Green" then 
		setting_window.colors =  {97, 255, 57}
	elseif setting_window.Color == "Blue" then 
		setting_window.colors =  {57, 57, 255}
	elseif setting_window.Color == "Cyan" then 
		setting_window.colors =  {0,255,255}
	elseif setting_window.Color == "Purple" then 
		setting_window.colors =  {128,0,128}
	elseif setting_window.Color == "Silver" then 
		setting_window.colors = {192,192,192}
	else 
		setting_window.colors = {128,128,0}
	end
end


--private function to update data in 5-7 rows
local function update_suggstns()
	if lastSelectedCol == 1 or lastSelectedCol == 2 then
		clean_table()
		sett_window:update_row(class_names, 7, RGB(253, 216, 22))
		sett_window:update_row(class_codes, 5, RGB(253, 216, 22))
	elseif lastSelectedCol == 3 or lastSelectedCol == 4 then
		clean_table()
		sett_window:update_row(sec_names, 7, RGB(253, 216, 22))
		sett_window:update_row(sec_codes, 5, RGB(253, 216, 22))
	elseif lastSelectedCol == 5 then
		clean_table()
	elseif lastSelectedCol == 6 then
		clean_table()
		coloring(7)
	end
end

--private function to generate some suggestions for user's entry
local function similar(str)
	if lastSelectedCol == 1 then
		class_codes, class_names = helps:similar_in_list(class_codes, class_names, str)
	elseif lastSelectedCol == 3 then
		sec_codes, sec_names = helps:similar_in_list(sec_codes, sec_names, str)
	end
	clean_table()
	update_suggstns()
end


--callback function for actions with `setting_window` table
local table_callback = function(t_id,  msg,  par1, par2)

	if msg == QTABLE_VKEY then
		if par1 == 2 then
			if not (lastSelectedCol == 2 or lastSelectedCol == 4) then
				if (par2 >= 65 and par2 <= 90 or par2 >= 48 and par2 <= 57 or par2 == 46) then   
					local let = GetCell(t_id,lastSelectedRow,lastSelectedCol)
					local res = let.image..string.char(par2)
					SetCell(t_id, lastSelectedRow, lastSelectedCol, tostring(res))
					
					if lastSelectedCol == 1 or lastSelectedCol == 3 then similar(res) end
            
				elseif par2 == 8 then
					local let = GetCell(t_id,lastSelectedRow, lastSelectedCol)
					local res = let.image:sub(1, let.image:len()-1)
					SetCell(t_id, lastSelectedRow, lastSelectedCol, tostring(res))
					
					if lastSelectedCol == 1 then
						get_class()
					elseif lastSelectedCol == 3 then
						get_sec()
					end
					if lastSelectedCol == 1 or lastSelectedCol == 3 then similar(res) end
				elseif par2 == 110 or par2 == 190 or par2 == 188 then
					if lastSelectedCol == 5 then
						local let = GetCell(t_id,lastSelectedRow,lastSelectedCol)
						SetCell(t_id, lastSelectedRow, lastSelectedCol, let.image..".")
					end
				elseif par2 == 189 then
					if lastSelectedCol == 7 then
						local let = GetCell(t_id,lastSelectedRow,lastSelectedCol)
						SetCell(t_id, lastSelectedRow, lastSelectedCol, let.image.."-")
					end
				end
				
			end
			if lastSelectedCol == 5 then
				Delta = GetCell(t_id, lastSelectedRow, lastSelectedCol).image
			elseif lastSelectedCol == 7 then
				Gmt = GetCell(t_id, lastSelectedRow, lastSelectedCol).image
			end
		end
	end
	
	if msg == QTABLE_LBUTTONDOWN  then
  
		if par1 == 2 then
			sett_window:highlight_cell(lastSelectedRow, lastSelectedCol, par1, par2)     

			lastSelectedCol = par2
			lastSelectedRow = par1

			update_suggstns()
		
		elseif par1 == 5 then
			if (lastSelectedCol == 1 or lastSelectedCol == 2) and par2 > 0 then 
				local c = GetCell(t_id, 5, par2).image
				if c ~= "" then
					classCode = c
					className = GetCell(t_id, 7, par2).image
				end
				sleep(20)
				clean_table()
				SetCell(t_id, 2, 1, classCode)
				SetCell(t_id, 2, 2, className)
			elseif (lastSelectedCol == 3 or lastSelectedCol == 4) and par2 > 0 then
				local c = GetCell(t_id, 5, par2).image
				if c ~= "" then
					secCode = c
					secName = GetCell(t_id, 7, par2).image
				end
				sleep(20)
				clean_table()
				SetCell(t_id, 2, 3, secCode)
				SetCell(t_id, 2, 4, secName)
			end
		elseif par1 == 7 then 
			if lastSelectedCol == 6 and par2 > 0 then
				local c = GetCell(t_id, 7, par2).image
				Color = c
				SetCell(t_id, 2, 6, Color)
			end
		end
	end
	
	if msg==QTABLE_LBUTTONDBLCLK then
		if par1 == 10 and par2 == 4 then
			setting_window.classCode = classCode
			setting_window.className = className
			setting_window.secCode = secCode
			setting_window.secName = secName
			if Delta ~= nil then
				setting_window.Delta = Delta
			end
			if Color ~= nil then
				setting_window.Color = Color
			end
			if Gmt ~= nil then
				setting_window.Gmt = Gmt
			end
			set_color()
			setting_window.Submit = true
			helps:delete_files_from_dir(getWorkingFolder()..'\\modules\\data\\')
			message("Settings saved", 1)
		end		
	end
	
	if msg==QTABLE_CLOSE  then
		sett_window:Close()
	end
end

--construct the window
function setting_window:window_construct()
	
	local butt_col = 4
	sett_window = {}
	setmetatable(sett_window, window)
	sett_window:init("Settings", {"Class_code", "Class_name", "Sec_code", "Sec_name", "Delta", "Color", "GMT"})
	
	sett_window:add_row({""}, RGB(184, 250, 255))
	sett_window:add_row({self.classCode, self.className, self.secCode, self.secName, self.Delta, self.Color, self.Gmt}, RGB(154, 250, 255))
	sett_window:add_row({""}, RGB(184, 250, 255))
	
	sett_window:add_row({""}, RGB(253, 216, 22))
	for i = 1, 5 do
		sett_window:add_row({""}, RGB(253, 216, 22))
	end
	sett_window:add_button("SAVE", butt_col, {RGB(40, 82, 159), RGB(255, 255, 194)})
	
	SetTableNotificationCallback (sett_window.t_id, table_callback) 
end

--destruct the window
function setting_window:destruct()
	sett_window:Close()
end

return setting_window