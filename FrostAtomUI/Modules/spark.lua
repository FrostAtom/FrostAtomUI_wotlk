local engine = select(2,...)
local spark = engine:module("spark")


function spark:Create(statusbar)
	local texture = statusbar:CreateTexture(nil,"OVERLAY")
	texture:SetTexture("Interface\\CastingBar\\UI-CastingBar-Spark")
	texture:SetBlendMode("ADD")

	local m_min,m_max,m_value = 0,0,0
	local orig_SetMinMaxValues,orig_SetValue = statusbar.SetMinMaxValues,statusbar.SetValue

	local function UpdateSpark()
		if m_min == m_max then
			texture:Hide()
			return
		end

		local width = statusbar:GetWidth()
		local perc = m_value/(m_max-m_min)

		texture:SetPoint("CENTER",statusbar,"LEFT",width*perc,0)
		texture:Show()	
	end

	statusbar.SetMinMaxValues = function(self,min,max)
		m_min,m_max = min,max
		UpdateSpark()

		return orig_SetMinMaxValues(self,min,max)
	end

	statusbar.SetValue = function(self,value)
		m_value = value
		UpdateSpark()

		return orig_SetValue(self,value)
	end
end