local engine = select(2,...)
local unitframes = engine:module("unitframes")
local spark = engine:module("spark")


local function castbar_setinterruptible(self,isInterruptible)
	if isInterruptible then
	    self:SetStatusBarColor(1,0.6,0.2)
	else
	    self:SetStatusBarColor(0.45,0.45,0.45)
	end
end

local function castbar_update(frame)
	local castbar = frame.castbar
	local unit = frame.unit

	local spellName,_,_,_,timeStart,timeEnd,_,castID,notInterruptible = UnitCastingInfo(unit)
	if not spellName then
		spellName,_,_,_,timeStart,timeEnd,_,notInterruptible = UnitChannelInfo(unit)

		if not spellName then
			castbar:Hide()
			return
		end
	end
	timeEnd,timeStart = timeEnd/1e3,timeStart/1e3

	castbar:SetMinMaxValues(timeStart,timeEnd)
	castbar:SetValue(castID and timeStart or timeEnd)
	castbar.name:SetText(spellName)
	--castbar.icon:SetTexture(texture ~= "" and texture or "Interface\\Icons\\Inv_Misc_QuestionMark")

	if unit ~= "player" then
		castbar_setinterruptible(castbar,not notInterruptible)
	end

	castbar.remain = timeEnd-GetTime()
	castbar.timeEnd = timeEnd
	castbar.timeStart = timeStart
	castbar.castID = castID
	castbar:SetAlpha(1)
	castbar:Show()
end


local function OnUpdate(self,elapsed)
	local remain = self.remain - elapsed
	if remain > 0 then
		if self.castID then
			self:SetValue(self.timeEnd - remain)
		else
			self:SetValue(self.timeStart + remain)
		end

		self.remain = remain
	else
		self:Hide()
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
		castbar:Hide()
	end
end

local function UNIT_SPELLCAST_STOP(self,unit)
	if unit ~= self.unit then return end

	local castbar = self.castbar
	if castbar.isCasting then
		castbar:Hide()
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
	castbar:SetScript("OnUpdate",OnUpdate)
	castbar:SetStatusBarTexture(engine.STATUSBAR_TEXTURE)
	castbar:SetStatusBarColor(1,0.6,0.2)

	local background = castbar:CreateTexture(nil,"BACKGROUND")
	background:SetAllPoints()
	background:SetTexture(engine.STATUSBAR_TEXTURE)
	background:SetVertexColor(0,0,0,0.5)

	--local icon = castbar:CreateTexture(nil,"BORDER")
	--icon:SetTexCoord(0.07,0.93,0.07,0.93)

	local name = castbar:CreateFontString(nil,"ARTWORK")
	name:SetFont("Fonts\\ARIALN.TTF",10)
	name:SetShadowOffset(1,-1)
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

	spark:Create(castbar)
	castbar.timer = timer
	--castbar.icon = icon
	castbar.name = name


	return castbar
end

unitframes:RegisterModule("castbar",castbar_create,castbar_update)