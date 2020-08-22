local engine = select(2,...)

local table = table
local table_wipe = wipe
local type = type
local select = select
local next = next
local rawget = rawget


local function table_getKeyByValue(tbl,value)
	for k,v in next,tbl do
		if v == value then
			return k
		end
	end
end

local function table_removeByValue(tbl,value)
	local key = table_getKeyByValue(tbl,value)
	if not key then return end

	if type(key) == "number" and table.remove(tbl,key) then
		return true
	end

	if tbl[key] then
		tbl[key] = nil
		return true
	end
end

local function table_push(t,...)
	local n = #t
	for i = 1,select("#",...) do
		t[n+i] = select(i,...)
	end

	return t
end

local function table_mixin(t,...)
	for i = 1,select("#",...) do
		for k,v in next,(select(i,...)) do
			if not rawget(t,k) then
				t[k] = v
			end
		end
	end
end

local table_new,table_del
do
    local cache = setmetatable({},{
        __mode = "k"
    })

    table_new = function()
    	local n,t = #cache
    	if n == 0 then
    		t = {}
    	else
    		t,cache[n] = cache[n]
    	end
    	return t
    end

    table_del = function(tbl)
    	table_wipe(tbl)
    	cache[#cache+1] = tbl
	end
end

local function table_copy(tbl,deep)
	local result = table_new()
	for k,v in pairs(tbl) do
		if deep and type(v) == "table" then
			result[k] = copy(v,deep)
		else
			result[k] = v
		end
	end

	return result
end


engine.table = setmetatable({
	getKeyByValue = table_getKeyByValue,
	removeByValue = table_removeByValue,
	push = table_push,
	mixin = table_mixin,
	new = table_new,
	del = table_del,
	copy = table_copy,
	wipe = table_wipe,
},{__index = _G.table})