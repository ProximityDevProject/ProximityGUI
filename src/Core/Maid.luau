--!nocheck
--[[
	Proximity · Core/Maid
	Owns anything that must be cleaned: instances, connections, threads,
	functions and objects with Destroy/Disconnect. One Clean() frees it all.
]]

local Maid = {}
Maid.__index = Maid

function Maid.new()
	return setmetatable({ _tasks = {} }, Maid)
end

function Maid:Give<T>(task_: T): T
	if task_ ~= nil then
		table.insert(self._tasks, task_)
	end
	return task_
end
Maid.Add = Maid.Give

-- Connects and keeps the connection in one call.
function Maid:Connect(signal: any, fn: (...any) -> ())
	return self:Give(signal:Connect(fn))
end

local function cleanup(item: any)
	local kind = typeof(item)
	if kind == "RBXScriptConnection" then
		item:Disconnect()
	elseif kind == "Instance" then
		item:Destroy()
	elseif kind == "function" then
		item()
	elseif kind == "thread" then
		pcall(task.cancel, item)
	elseif kind == "table" then
		if type(item.Destroy) == "function" then
			item:Destroy()
		elseif type(item.Disconnect) == "function" then
			item:Disconnect()
		elseif type(item.Clean) == "function" then
			item:Clean()
		end
	end
end

function Maid:Clean()
	local tasks = self._tasks
	self._tasks = {}
	for i = #tasks, 1, -1 do
		pcall(cleanup, tasks[i])
	end
end
Maid.Destroy = Maid.Clean

return Maid
