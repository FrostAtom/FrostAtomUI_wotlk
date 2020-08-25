local engine = select(2,...)

local table = engine.table
local type = type
local next = next
local safecall = engine.exception.safecall

local frame,callbacks = CreateFrame("Frame"),{}
local prototype = {}


function prototype:RegisterEvent(event,func)
	if not func then
		func = self[event]
	elseif type(func) == "string" then
		func = self[func]
	end

	local callbacks_event = callbacks[event]
	if callbacks_event then
		local callbacks_event_self = callbacks_event[self]
		if callbacks_event_self then
			if type(callbacks_event_self) == "table" then
				callbacks_event_self[#callbacks_event_self+1] = func
			else
				callbacks_event[self] = table.push(table.new(),callbacks_event_self,func)
			end
		else
			callbacks_event[self] = func
		end
	else
		callbacks_event = table.new()
		callbacks_event[self] = func
		callbacks[event] = callbacks_event

		frame:RegisterEvent(event)
	end
end

function prototype:UnregisterEvent(event,func)
	local callbacks_event = callbacks[event]
	if not callbacks_event then return end

	local callbacks_event_self = callbacks_event[self]
	if not callbacks_event_self then return end

	local isCanBeEmpty
	if func then
		if type(callbacks_event_self) == "table" then
			if table.removeByValue(callbacks_event_self,func) then
				if #callbacks_event_self == 1 then
					callbacks_event[self] = callbacks_event_self[1]
					table.del(callbacks_event_self)
				end
			end
		else
			if callbacks_event_self == func then
				callbacks_event[self] = nil
				isCanBeEmpty = true
			end
		end
	else
		if type(callbacks_event_self) == "table" then
			table.del(callbacks_event_self)
		end
		callbacks_event[self] = nil
		isCanBeEmpty = true
	end

	if isCanBeEmpty and not next(callbacks_event) then
		callbacks[event] = table.del(callbacks_event)
		frame:UnregisterEvent(event)
	end
end

function prototype:UnregisterAllEvents()
	local callbacks_event_self,isCanBeEmpty
	for event,callbacks_event in next,callbacks do
		callbacks_event_self = callbacks_event[self]
		if callbacks_event_self then
			isCanBeEmpty = false

			if type(callbacks_event_self) == "table" then
				if table.removeByValue(callbacks_event_self,func) then
					if #callbacks_event_self == 1 then
						callbacks_event[self] = callbacks_event_self[1]
						table.del(callbacks_event_self)
					end
				end
			else
				if callbacks_event_self == func then
					callbacks_event[self] = nil
					isCanBeEmpty = true
				end
			end

			if isCanBeEmpty and not next(callbacks_event) then
				callbacks[event] = table.del(callbacks_event)
				frame:UnregisterEvent(event)
			end
		end
	end
end

local function FireEvent(event,...)
	local callbacks_event = callbacks[event]
	if not callbacks_event then return end

	for object,callback in next,callbacks_event do
		if type(callback) == "table" then
			for i = 1,#callback do
				safecall(callback[i],object,...)
			end
		else
			safecall(callback,object,...)
		end
	end
end


frame:SetScript("OnEvent",function(self,...) FireEvent(...) end)
engine.events_prototype = prototype
engine.FireEvent = FireEvent