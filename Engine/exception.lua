local engine = select(2,...)

local table = engine.table
local ItemRefTooltip = ItemRefTooltip
local UIParent = UIParent
local debuginfo = debuginfo
local debugstack = debugstack
local pcall = pcall


local function throw(text)
	debuginfo()

	ItemRefTooltip:Hide()
	ItemRefTooltip:SetOwner(UIParent,"ANCHOR_PRESERVE")
	ItemRefTooltip:AddLine(text,1,0.2,0.2)
	ItemRefTooltip:AddLine(debugstack(4),1,1,1)
	ItemRefTooltip:Show()
end

local function validate_call(isOk,...)
	if not isOk then
		local err = ...
		throw(err)
	else
		return ...
	end
end

local function safecall(...)
	return validate_call(pcall(...))
end

engine.exception = {
	throw = throw,
	safecall = safecall,
}
