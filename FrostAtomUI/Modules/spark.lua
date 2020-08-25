local engine = select(2,...)
local spark = engine:module("spark")


local function statusbar_UpdateSpark(self,value,min,max)
	if not min then min,max = self:GetMinMaxValues() end
	if not value then value = self:GetValue() end
	local spark = self.spark

	if min == max then
		spark:Hide()
		return
	end

	spark:SetPoint("CENTER",self,"LEFT",self:GetWidth()*((value-min)/(max-min)),0)
	spark:Show()
end

local function statusbar_OnValueChanged(self,value)
	statusbar_UpdateSpark(self,value)
end

local function statusbar_SetMinMaxValues_hk(self,min,max)
	statusbar_UpdateSpark(self,nil,min,max)
end

function spark:Create(statusbar)
	local texture = statusbar:CreateTexture(nil,"OVERLAY")
	texture:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	texture:SetBlendMode("ADD")

	statusbar:HookScript("OnValueChanged",statusbar_OnValueChanged)
	hooksecurefunc(statusbar,"SetMinMaxValues",statusbar_SetMinMaxValues_hk)

	statusbar.UpdateSpark = statusbar_UpdateSpark
	statusbar.spark = texture
end