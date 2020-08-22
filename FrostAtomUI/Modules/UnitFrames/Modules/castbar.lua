local engine = select(2,...)
local unitframes = engine:module("unitframes")
local BACKDROP = {
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	edgeSize = 16,
	bgFile = "Interface\\Buttons\\WHITE8x8",
	insets = { top = 2, bottom = 2, left = 2, right = 2, }
}


local function castbar_setinterruptible(castbar,isInterruptible)
	if isInterruptible then
	    self.icon:SetDesaturated(1)
	    self:SetStatusBarColor(0.4,0.4,0.4)
	else
	    self.icon:SetDesaturated(nil)
	    self:SetStatusBarColor(0.75,0.4,0)
	end
end

local function castbar_update(frame)
	local castbar = frame.castbar

	local spellName,_,_,_,timeStart,timeEnd,_,castID,notInterruptible = UnitCastingInfo(unit)
	if not spellName then
		spellName,_,_,_,timeStart,timeEnd,_,notInterruptible = UnitChannelInfo(unit)

		if not spellName then
			castbar:Hide()
			return
		end
	end

	timeEnd,timeStart = timeEnd/1e3,timeStart/1e3

	castbar.name:SetText(spellName)
	castbar_setinterruptible(castbar,notInterruptible)
	castbar:SetMinMaxValues(timeStart,timeEnd)

	castbar.len = timeEnd-timeStart
	if castID then -- is cast
		castbar:SetValue(0)
	else -- is channel
		castbar:SetValue(1)
	end

	local remain = timeEnd-GetTime()
	castbar.remain = remain
	castbar.castID = castID
	castbar.casting = true
	castbar:SetAlpha(1)
	castbar:Show()

end

local function castbar_endcast(castbar)
	self:SetValue(self.len)
	self.timer:SetText(nil)
	self.casting = nil
end

local function OnUpdate(self,elapsed)
	if self.isCasting then
		local remain = self.remain - elapsed
		if remain > 0 then
			local len = self.len
			self:SetValue(self.castID and len+remain or len-remain)
			self.timer:SetFormattedText("%.01f/%.01f",remain,len)
			self.remain = remain
		else
			castbar_endcast(self)
		end
	else
		local newAlpha = self:GetAlpha()-elapsed*1.4
		if newAlpha > 0 then
			self:SetAlpha(newAlpha)
		else
			self:Hide()
		end
	end
end

local function UNIT_SPELLCAST_START(self,unit)
	if unit ~= self.unit then return end
	castbar_update(self)
end

local function UNIT_SPELLCAST_FAILED(self,unit,_,_,castID)
	if unit ~= self.unit then return end

	local castbar = self.castbar
	if castID == castbar.castID then
	    castbar.name:SetText("|cff8B0000INTERRUPTED|r")
		castbar_endcast(castbar)
	end
end

local function UNIT_SPELLCAST_STOP(self,unit)
	if unit ~= self.unit then return end

	local castbar = self.castbar
	if castbar.isCasting then
		castbar_endcast(castbar)
	end
end

local function UNIT_SPELLCAST_INTERRUPTIBLE(self,unit)
	if unit ~= self.unit then return end
	castbar_setinterruptible(self.castbar,true)
end

local function UNIT_SPELLCAST_NOT_INTERRUPTIBLE(self,unit)
	if unit ~= self.unit then return end
	castbar_setinterruptible(self.castbar)
end

local function castbar_create(frame)
	local castbar = CreateFrame("StatusBar",nil,frame)
	castbar:SetFrameLevel(frame:GetFrameLevel())
	castbar:SetMinMaxValues(0,1)
	castbar:SetScript("OnUpdate",OnUpdate)
	castbar:SetStatusBarTexture("Interface\\Buttons\\WHITE8x8")

	local background = CreateFrame("frame",nil,castbar)
	background:SetPoint("TOPRIGHT",3,3)
	background:SetPoint("BOTTOMLEFT",-3,-3)
	background:SetBackdrop(BACKDROP)
	background:SetBackdropColor(0,0,0,0.8)
	background:SetBackdropBorderColor(0.4,0.4,0.4,0.95)
	background:SetFrameLevel(castbar:GetFrameLevel())

	local timer = castbar:CreateFontString(nil,"ARTWORK","NumberFontNormal")
	timer:SetAllPoints()
	timer:SetJustifyH("RIGHT")

	local name = castbar:CreateFontString(nil,"ARTWORK")
	name:SetFont("Fonts\\ARIALN.TTF",12,"OUTLINE")
	name:SetPoint("CENTER")


	frame:RegisterEvent("UNIT_SPELLCAST_START",UNIT_SPELLCAST_START)
	frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START",UNIT_SPELLCAST_START)
	frame:RegisterEvent("UNIT_SPELLCAST_FAILED",UNIT_SPELLCAST_FAILED)
	frame:RegisterEvent("UNIT_SPELLCAST_STOP",UNIT_SPELLCAST_STOP)
	frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED",UNIT_SPELLCAST_STOP)
	frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_INTERRUPTED",UNIT_SPELLCAST_STOP)
	frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP",UNIT_SPELLCAST_STOP)
	frame:RegisterEvent("UNIT_SPELLCAST_DELAYED",UNIT_SPELLCAST_START)
	frame:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE",UNIT_SPELLCAST_START)
	if frame.unit ~= "player" then
		frame:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE",UNIT_SPELLCAST_INTERRUPTIBLE)
		frame:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE",UNIT_SPELLCAST_NOT_INTERRUPTIBLE)
	end

	castbar.timer = timer
	castbar.name = name


	return castbar
end

unitframes:RegisterModule("castbar",castbar_create,castbar_update)