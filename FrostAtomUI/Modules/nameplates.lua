local engine = select(2,...)
local spark = engine:module("spark")

local select = select
local unpack = unpack
local CreateFrame = CreateFrame
local HEALTHBAR_COLORS = engine.HEALTHBAR_COLORS
local ColorGradient = engine.ColorGradient
local HideInherited = engine.HideInherited

local isTargetExists


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
	healthbar:SetSize(100,4)
	healthbar:SetPoint("TOP",0,-5)

	local unitName = self.origName:GetText()
	healthbar_UpdateName(healthbar,unitName)
	--healthbar:UpdateSpark()
end

local function nameplate_OnHide(self)
	self.highlight:Hide()
end

local function SetupNameplate(frame)
	local healthbar = frame:GetChildren()
	local threat,hpborder,cbshield,cbborder,cbicon,highlight,origName,level,bossicon,raidicon,elite = frame:GetRegions()
	healthbar:SetFrameLevel(frame:GetFrameLevel())
	healthbar:SetStatusBarTexture(engine.STATUSBAR_TEXTURE)
	healthbar:SetBackdrop(BACKDROP)
	healthbar:SetBackdropBorderColor(0,0,0)

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
	frame.healthbar = healthbar
	frame.origName = origName
	frame.highlight = highlight
	healthbar.name = name
	healthbar.background = background
	healthbar.border = border
	healthbar.highlight = highlight

	healthbar:SetScript("OnUpdate",healthbar_OnUpdate)
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