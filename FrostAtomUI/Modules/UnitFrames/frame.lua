local ADDON_NAME,engine = ...
local unitframes = engine:module("unitframes")

local BACKDROP = {
	edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	edgeSize = 16,
	bgFile = "Interface\\Buttons\\WHITE8x8",
	insets = { top = 2, bottom = 2, left = 2, right = 2, }
}
local table = engine.table


local prototype = setmetatable({},{__index = PlayerFrame})
local MT = {__index = prototype}
table.mixin(prototype,engine.events_prototype)

function prototype:UpdateModules()
	local self_moduleUpdateQueue = self.moduleUpdateQueue
	for i = 1,#self_moduleUpdateQueue do
		self_moduleUpdateQueue[i](self)
	end
end


function unitframes:CreateBase(unit)
	local frame = setmetatable(CreateFrame("Button",ADDON_NAME..unit:gsub("^%l",string.upper),UIParent,"SecureUnitButtonTemplate"),MT)
	frame:RegisterForClicks("AnyDown")
	frame:SetBackdrop(BACKDROP)
	frame:SetBackdropColor(0.137,0.137,0.137)
	frame:SetBackdropBorderColor(0.2,0.2,0.2)

	frame.unit = unit
	frame:SetAttribute("unit",unit)
	frame:SetAttribute("*type1","target")
	frame:SetScript("OnEnter",UnitFrame_OnEnter)
	frame:SetScript("OnLeave",UnitFrame_OnLeave)
	frame:SetScript("OnShow",frame.UpdateModules)
	frame:RegisterEvent("PLAYER_ENTERING_WORLD",frame.UpdateModules)
	RegisterUnitWatch(frame)

	frame.moduleUpdateQueue = {}

	return frame
end