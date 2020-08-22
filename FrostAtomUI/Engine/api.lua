local engine = select(2,...)

local select = select
local math_modf = math.modf

local function ColorGradient(x,...)
	if x >= 1 then
		return select(select("#",...)-2,...)
	elseif x <= 0 then
		local r,g,b
		return r,g,b
	end

	local N = select("#",...)/3
	local segment,relperc = math_modf(x*(N-1))
	local r1,g1,b1,r2,g2,b2 = select(segment*3+1,...)

	return r1+(r2-r1)*relperc,g1+(g2-g1)*relperc,b1+(b2-b1)*relperc
end


engine.ColorGradient = ColorGradient