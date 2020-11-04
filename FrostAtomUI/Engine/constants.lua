local engine = select(2,...)

local POWER_COLOR_MULTIPLIER = 2
local CLASS_COLOR_MULTIPLIER = 1.2

local next = next
local math = math


local function HEX(t)
	local result = {}
	local rgb
	for k,v in next,t do
		rgb = t[k]
		result[k] = ("|cff%02x%02x%02x"):format(rgb[1]*255,rgb[2]*255,rgb[3]*255)
	end

	return result
end

local CLASS_COLORS,CLASS_COLORS_HEX = {}
for k,v in next,RAID_CLASS_COLORS do
	CLASS_COLORS[k] = {math.min(v.r*CLASS_COLOR_MULTIPLIER,1),math.min(v.g*CLASS_COLOR_MULTIPLIER,1),math.min(v.b*CLASS_COLOR_MULTIPLIER,1)}
end
CLASS_COLORS_HEX = HEX(CLASS_COLORS)


local POWER_COLORS,POWER_COLORS_HEX = {}
for k,v in next,PowerBarColor do
	POWER_COLORS[k] = {v.r*POWER_COLOR_MULTIPLIER,v.g*POWER_COLOR_MULTIPLIER,v.b*POWER_COLOR_MULTIPLIER}
end
POWER_COLORS_HEX = HEX(POWER_COLORS)



engine.CLASS_COLORS = CLASS_COLORS
engine.POWER_COLORS = POWER_COLORS
engine.CLASS_COLORS_HEX = CLASS_COLORS_HEX
engine.POWER_COLORS_HEX = POWER_COLORS_HEX
engine.STATUSBAR_TEXTURE = "Interface\\TargetingFrame\\UI-StatusBar"
engine.HEALTHBAR_COLORS = {	1,0,0, 1,1,0, 0,1,0 }