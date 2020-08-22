local engine = select(2,...)

local math_floor = math.floor


local function math_round(x)
	return math_floor(x+0.51)
end

local function math_shortValue(x)
	if x < 0 then
		return x
	elseif x < 1e3 then
		return x
	elseif x < 1e6 then
		return ("%.01fk"):format(x/1e3)
	else
		return ("%.01fm"):format(x/1e6)
	end
end

local function math_shortTime(x)
	if x < 0 then
		return x
	elseif x < 3 then
		return ("%.01f"):format(x)
	elseif x < 60 then
		return math_round(x)
	elseif x <= 3600 then
		return math_round(x/60).."m"
	else
		return math_round(x/3600).."h"
	end
end


engine.math = setmetatable({
	round = math_round,
	shortValue = math_shortValue,
	shortTime = math_shortTime,
},{__index = math})