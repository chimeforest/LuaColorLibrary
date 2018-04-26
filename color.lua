--[[
  This is the color class.
  It handles colors and color manipulation.
--]]

Color = {}
Color.X11 = {}		--TODO should I divide them up like this?	Can I put these into seperate files?
Color.Munsell = {}

---- Functions
--rounds an integer up if it is >= .5 otherwise rounds down.
function Color.round(num)
	local rnd

	if num-math.floor(num) >=.5 then
		rnd = math.ceil(num)
	else
		rnd = math.floor(num)
	end

	return rnd	
end

--checks if a number is Not a Number
function Color.isNaN(value)
  return value ~= value
end

--returns all keys in a table, whose value is of a certian type
function Color.getAllKeysOfType(tbl, tbltype)
  local keyset = {}
  for k in pairs(tbl) do
    if type(tbl[k]) == 'table' then
      table.insert(keyset, k)
      --print (type(tbl[k]) .. ":" .. k)
    end
  end
  return keyset
end

-- Adds a color from a hex value
function Color.add(colorName, hexCode)
  Color[colorName] = Color.hex2rgb(hexCode)
end

-- Adds a color from a hex value to a lib
function Color.add2Lib(colorName, hexCode, libname)
	if libname == nil or type(Color[libname]) ~= 'table' or Color[libname] == nil then	--if libname is empty or Color[libname] is not a table or is nil, add color to base class.. for now
  		Color[colorName] = Color.hex2rgb(hexCode)
  		print("error")
  	else
  		Color[libname][colorName] = Color.hex2rgb(hexCode)
  		print("we good")
  	end
end

-- Converts a hex code to RGB
function Color.hex2rgb(hexCode)
  local nc = {}
	nc[1] = tonumber(string.sub(hexCode,1,2),16)
	nc[2] = tonumber(string.sub(hexCode,3,4),16)
	nc[3] = tonumber(string.sub(hexCode,5,6),16)
	nc[4] = tonumber(string.sub(hexCode,7,8),16)
	if nc[4] == nil then nc[4] = 255 end
	return nc
end

function Color.adjust(c, h, s, v, a)
	hsvColor = Color.rgb2hsv(c)

	hsvColor[1] = hsvColor[1] + h
	if hsvColor[1] > 360 then hsvColor[1] = hsvColor[1] - 360 end
	if hsvColor[1] < 0 then hsvColor[1] = hsvColor[1] + 360 end

	hsvColor[2] = hsvColor[2] * s
	hsvColor[3] = hsvColor[3] * v
	hsvColor[4] = hsvColor[4] * a

	return Color.hsv2rgb(hsvColor)
end

-- Converts from RGB to HVS
function Color.rgb2hsv(rgb)
  local hsv = {}

	--normalize the rgb values between 0 and 1
	local red = rgb[1]/255
	local green = rgb[2]/255
	local blue = rgb[3]/255
	local alpha = rgb[4]/255

	local minValue = math.min(red,math.min(green,blue))
	local maxValue = math.max(red,math.max(green,blue))
	local delta = maxValue - minValue

	local h
	local s
	local v = maxValue

	--calculate the hue, degrees between 0 and 360
	if red > green and red > blue then
		if green >= blue then
			if delta == 0 then
				h=0
			else
				h = 60*(green-blue)/delta
			end
		else
			h = 60 * (green-blue)/delta + 360
		end
	elseif green > blue then
		h = 60 * (blue-red)/delta+120
	else  -- blue is max
		h = 60 * (red-green)/delta+240
	end

  --if h is nan (aka, a pure black, white or grey) set it to 0
  if Color.isNaN(h) then h = 0 end

	--calculate saturation (between 0 and 1)
	if maxValue == 0 then
		s = 0
	else
		s = 1 - (minValue/maxValue)
	end
  
	--scale saturation to a value between 0 and 11
	s = s * 100
	v = v * 100
	alpha = alpha * 100

	if round then
		h = math.ceil(h)
		s = math.ceil(s)
		v = math.ceil(v)
		alpha = math.ceil(alpha)
	end
  
	hsv[1] = h
	hsv[2] = s
	hsv[3] = v
	hsv[4] = alpha

	--print(hsv[1] .. " " .. hsv[2] .. " " .. hsv[3] .. " " .. hsv[4])

	return hsv
end

