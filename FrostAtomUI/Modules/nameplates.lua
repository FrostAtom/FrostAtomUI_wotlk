local engine = select(2,...)
local spark = engine:module("spark")

local select = select
local unpack = unpack
local CreateFrame = CreateFrame
local HEALTHBAR_COLORS = engine.HEALTHBAR_COLORS
local ColorGradient = engine.ColorGradient
local BACKDROP = {
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	edgeSize = 12,
	bgFile = engine.STATUSBAR_TEXTURE,
	insets = { top = 2, bottom = 2, left = 2, right = 2, }
}
local HideInherited = engine.HideInherited

local isTargetExists


local function healthbar_UpdateColors(self,value)
	local r,g,b = ColorGradient(value/self.max,unpack(HEALTHBAR_COLORS))
	self:SetStatusBarColor(r,g,b)
	self.background:SetBackdropColor(r*0.3,g*0.3,b*0.3)
	self.r,self.g,self.b = self:GetStatusBarColor()
end

local function healthbar_OnValueChanged(self,value)
	if not self.max then self.max = select(2,self:GetMinMaxValues()) end
	healthbar_UpdateColors(self,value)
	self:UpdateSpark(value,0,self.max)
end

local function healthbar_OnUpdate(self)
	local _,max = self:GetMinMaxValues()
	local m_max = self.max
	if not m_max or  max ~= m_max then
		self.max = max
		healthbar_OnValueChanged(self,self:GetValue())
	else
		local r,g,b = self:GetStatusBarColor()
		if self.r ~= r or self.g ~= g or self.b ~= b then
			healthbar_UpdateColors(self,self:GetValue())
		end
	end

	self.highlight:SetAllPoints(self)
end

local function healthbar_UpdateName(self,unitName)
	local r,g,b = self:GetStatusBarColor()
	local name = self.name

	if r == 0 and (g >= 0.99 and b == 0) or (g == 0 and b >= 0.99) then
		name:SetTextColor(1,1,1)
		self.background:SetBackdropBorderColor(0,1,0)
	elseif r >= 0.99 and g >= 0.99 and b == 0 then
		name:SetTextColor(1,1,1)
		self.background:SetBackdropBorderColor(1,1,0)
	else
		name:SetTextColor(r,g,b)
		self.background:SetBackdropBorderColor(r,g,b)
	end

	name:SetText(unitName)
	local stringWidth,maxWidth = name:GetStringWidth(),self:GetWidth()*(3/4)
	if stringWidth > maxWidth then
		name:SetText(unitName:sub(1,maxWidth/(stringWidth/unitName:len())))
	end
end

local function nameplate_OnUpdate(self)
	if isTargetExists then
		self:SetAlpha(1)
	end
end

local function nameplate_OnShow(self)
	local healthbar = self.healthbar

	local unitName = self.origName:GetText()
	healthbar_UpdateName(healthbar,unitName)

	healthbar:ClearAllPoints()
	healthbar:SetSize(100,6)
	healthbar:SetPoint("TOP",0,-5)
end

local function nameplate_OnHide(self)
	self.highlight:Hide()
end

local function SetupNameplate(frame)
	local healthbar = frame:GetChildren()
	local threat,hpborder,cbshield,cbborder,cbicon,highlight,origName,level,bossicon,raidicon,elite = frame:GetRegions()
	healthbar:SetFrameLevel(frame:GetFrameLevel())
	healthbar:SetStatusBarTexture(engine.STATUSBAR_TEXTURE)

	HideInherited(threat)
	HideInherited(hpborder)
	-- cbshield
	-- cbborder
	-- cbicon
	highlight:SetTexture(1,1,1,0.5)
	HideInherited(origName)
	HideInherited(level)
	HideInherited(bossicon)
	HideInherited(raidicon)
	HideInherited(elite)

	local name = healthbar:CreateFontString(nil,"BORDER")
	name:SetPoint("BOTTOM",healthbar,"TOP",0,2)
	name:SetFont("Fonts\\ARIALN.TTF",10)
	name:SetShadowOffset(1,-1)

	local background = CreateFrame("frame",nil,healthbar)
	background:SetFrameLevel(healthbar:GetFrameLevel())
	background:SetPoint("TOPRIGHT",4,4)
	background:SetPoint("BOTTOMLEFT",-4,-4)
	background:SetBackdrop(BACKDROP)
	background:SetBackdropColor(0.1,0.1,0.1,0.75)
	background:SetBackdropBorderColor(0.4,0.4,0.4)


    spark:Create(healthbar)
	frame.healthbar = healthbar
	frame.origName = origName
	frame.highlight = highlight
	healthbar.name = name
    healthbar.background = background
	healthbar.highlight = highlight

	healthbar:SetScript("OnUpdate",healthbar_OnUpdate)
	healthbar:SetScript("OnValueChanged",healthbar_OnValueChanged)
	frame:SetScript("OnUpdate",nameplate_OnUpdate)
	frame:SetScript("OnShow",nameplate_OnShow)
	frame:SetScript("OnHide",nameplate_OnHide)
	nameplate_OnShow(frame)
end

local function GetFrameType(frame)
    if not frame:GetName() and frame.GetRegions then
        local region = frame:GetRegions()
        if region.GetTexture then
        	local texturePath = region:GetTexture()
        	if texturePath == "Interface\\TargetingFrame\\UI-TargetingFrame-Flash" then
        		return "nameplate"
        	elseif texturePath == "Interface\\Tooltips\\ChatBubble-Background" then
        		return "chatbubble"
        	end
        end
    end
end

local function iterateChildrens(...)
	local frame,frameType
	for i = 1,select("#",...) do
		frame = select(i,...)

		frameType = GetFrameType(frame)
		if frameType == "nameplate" then
			SetupNameplate(frame)
		elseif frameType == "chatbubble" then
			--SetupChatbubble(frame)
		end
	end
end


local WorldFrame = WorldFrame
local lastWorldFrameChildsCount = 0
local frame = CreateFrame("frame")

local function OnEvent()
	isTargetExists = UnitExists("target")
end

local function OnUpdate()
	local worldFrameChildsCount = WorldFrame:GetNumChildren()
	if worldFrameChildsCount ~= lastWorldFrameChildsCount then
		iterateChildrens(select(lastWorldFrameChildsCount+1,WorldFrame:GetChildren()))
		lastWorldFrameChildsCount = worldFrameChildsCount
	end
end

frame:SetScript("OnUpdate",OnUpdate)
frame:SetScript("OnEvent",OnEvent)
frame:RegisterEvent("PLAYER_TARGET_CHANGED")