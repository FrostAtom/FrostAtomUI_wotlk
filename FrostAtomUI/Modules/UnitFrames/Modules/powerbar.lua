local engine = select(2,...)
local unitframes = engine:module("unitframes")

local unpack = unpack
local UnitIsConnected = UnitIsConnected
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitPower = UnitPower
local UnitPowerMax = UnitPowerMax
local UnitPowerType = UnitPowerType
local math_shortValue = engine.math.shortValue
local POWER_COLORS = engine.POWER_COLORS



local function powerbar_update(frame)
	local unit = frame.unit
	local powerbar = frame.powerbar

	if not UnitIsConnected(unit) or UnitIsDeadOrGhost(unit) then
		powerbar:SetMinMaxValues(0,1)
		powerbar:SetValue(0)
		powerbar.background:SetVertexColor(0,0,0,0)
		powerbar.text:SetText(nil)
	else
		local curPower,maxPower = UnitPower(unit),UnitPowerMax(unit)
		powerbar:SetMinMaxValues(0,maxPower)
		powerbar:SetValue(curPower)

		local r,g,b = unpack(POWER_COLORS[UnitPowerType(unit)])
		powerbar:SetStatusBarColor(r,g,b)
		powerbar.background:SetVertexColor(r*0.3,g*0.3,b*0.3)
		powerbar.text:SetText(math_shortValue(curPower))
	end
end

local function powerbar_create(frame)
	local powerbar = CreateFrame("StatusBar",nil,frame)
	powerbar:SetFrameLevel(frame:GetFrameLevel())
	powerbar:SetStatusBarTexture(engine.STATUSBAR_TEXTURE)

	local background = powerbar:CreateTexture(nil,"BORDER")
	background:SetAllPoints()
	background:SetTexture(engine.STATUSBAR_TEXTURE)

	local text = powerbar:CreateFontString(nil,"OVERLAY","SystemFont_Outline_Small")
	text:SetAllPoints()
    text:SetTextColor(1,0.9,0.8)

    do
    	local unit,prevPower = frame.unit
		powerbar:SetScript("OnUpdate",function()
			local curPower = UnitPower(unit)
			if curPower ~= prevPower then
				prevPower = curPower
				powerbar_update(frame)
			end
		end)
    end

	powerbar.unit = frame.unit
	powerbar.background = background
	powerbar.text = text


	return powerbar
end

unitframes:RegisterModule("powerbar",powerbar_create,powerbar_update)