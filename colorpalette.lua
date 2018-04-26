--[[
  This is the color plalette class.
  It handles color palettes
--]]

require "color"

ColorPalette = {}

---- Functions ----
function ColorPalette.getData(t)  --gets the palette date, ralative to the root color
	local tData = {}

	local rootColor = Color.rgb2hsv(t[1])

	for k in pairs(t) do
    if k ~= 1 then
      --print(k)
      local curColor = Color.rgb2hsv(t[k])
      local curData = {}
      --print(curColor[1])
      for ii=1,4,1 do
        if ii== 1 then
          curData[ii] = rootColor[ii] - curColor[ii]
        else
          curData[ii] = curColor[ii]/rootColor[ii]
        end
        --print("tData["..k.."]: " .. curData[ii])
      end
      tData[k] = curData
    end
	end

	tData.sat = rootColor[2]
	tData.val = rootColor[3]

	return tData
end

function ColorPalette.fromThemeData(rootColor,themeData, useOrigSV) --creates a new palette using an old one with a new root color
	local set = {}

	hsvColor = Color.rgb2hsv(rootColor)

	if useOrigSV then
		hsvColor[2] = themeData.sat
		hsvColor[3] = themeData.val
	end
	
	set[1] = Color.hsv2rgb(hsvColor)
  
  for k in pairs(themeData) do
		local curData = themeData[k]
		local curColor = {}

		--print(i)
    if k ~= 'sat' and k ~= 'val' then --don't recolor sat and val, they are not colors
      for ii=1,4,1 do
        if ii == 1 then
          --value must be between 0 and 360
          --print(k .. ":" .. ii)
          --print (hsvColor[ii])
          --print (curData[ii])
          curColor[ii] = hsvColor[ii] + curData[ii]
          --print (curColor[ii])
          if curColor[ii] > 360 then curColor[ii] = curColor[ii] - 360 end
          if curColor[ii] < 0 then curColor[ii] = curColor[ii] + 360 end
        else
          --value must be between 0 and 100
          curColor[ii] = hsvColor[ii] * curData[ii]
          if curColor[ii] > 100 then curColor[ii] = 100 end
          if curColor[ii] < 0 then curColor[ii] = 0 end
        end
      end
		-- on the 12 iteration: Error: colors.lua:154: attempt to perform arithmetic on local 'r' (a nil value)
		-- on 12, it's the first time that curdata[ii] is less than 180...
		--print("curColor: " .. curColor[1] .. "," .. curColor[2] .. "," .. curColor[3] .. "," .. curColor[4])
		set[k] = Color.hsv2rgb(curColor)
    end
	end

	return set
end

function ColorPalette.fromHexTable(hexTable)  --makes a palette from an array of hex values
	set = {}

	for i=1,#hexTable,1 do
		set[i] = Color.hex2rgb(hexTable[i])
	end

	return set
end

