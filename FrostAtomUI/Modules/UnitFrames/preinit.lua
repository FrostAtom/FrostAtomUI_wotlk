local engine = select(2,...)
local unitframes = engine:module("unitframes")

local createFuncs,updateFuncs = {},{}


function unitframes:RegisterModule(moduleName,createFunc,updateFunc)
	createFuncs[moduleName],updateFuncs[moduleName] = createFunc,updateFunc
end

function unitframes:CreateModule(frame,moduleName,...)
	local module = createFuncs[moduleName](frame,...)
	frame[moduleName] = module

	local frame_moduleUpdateQueue = frame.moduleUpdateQueue
	frame_moduleUpdateQueue[#frame_moduleUpdateQueue+1] = updateFuncs[moduleName]


	return module
end