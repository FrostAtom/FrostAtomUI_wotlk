local engine = select(2,...)
local unitframes = engine:module("unitframes")

local unpack = unpack
local UnitIsConnected = UnitIsConnected
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local math_shortValue = engine.math.shortValue
local HEALTHBAR_COLORS = engine.HEALTHBAR_COLORS
local ColorGradient = engine.ColorGradient


local function healthbar_update(frame)
	local unit = frame.unit
	local healthbar = frame.healthbar

	local idleReason = (not UnitIsConnected(unit) and "offline") or (UnitIsDead(unit) and "dead") or (UnitIsGhost(unit) and "ghost")
	if idleReason then
		healthbar:SetMinMaxValues(0,1)
		healthbar:SetValue(0)
		healthbar.background:SetVertexColor(0,0,0,0)
		healthbar.text:SetText(idleReason)
	else
		local curHealth,maxHealth = UnitHealth(unit),UnitHealthMax(unit)
		healthbar:SetMinMaxValues(0,maxHealth)
		healthbar:SetValue(curHealth)

		local r,g,b = ColorGradient(curHealth/maxHealth,unpack(HEALTHBAR_COLORS))
		healthbar:SetStatusBarColor(r,g,b)
		healthbar.background:SetVertexColor(r*0.3,g*0.3,b*0.3)
		healthbar.text:SetText(math_shortValue(curHealth))
	end
end

local function healthbar_create(frame)
	local healthbar = CreateFrame("StatusBar",nil,frame)
	healthbar:SetFrameLevel(frame:GetFrameLevel())
	healthbar:SetStatusBarTexture(engine.STATUSBAR_TEXTURE)

	local background = healthbar:CreateTexture(nil,"BORDER")
	background:SetAllPoints()
	background:SetTexture(engine.STATUSBAR_TEXTURE)

	local text = healthbar:CreateFontString(nil,"ARTWORK","SystemFont_Outline_Small")
	text:SetAllPoints()
    text:SetTextColor(1,0.9,0.8)

    do
    	local unit,prevHealth = frame.unit
		healthbar:SetScript("OnUpdate",function()
			local curHealth = UnitHealth(unit)
			if curHealth ~= prevHealth then
				healthbar_update(frame)
				prevHealth = curHealth
			end
		end)
	end

	healthbar.unit = frame.unit
	healthbar.background = background
	healthbar.text = text


	return healthbar
end

unitframes:RegisterModule("healthbar",healthbar_create,healthbar_update)