--draws the color (pal)ette at x,y with squares of size s
function ColorPalette.draw(pal,x,y,s)
  --record the color before drawing
    local normColor = {}
    normColor[1], normColor[2], normColor[3], normColor[4] = love.graphics.getColor()
    
    --drawboarder
    love.graphics.setColor(Color['white'])
    love.graphics.rectangle('fill', x-1, y-1, s * #pal +2, s/2 + 1)
    love.graphics.setColor(Color['black'])
    love.graphics.rectangle('fill', x-1, y + s/2, s * #pal +2, s/2 + 1)
    --drawcolors
    i=0
  for k in pairs(pal) do
    --set color and draw
    love.graphics.setColor(pal[k])
    love.graphics.rectangle('fill', x + i * s, y, s, s)
    i = i + 1
  end
  
  --restore previous color
  love.graphics.setColor(normColor)
end


---- Palettes ----

--Our Palettes
  --none atm.

--Pallettes from creativecolorschemes.com
--An example of setting a pallette one color at a time.
ColorPalette['earthtone'] = {}
ColorPalette['earthtone'][1] = Color.hex2rgb("493829")
ColorPalette['earthtone'][2] = Color.hex2rgb("816c5b")
ColorPalette['earthtone'][3] = Color.hex2rgb("a9a18c")
ColorPalette['earthtone'][4] = Color.hex2rgb("613318")
ColorPalette['earthtone'][5] = Color.hex2rgb("855723")
ColorPalette['earthtone'][6] = Color.hex2rgb("b99c6b")
ColorPalette['earthtone'][7] = Color.hex2rgb("8f3b1b")
ColorPalette['earthtone'][8] = Color.hex2rgb("d57500")
ColorPalette['earthtone'][9] = Color.hex2rgb("dbca60")
ColorPalette['earthtone'][10] = Color.hex2rgb("404f24")
ColorPalette['earthtone'][11] = Color.hex2rgb("668d3c")
ColorPalette['earthtone'][12] = Color.hex2rgb("bdd09f")
ColorPalette['earthtone'][13] = Color.hex2rgb("4e6172")
ColorPalette['earthtone'][14] = Color.hex2rgb("93929f")
ColorPalette['earthtone'][15] = Color.hex2rgb("a3adb8")

--An example of setting a palette from a table of hex values
ColorPalette['artdeco'] = ColorPalette.fromHexTable({"ef3e5b","f26279","f68fa0",
                                                     "4b265d","6f5495","a09ed6",
                                                     "3f647e","688fad","9fc1d3",
                                                     "00b0b2","52ccce","95d47a",
                                                     "677c8a","b2a296","c9c9c9",})

ColorPalette['beach'] = ColorPalette.fromHexTable({"c0362c","ff8642","f4dcb5",
                                                     "816c5b","c3b7ac","e7e3d7",
                                                     "668d3c","b1dda1","e5f3cf",
                                                     "0097ac","3cd6e6","97eaf4",
                                                     "007996","06c2f4","fad8fa",})

ColorPalette['cool'] = ColorPalette.fromHexTable({"004159","65a8c4","aacee2",
                                                  "8c65d3","9a93ec","cab9f1",
                                                  "0052a5","413bf7","81cbf8",
                                                  "00adce","59dbf1","9ee7fa",
                                                  "00c590","73ebae","b5f9d3",})

ColorPalette['cute'] = ColorPalette.fromHexTable({"8db6c7","c1b38e","d1c6bf",
                                                  "ca9f92","f9cd97","e3d9b0",
                                                  "b1c27a","b1e289","51c0bf",
                                                  "59add0","7095e1","9fa3e3",
                                                  "c993da","db8db2","f1c3d0",})

ColorPalette['elegant'] = ColorPalette.fromHexTable({"502812","603618","855723",
                                                  "892034","7a1a57","6f256c",
                                                  "00344d","003066","57527e",
                                                  "004236","404616","9f9b74",
                                                  "215930","868f98","c3c8cd",})

ColorPalette['gorgeous'] = ColorPalette.fromHexTable({"006884","00909e","89dbec",
                                                  "ed0026","fa9d00","ffd08d",
                                                  "b00051","f68370","feabb9",
                                                  "6e006c","91278f","cf97d7",
                                                  "000000","5b5b5b","d4d4d4",})

ColorPalette['warm'] = ColorPalette.fromHexTable({"973f0d","ac703d","c38e63",
                                                  "e49969","e5ae86","eec5a9",
                                                  "6e7649","9d9754","c7c397",
                                                  "b4a851","dfd27c","e7e3b5",
                                                  "846d74","b7a6ad","d3c9ce",})

---- Palette Recolors ----
--Pallettes from creativecolorschemes.com
--Earthtone
ColorPalette['oceantone'] = ColorPalette.fromThemeData(Color.MediumBlue, ColorPalette.getData(ColorPalette['earthtone']),true)
ColorPalette['foresttone'] = ColorPalette.fromThemeData(Color.ForestGreen, ColorPalette.getData(ColorPalette['earthtone']),true)
ColorPalette['lavatone'] = ColorPalette.fromThemeData(Color.hex2rgb("330000"), ColorPalette.getData(ColorPalette['earthtone']),false)
ColorPalette['firetone'] = ColorPalette.fromThemeData(Color['Maroon'], ColorPalette.getData(ColorPalette['earthtone']),false)

--Warm
ColorPalette['oceanwarm'] = ColorPalette.fromThemeData(Color.MediumBlue, ColorPalette.getData(ColorPalette['warm']),true)


return ColorPalette