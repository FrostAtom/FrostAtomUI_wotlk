local engine = select(2,...)
local unitframes = engine:module("unitframes")

local GetPartyLeaderIndex = GetPartyLeaderIndex
local IsPartyLeader = IsPartyLeader
local tonumber = tonumber


local function leader_update(frame)
	local unit = frame.unit
	local leader = frame.leader

	local isLeader
	if unit == "player" then
		isLeader = IsPartyLeader()
	else
		isLeader = GetPartyLeaderIndex() == tonumber(unit:match(("(%d)$")))
	end

	if isLeader then
		leader:Show()
	else
		leader:Hide()
	end
end

local function leader_create(frame)
	local texture = frame:CreateTexture(nil,"HIGHLIGHT")
	texture:SetTexture("Interface\\GroupFrame\\UI-Group-LeaderIcon")
	texture:SetSize(16,16)
	frame:RegisterEvent("PARTY_LEADER_CHANGED",leader_update)

	return texture
end

unitframes:RegisterModule("leader",leader_create,leader_update)