--
--BMP format (WIN V3) files
--
--Written by kenromka in Lua, 2018

--`bmp` definition
local bmp = {}
bmp.__index = bmp

--private function to converting numbers to bytes
local function to_bytes(x, num)
local b = {}
for i = 1, num do
	b[i] = string.char(x%256)
	x = (x - x%256)/256
end
return unpack(b)
end

local function rgb_to_rgba(col)
	return col[1], col[2], col[3], 255
end


--function draw the coloured (`color`) rectangle with (`w`) width and (`h`) height to bitmap file `filename`
function bmp:draw_bitmap(filename, w, h, color)
	local r, g, b, a = rgb_to_rgba(color)
	local bitmap, err = io.open(filename, "w")
	if not bitmap then
		message("Error with graph construct\n"..tostring(err), 3)
		return false
	end
	io.output(bitmap)
	
	--bitmap file header
	local signature = {66, 77} --"BM"
	local fileSize = 14 + 40 + w*h*4
	local reserved = 0
	local offset = 14 + 40

	--BITMAPINFOHEADER
	local headerSize = 40
	local dimensions = {w, h}
	local colorPlanes = 1
	local bpp = 32
	local compression = 0
	local imgSize = w*h*4
	local resolution = {2795, 2795}
	local pltColors = 0
	local impColors = 0
	io.write(to_bytes(signature[1], 1), to_bytes(signature[2], 1))
	io.write(to_bytes(fileSize, 4))
	io.write(to_bytes(reserved, 4))
	io.write(to_bytes(offset, 4))
	io.write(to_bytes(headerSize, 4))
	io.write(to_bytes(dimensions[1], 4))
	io.write(to_bytes(dimensions[2], 4))
	io.write(to_bytes(colorPlanes, 2))
	io.write(to_bytes(bpp, 2))
	io.write(to_bytes(compression, 4))
	io.write(to_bytes(imgSize, 4))
	io.write(to_bytes(resolution[1], 4))
	io.write(to_bytes(resolution[2], 4))
	io.write(to_bytes(pltColors, 4))
	io.write(to_bytes(impColors, 4))

	--pixels info
	for i = 1, dimensions[2] do
		for j = 1, dimensions[1] do
			io.write(to_bytes(r, 1))   --red
			io.write(to_bytes(a, 1))   --alpha
			io.write(to_bytes(b, 1))   --blue
			io.write(to_bytes(g, 1))   --green
		end
	end
	bitmap:close()
	return true
end

return bmp