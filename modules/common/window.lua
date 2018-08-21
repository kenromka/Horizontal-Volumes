--
--Definition of `window` object
--
--Written by kenromka in Lua, 2018
--

local window = {}
window.__index = window

function window:init(table_name, cols, width)
	-- default width value
	width = width or 15
	
	-- allocating table with t_id identificator
	self.t_id = AllocTable()
	
	-- add columns to table
	for key, value in pairs(cols) do
		AddColumn (self.t_id, key, value, true, QTABLE_STRING_TYPE, width)
	end
	
	CreateWindow(self.t_id)
	
	SetWindowCaption(self.t_id, table_name)
	
	InsertRow(self.t_id, 0)
end


--add row with `col_names` in columns, coloured with `color` to the current QTable
function window:add_row(col_names, color)
	rows, cols = GetTableSize(self.t_id), self.t_id
	
	InsertRow(self.t_id, rows)
	
	for key, value in pairs(col_names) do
		SetCell(self.t_id, rows, key, tostring(value))
	end
	
	SetColor(self.t_id, rows, QTABLE_NO_INDEX, color, QTABLE_NO_INDEX, QTABLE_NO_INDEX, QTABLE_NO_INDEX)
end

function window:update_row(col_names, row, color)
	for i = 1, 7 do
		SetColor(self.t_id, row, i, color, RGB(0,0,0), color, RGB(0,0,0))
		SetCell(self.t_id, row, i, "")
	end
	for key, value in pairs(col_names) do
		SetCell(self.t_id, row, key, tostring(value))
	end
end

--delete rows from `startpoint` till the end of QTable
function window:delete_rows(startpoint)
	rows, _ = GetTableSize(self.t_id)
	for i = rows, startpoint, -1 do 
		DeleteRow(self.t_id, i)
	end
	return true	
end

--add button `name` to the next row and `column` selected
function window:add_button(name, column, color)
	rows, cols = GetTableSize(self.t_id)
	InsertRow(self.t_id, rows)
	SetCell(self.t_id, rows, column, tostring(name))
	SetColor(self.t_id, rows, column, color[1], color[2], QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR)
end

--highlights current cell
function window:highlight_cell(row1, col1, row2, col2)
	SetColor(sett_window.t_id, row1, col1, QTABLE_DEFAULT_COLOR,QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR,QTABLE_DEFAULT_COLOR)
	SetColor(sett_window.t_id, row2, col2, RGB(100,250,100),QTABLE_DEFAULT_COLOR, QTABLE_DEFAULT_COLOR,QTABLE_DEFAULT_COLOR)
end

--return value in next column `value` was chosen
function window:get_value(value)
	local val = 0
	rows, cols = GetTableSize(self.t_id)
	for i = 1, cols do
		for j = 1, rows do
			local x = GetCell(self.t_id, j, i)
			if x ~= nil then
				if x.image == value then
					val = GetCell(self.t_id, j, i + 1)
					if val ~= nil then 
						val = val.image
						return val
					else 
						return 0
					end
				end
			end
		end
	end
	if val == nil or val == "" then
		val = 0
	end
	return val
end

function window:set_value(cell, value)
	local rows, cols = GetTableSize(self.t_id)
	local i = 1
	local j = 1
	for j = 1, rows do
		local x = GetCell(self.t_id, j, i)
		if x ~= nil and x.image == cell then
			SetCell(self.t_id, j, i + 1, value)
		end
	end
end

--add row between existings cells
function window:add_row_inline(cell, value)
	local rows, cols = GetTableSize(self.t_id)
	local i = 0
	for j = 1, rows do
		i = j
		local x = GetCell(self.t_id, j, 1)
		if x ~= nil then
			if x.image ~= nil then
				if tonumber(x.image) ~= nil and tonumber(x.image) < tonumber(value) then
					InsertRow(self.t_id, j)
					for key, val in pairs(cell) do
					SetCell(self.t_id, j, key, tostring(val))
					end
					do return end
				end
			end
		end
	end 
	i = i + 1
	InsertRow(self.t_id, i)
	for key, val in pairs(cell) do
		SetCell(self.t_id, i, key, tostring(val))
	end
end

--check existence of `value` in table
function window:existence(value)
	local rows, cols = GetTableSize(self.t_id)
	for i = 1, cols do 
		for j = 1, rows do
			local x = GetCell(self.t_id, j, i)
			if x ~= nil then
				if x.image == value then
					return true
				end
			end
		end
	end
	return false
end

--destroy the QTable
function window:Close()
	DestroyTable(self.t_id)
end

return window