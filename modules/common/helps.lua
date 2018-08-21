--
--Some helpful functions and class methods added here
--
--Written by kenromka in Lua, 2018
local helps = {}
helps.__index = helps


--private extra method for `string` module
--split string to table
function string:split(str)
	local ta = {}
	for i in string.gmatch(str, "(%P+)") do
		table.insert(ta, i)
	end
	return ta
end

function helps:split(str)
	return string:split(str)
end

--delete duplicate values from table
function helps:del_dupl(ta)
	local res = {}
	local hash = {}
	for _, v in ipairs(ta) do
		if v ~= nil then 
			if not hash[v] then
				res[#res+1] = v
				hash[v] = true
			end
		end
	end
	return res
end


--get table with class info
function helps:get_classes_info()
	-- get list of classes' codes
	local class_codes = helps:split(getClassesList())
	
	-- get table with classes' information
	local class_info = {}
	for i = 1, #class_codes do
		class_info[i] = getClassInfo(class_codes[i])
	end
	return class_info
end

--find elements in table with similar substrings
function helps:similar_in_list(ta1, ta2, str)
	local result1, result2 = {}, {}
	for i = 1, #(ta1) do
		local buf = ta1[i]:lower()
		if buf:find(str:lower()) ~= nil then
			table.insert(result1, ta1[i])
			table.insert(result2, ta2[i])
		end
	end
	return result1, result2
end

--add label `HV` to the graph
function helps:add_label(yvalue, pic, date_p, time_p, hint)
	local params = {
		TEXT = "",
		IMAGE_PATH = pic,
		ALIGNMENT = "LEFT",
		YVALUE = yvalue,
		DATE = date_p,
		TIME = time_p,
		R = 0,
		G = 0,
		B = 0,
		TRANSPARENCY = 30,
		TRANSPARENT_BACKGROUND = 0,
		FONT_FACE_NAME = "Arial",
		FONT_HEIGHT = 12,
		HINT = hint
	}
	label_id = AddLabel("HV", params)
end


--return a-b where `a`, `b` are tables
function helps:table_difference(a, b)
    local ai = {}
    local r = {}
	if a == nil then
		return b
	elseif b == nil then
		return a
	end
    for k,v in pairs(a) do 
		r[k] = v
		ai[v] = true 
	end
    for k,v in pairs(b) do 
        if ai[v] ~= nil then
			r[k] = nil   
		end
    end
    return r
end

--return a+b, where `a`, `b` are tables
function helps:table_concat(tbl1, tbl2)
	for k, v in pairs(tbl2) do
		tbl1[k] = v
	end
	return tbl1
end

--find max element in table
function helps:find_max(tbl)
	local maxj = 0
	for _, value in pairs(tbl) do
		maxj = math.max(maxj, tonumber(value))
	end
	return maxj
end

--delete files from directory `path`
--WORK ON WINDOWS ONLY
function helps:delete_files_from_dir(path)
	os.execute('rd /s/q "'..path..'"')
	os.execute('mkdir "'..path..'"')
end


return helps