--!nocheck
--[[
	Proximity · Core/Signal
	Lightweight signal. Handlers run synchronously, in connection order, and
	an erroring handler never stops the others.
]]

local Util = require("./Util")

local Connection = {}
Connection.__index = Connection

function Connection:Disconnect()
	if not self.Connected then
		return
	end
	self.Connected = false
	local list = self._signal._handlers
	local index = table.find(list, self)
	if index then
		table.remove(list, index)
	end
end
Connection.Destroy = Connection.Disconnect

local Signal = {}
Signal.__index = Signal

function Signal.new()
	return setmetatable({ _handlers = {} }, Signal)
end

function Signal.Is(value: any): boolean
	return type(value) == "table" and getmetatable(value) == Signal
end

function Signal:Connect(fn: (...any) -> ())
	local connection = setmetatable({ Connected = true, _fn = fn, _signal = self }, Connection)
	table.insert(self._handlers, connection)
	return connection
end

function Signal:Once(fn: (...any) -> ())
	local connection
	connection = self:Connect(function(...)
		connection:Disconnect()
		fn(...)
	end)
	return connection
end

function Signal:Fire(...: any)
	local snapshot = table.clone(self._handlers)
	for _, connection in snapshot do
		if connection.Connected then
			Util.SafeCall(connection._fn, ...)
		end
	end
end

function Signal:Wait(timeout: number?): ...any
	local thread = coroutine.running()
	local done = false
	local connection
	connection = self:Connect(function(...)
		if done then
			return
		end
		done = true
		connection:Disconnect()
		task.spawn(thread, ...)
	end)
	if timeout then
		task.delay(timeout, function()
			if not done then
				done = true
				connection:Disconnect()
				task.spawn(thread)
			end
		end)
	end
	return coroutine.yield()
end

function Signal:HasConnections(): boolean
	return #self._handlers > 0
end

function Signal:DisconnectAll()
	for _, connection in table.clone(self._handlers) do
		connection:Disconnect()
	end
end
Signal.Destroy = Signal.DisconnectAll

return Signal
