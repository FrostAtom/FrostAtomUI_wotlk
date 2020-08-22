local engine = select(2,...)

local math = math

local function toHEX(t)
	local result = {}
	local rgb
	for k,v in next,t do
		rgb = t[k]
		result[k] = ("|cff%02x%02x%02x"):format(rgb[1]*255,rgb[2]*255,rgb[3]*255)
	end

	return result
end

local CLASS_COLORS = {}
for k,v in next,RAID_CLASS_COLORS do
	CLASS_COLORS[k] = {math.min(v.r*1.25,1),math.min(v.g*1.25,1),math.min(v.b*1.25,1)}
end


local POWER_COLORS = {}
do
	for k,v in next,PowerBarColor do
		POWER_COLORS[k] = {v.r*0.66,v.g*0.66,v.b*0.66}
	end
end



engine.CLASS_COLORS = CLASS_COLORS
engine.POWER_COLORS = POWER_COLORS
engine.CLASS_COLORS_HEX = toHEX(CLASS_COLORS)
engine.POWER_COLORS_HEX = toHEX(POWER_COLORS)
engine.STATUSBAR_TEXTURE = "Interface\\Buttons\\WHITE8x8"
engine.HEALTHBAR_COLORS = {	0.8,0.2,0.2, 0.65,0.63,0.35, 0.33,0.59,0.33, }