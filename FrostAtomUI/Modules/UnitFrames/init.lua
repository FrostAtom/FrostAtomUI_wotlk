local engine = select(2,...)
local unitframes = engine:module("unitframes")


function unitframes:OnInitialize()
    local player = self:CreatePlayerFrame(180,26)
    player:SetPoint("CENTER",0,-180)

    
end