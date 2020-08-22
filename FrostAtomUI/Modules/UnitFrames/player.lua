local engine = select(2,...)
local unitframes = engine:module("unitframes")


local NOCOMBAT_ALPHA = 1/3
local UnitAffectingCombat = UnitAffectingCombat


local function frame_OnUpdate(self,elapsed)
	local curAlpha,newAlpha = self:GetAlpha()
	if UnitAffectingCombat(self.unit) or self:IsMouseOver() then
		newAlpha = curAlpha + elapsed*2
		if newAlpha > 1 then
			self:SetAlpha(1)
			self:SetScript("OnUpdate",nil)
		else
			self:SetAlpha(newAlpha)
		end
	else
		newAlpha = curAlpha - elapsed
		if newAlpha < NOCOMBAT_ALPHA then
			self:SetAlpha(NOCOMBAT_ALPHA)
			self:SetScript("OnUpdate",nil)
		else
			self:SetAlpha(newAlpha)
		end
	end
end

local function UpdateVisibility(self)
	self:SetScript("OnUpdate",frame_OnUpdate)
end

local function PLAYER_ENTERING_WORLD(self)
	self:SetAlpha(UnitAffectingCombat(self.unit) and 1 or NOCOMBAT_ALPHA)
end


function unitframes:CreatePlayerFrame(width,height)
	local frame = self:CreateBase("player")
	frame:RegisterEvent("PLAYER_REGEN_DISABLED",UpdateVisibility)
	frame:RegisterEvent("PLAYER_REGEN_ENABLED",UpdateVisibility)
	frame:SetScript("OnEnter",UpdateVisibility)
	frame:SetScript("OnLeave",UpdateVisibility)
	frame:RegisterEvent("PLAYER_ENTERING_WORLD",PLAYER_ENTERING_WORLD)
	frame:SetSize(width,height)

	local healthbar = self:CreateModule(frame,"healthbar")
	healthbar:SetPoint("TOPRIGHT",-5,-5)
	healthbar:SetPoint("BOTTOMLEFT",frame,"TOPLEFT",5,-5-(height-10)/2)

	local powerbar = self:CreateModule(frame,"powerbar")
	powerbar:SetPoint("BOTTOMRIGHT",-5,5)
	powerbar:SetPoint("TOPLEFT",healthbar,"BOTTOMLEFT")

	local leader = self:CreateModule(frame,"leader")
	leader:SetPoint("TOPLEFT",8,4)

	--local powerbar = self:CreateModule(frame,"powerbar")


	return frame
end