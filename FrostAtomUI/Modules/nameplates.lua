local engine = select(2,...)
local spark = engine:module("spark")
local NAMEPLATE_WIDTH,NAMEPLATE_HEIGHT = 120,8
local HEALTHBAR_DELIMHEALTH = 10e3
local HEALTHBAR_INTERMEDIATEDELIMS = 4

local select = select
local unpack = unpack
local math = math
local CreateFrame = CreateFrame
local HEALTHBAR_COLORS = engine.HEALTHBAR_COLORS
local ColorGradient = engine.ColorGradient
local HideInherited = engine.HideInherited

local isTargetExists


local function castbar_OnUpdate(self)
	self:ClearAllPoints()
	self:SetSize(100,4)
	self:SetPoint("TOP",self.healthbar,"BOTTOM",0,-4)

	if self.shield:IsShown() then
	    self:SetStatusBarColor(0.45,0.45,0.45)
	    self.background:Show()
	else
	    self:SetStatusBarColor(1,0.6,0.2)
	end
end

local function healthbar_OnUpdate(self)
	local r,g,b = self:GetStatusBarColor()
	if self.r ~= r or self.g ~= g or self.b ~= b then
		if r == 0 and g == 0 and b >= 0.99 then
			self:SetStatusBarColor(0,1,0)
			r,g,b = self:GetStatusBarColor()
		end
		self.background:SetTexture(r*0.3,g*0.3,b*0.3)

		self.r,self.g,self.b = r,g,b
	end

	self.highlight:SetAllPoints(self.border)
end

function GetDelimHealth(min,value)
	while value / min > 10 do
		min = min * 10
	end

	return min
end

local function healthbar_OnValueChanged(self,value)
	local delimiters = self.delimiters
	local _,maxValue = self:GetMinMaxValues()
	local width = self:GetWidth()
	local delimHealth = GetDelimHealth(HEALTHBAR_DELIMHEALTH,value)
	local widthStep = width*((delimHealth/HEALTHBAR_INTERMEDIATEDELIMS)/maxValue)

	local delimiter
	for i = 1,math.max(math.floor(width/widthStep),#delimiters) do
		delimiter = delimiters[i]

		if (widthStep * i <= width) then
			if not delimiter then
				delimiter = self:CreateTexture(nil,"OVERLAY")
				delimiter:SetPoint("TOP")
				delimiter:SetPoint("BOTTOM")
				table.insert(delimiters,delimiter)
			end

			if i % HEALTHBAR_INTERMEDIATEDELIMS == 0 then
				delimiter:SetWidth(2)
				delimiter:SetTexture(0,0,0,1)
			else
				delimiter:SetWidth(1)
				delimiter:SetTexture(0,0,0,0.75)
			end

			delimiter:SetPoint("LEFT",-1+widthStep*i,0)
			delimiter:Show()
		elseif delimiter and delimiter:IsShown() then
			delimiter:Hide()
		else
			break
		end
	end
end

local function healthbar_OnShow(self)
	healthbar_OnValueChanged(self,self:GetValue())
end

local function healthbar_UpdateName(self,unitName)
	local name = self.name
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
	healthbar:ClearAllPoints()
	healthbar:SetSize(NAMEPLATE_WIDTH,NAMEPLATE_HEIGHT)
	healthbar:SetPoint("TOP",0,-5)

	local unitName = self.origName:GetText()
	healthbar_UpdateName(healthbar,unitName)
	--healthbar:UpdateSpark()
end

local function nameplate_OnHide(self)
	self.highlight:Hide()
end

local function SetupNameplate(frame)
	local healthbar,castbar = frame:GetChildren()
	local threat,hpborder,cbborder,cbshield,cbicon,highlight,origName,level,bossicon,raidicon,elite = frame:GetRegions()
	healthbar:SetFrameLevel(frame:GetFrameLevel())
	healthbar:SetBackdrop(BACKDROP)
	healthbar:SetBackdropBorderColor(0,0,0)
	--castbar:SetFrameLevel(frame:GetFrameLevel())
	--castbar:ClearAllPoints()

	HideInherited(threat)
	HideInherited(hpborder)
	HideInherited(cbshield)
	--cbborder:SetParent(castbar)
	--cbborder:SetTexture(0,0,0)
	--cbborder:SetDrawLayer("BACKGROUND")
	--cbborder:ClearAllPoints()
	--cbborder:SetPoint("TOPRIGHT",2,2)
	--cbborder:SetPoint("BOTTOMLEFT",-2,-2)
	--cbicon:SetParent(castbar)
	--cbicon:SetTexCoord(0.07,0.93,0.07,0.93)
	--cbicon:ClearAllPoints()
	--cbicon:SetSize(16,16)
	--cbicon:SetPoint("BOTTOMRIGHT",castbar,"BOTTOMLEFT",-2,-2)
	highlight:SetTexture(1,1,1,0.35)
	HideInherited(origName)
	HideInherited(level)
	HideInherited(bossicon)
	HideInherited(raidicon)
	HideInherited(elite)

	local name = healthbar:CreateFontString(nil,"BORDER")
	name:SetPoint("BOTTOM",healthbar,"TOP",0,2)
	name:SetTextColor(1,1,1)
	name:SetFont("Fonts\\ARIALN.TTF",9)
	name:SetShadowOffset(1,-1)

	local background = healthbar:CreateTexture(nil,"BORDER")
	background:SetAllPoints()
	background:SetBlendMode("blend")

	local border = healthbar:CreateTexture(nil,"BACKGROUND")
	border:SetPoint("TOPRIGHT",2,2)
	border:SetPoint("BOTTOMLEFT",-2,-2)
	border:SetTexture(0,0,0,0.9)


    --spark:Create(healthbar)
	healthbar.name = name
	healthbar.background = background
	healthbar.border = border
	healthbar.highlight = highlight
	--castbar.healthbar = healthbar
	--castbar.shield = cbshield
	--castbar.background = cbborder
	frame.healthbar = healthbar
	frame.origName = origName
	frame.highlight = highlight

	healthbar.delimiters = {}
	healthbar:SetScript("OnUpdate",healthbar_OnUpdate)
	healthbar:SetScript("OnShow",healthbar_OnShow)
	healthbar_OnShow(healthbar)
	healthbar:SetScript("OnValueChanged",healthbar_OnValueChanged)
	--castbar:SetScript("OnUpdate",castbar_OnUpdate)
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