-- Converts from HVS to RGB
function Color.hsv2rgb(hsv, round)
  local rgb = {}

	local hue = hsv[1]
	local sat = hsv[2]/100
	local val = hsv[3]/100
	local alpha = hsv[4]/100

	local r
	local g
	local b
  
	if sat == 0 then
		r,g,b = val, val, val
	else
		local sectorPos = hue/60
		local sectorNum = math.floor(sectorPos)

		local fractionalSector = sectorPos - sectorNum

		local p = val * (1 - sat)
		local q = val * (1 - (sat * fractionalSector))
		local t = val * (1 - (sat * (1 - fractionalSector)))

		--print(sectorNum)
		if sectorNum == 0 or sectorNum == 6 then
			r = val
			g = t
			b = p
		elseif sectorNum == 1 then
			r = q
			g = val
			b = p
		elseif sectorNum == 2 then
			r = p
			g = val
			b = t
		elseif sectorNum == 3 then
			r = p
			g = q
			b = val
		elseif sectorNum == 4 then
			r = t
			g = p
			b = val
		elseif sectorNum == 5 then
			r = val
			g = p
			b = q
		end
	end
	rgb[1] = Color.round(r*255)
	rgb[2] = Color.round(g*255)
	rgb[3] = Color.round(b*255)
	rgb[4] = Color.round(alpha*255)

	--print(rgb[1] .. " " .. rgb[2] .. " " .. rgb[3] .. " " .. rgb[4])

	return rgb
end

--blends 2 colors, in a ratio, default ratio is 1:1
function Color.blend(color1, color2, r1, r2)
  local newColor = {}
  
  --set ratios if empty or less than 1
  if r1 == nil or r1 < 0 then
    r1 = 1
  end
  if r2 == nil or r2 < 0 then
    r2 = 1
  end
  
  for i =1,4 do
    newColor[i] = Color.round(math.sqrt((math.pow(color1[i],2) * r1 + math.pow(color2[i],2) * r2)/(r1+r2)))
  end

  return newColor
end

--recolors an image so that lighter values are one color, dark values are another, and in between is mixed proportionally
function Color.crossfadeOnVal(imageFile, lightColor, darkColor)
  
end


----Colors
--subtractive primary colors (pastel)
Color['magenta'] = {255,128,255,255}
Color['yellow'] = {255,255,128,255}
Color['cyan'] = {128,255,255,255}

--additive primary colors (pastel)
Color['red'] = {255,128,128,255}
Color['green'] = {128,255,128,255}
Color['blue'] = {128,128,255,255}

--additive secondary colors (pastel)
Color['orange'] = {255,192,128,255}
Color['purple'] = {192,128,255,255}

--greys
Color['white'] = {255,255,255,255}
Color['grey'] = {224,224,224,255}
Color['grey2'] = {192,192,192,255}
Color['grey3'] = {160,160,160,255}
Color['grey4'] = {128,128,128,255}
Color['grey5'] = {96,96,96,255}
Color['grey6'] = {64,64,64,255}
Color['grey7'] = {32,32,32,255}
Color['black'] = {0,0,0,255}

--X11

----Pinks
Color.add("Pink","ffc0cb")
Color.add("LightPink","ffb6c1")
Color.add("HotPink","ff69b4")
Color.add("DeepPink","ff1493")
Color.add("PaleVioletRed","db7093")
Color.add("MediumVioletRed","c71585")

----Reds
Color.add("LightSalmon","ffa07a")
Color.add("Salmon","fa8072")
Color.add("DarkSalmon","e9967a")
Color.add("LightCoral","f08080")
Color.add("IndianRed","cd5c5c")
Color.add("Crimson","dc143c")
Color.add("FireBrick","b22222")
Color.add("DarkRed","8b0000")
Color.add("Red","ff0000")

--Oranges
Color.add("OrangeRed","ff4500")
Color.add("Tomato","ff6347")
Color.add("Coral","ff7f50")
Color.add("DarkOrange","ff8c00")
Color.add("Orange","ffa500")

--Yellows
Color.add("Yellow","ffff00")
Color.add("LightYellow","ffffe0")
Color.add("LemonChiffon","fffacd")
Color.add("LightGoldenrodYellow","fafad2")
Color.add("PapayaWhip","ffefd5")
Color.add("Moccasin","ffe4b5")
Color.add("PeachPuff","ffdab9")
Color.add("PaleGoldenrod","eee8aa")
Color.add("Khaki","f0e68c")
Color.add("DarkKhaki","bdb76b")
Color.add("Gold","ffd700")

--Browns
Color.add("Cornsilk","fff8dc")
Color.add("BlanchedAlmond","ffebcd")
Color.add("Bisque","ffe4c4")
Color.add("NavajoWhite","ffdead")
Color.add("Wheat","f5deb3")
Color.add("BurlyWood","deb887")
Color.add("Tan","d2b48c")
Color.add("RosyBrown","bc8f8f")
Color.add("SandyBrown","f4a460")
Color.add("Goldenrod","daa520")
Color.add("DarkGoldenrod","b8860b")
Color.add("Peru","cd853f")
Color.add("Chocolate","d2691e")
Color.add("SaddleBrown","8b4513")
Color.add("Sienna","a0522d")
Color.add("Brown","a52a2a")
Color.add("Maroon","800000")

