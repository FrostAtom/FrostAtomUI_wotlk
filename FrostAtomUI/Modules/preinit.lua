local engine = select(2,...)

local table = engine.table
local next = next
local type = type
local select = select

local modules,dependencies = {},{}


local function InitializeModule(name,module)
	assert(module,("InitializeModule(): can't find module [%q]"):format(name))

	local module_OnInitialize = module.OnInitialize
	if module_OnInitialize then
		local deps = dependencies[name]
		if deps then
			local name
			for i = 1,#deps do
				name = deps[i]
				InitializeModule(name,modules[name])
			end

			dependencies[name] = depentable.del(deps)
		end

		module_OnInitialize(module)
		module.OnInitialize = nil
	end
end

function engine:module(name,...) -- deps
	local module = modules[name]
	if not module then module = {} modules[name] = module end
	if select("#",...) > 0 then
		local deps = dependencies[name]
		if deps then
			table.push(deps,...)
		else
			dependencies[name] = table.push(table.new(),...)
		end
	end

	return module
end

function engine:InitializeModules()
	for k,v in next,modules do
		InitializeModule(k,v)
	end

	self.InitializeModules = nil
end