--Greens
Color.add("DarkOliveGreen","556b2f")
Color.add("Olive","808000")
Color.add("OliveDrab","6b8e23")
Color.add("YellowGreen","9acd32")
Color.add("LimeGreen","32cd32")
Color.add("Lime","00ff00")
Color.add("LawnGreen","7cfc00")
Color.add("Chartreuse","7fff00")
Color.add("GreenYellow","adff2f")
Color.add("SpringGreen","00ff7f")
Color.add("MediumSpringGreen","00fa9a")
Color.add("LightGreen","90ee90")
Color.add("PaleGreen","98fb98")
Color.add("DarkSeaGreen","8fbc8f")
Color.add("MediumSeaGreen","3cb371")
Color.add("SeaGreen","2e8b57")
Color.add("ForestGreen","228b22")
Color.add("Green","008000")
Color.add("DarkGreen","006400")

----Cyans
Color.add("MediumAquamarine","66CDAA")
Color.add("Cyan","00FFFF")
Color.add("LightCyan","E0FFFF")
Color.add("PaleTurqouise","AFEEEE")
Color.add("Aquamarine","7FFFD4")
Color.add("Turquoise","40E0D0	")
Color.add("MediumTurquoise","48D1CC")
Color.add("DarkTurquoise","00CED1")
Color.add("LightSeaGreen","20B2AA")
Color.add("CadetBlue","5F9EA0")
Color.add("DarkCyan","008B8B")
Color.add("Teal","008080")

----Blues
Color.add("LightSteelBlue","B0C4DE")
Color.add("PowderBlue","B0E0E6")
Color.add("LightBlue","ADD8E6")
Color.add("SkyBlue","87CEEB")
Color.add("LightSkyBlue","87CEFA")
Color.add("DeepSkyBlue","00BFFF")
Color.add("DodgerBlue","1E90FF")
Color.add("CornflowerBlue","6495ED")
Color.add("SteelBlue","4682B4")
Color.add("RoyalBlue","4169E1")
Color.add("Blue","0000FF")
Color.add("MediumBlue","0000CD")
Color.add("DarkBlue","00008B")
Color.add("Navy","000080")
Color.add("MidnightBlue","191970")

----Purples
Color.add("Lavender","E6E6FA")
Color.add("Thistle","D8BFD8")
Color.add("Plum","DDA0DD")
Color.add("Violet","EE82EE")
Color.add("Orchid","DA70D6")
Color.add("Fuchsia","FF00FF")
Color.add("Magenta","FF00FF")
Color.add("MediumOrchid","BA55D3")
Color.add("MediumPurple","9370DB")
Color.add("BlueViolet","8A2BE2")
Color.add("DarkViolet","9400D3")
Color.add("DarkOrchid","9932CC")
Color.add("DarkMagenta","8B008B")
Color.add("Purple","800080")
Color.add("Indigo","4B0082")
Color.add("DarkSlateBlue","483D8B")
Color.add("RebeccaPurple","663399")
Color.add("SlateBlue","6A5ACD")
Color.add("MediumSlateBlue","7B68EE")

----Whites
Color.add("White","ffffff")
Color.add("Snow","FFFAFA")
Color.add("Honeydew","F0FFF0")
Color.add("MintCream","F5FFFA")
Color.add("Azure","F0FFFF")
Color.add("AliceBlue","F0F8FF")
Color.add("GhostWhite","F8F8FF")
Color.add("WhiteSmoke","F5F5F5")
Color.add("Seashell","FFF5EE")
Color.add("Beige","F5F5DC")
Color.add("OldLace","FDF5E6")
Color.add("FloralWhite","FFFAF0")
Color.add("Ivory","FFFFF0")
Color.add("AntiqueWhite","FAEBD7")
Color.add("Linen","FAF0E6")
Color.add("LavenderBlush","FFF0F5")
Color.add("MistyRose","FFE4E1")

----Greys
Color.add("Gainsboro","DCDCDC")
Color.add("LightGrey","D3D3D3")
Color.add("Silver","C0C0C0")
Color.add("DarkGray","A9A9A9")
Color.add("Gray","808080")
Color.add("DimGray","696969")
Color.add("LightSlateGray","778899")
Color.add("SlateGray","708090")
Color.add("DarkSlateGray","2F4F4F")
Color.add("Black","000000")

--Munsell 
--color codes from: http://www.andrewwerth.com/aboutmunsell/

----N
Color.add("N10","ffffff")
Color.add("N9","e9e8e7")
Color.add("N8","cacaca")
Color.add("N7","c0aba9")
Color.add("N6","a3a2a2")
Color.add("N5","888987")
Color.add("N4","6b6c6b")
Color.add("N3","525251")
Color.add("N2","3b3a3a")
Color.add("N1","222221")
Color.add("N0","000000")

----5R
Color.add("R5 9/2","f4e2df")
Color.add("R5 9/4","ffdad5")
Color.add("R5 9/6","ffd3cb")

Color.add("R5 8/2","d8c6c4")
Color.add("R5 8/4","edc0bb")
Color.add("R5 8/6","feb9b3")
Color.add("R5 8/8","ffb1aa")
Color.add("R5 8/10","ffa9a1")

return Color