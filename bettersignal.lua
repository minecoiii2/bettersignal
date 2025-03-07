--!optimize 2
--!native
-- Original module made by stravant, edited by minecoiii2

-- ** Type Structs ** --

export type Connection<T...> = {
	Connected: boolean,
	
	Signal: Signal<T...>,
	Callback: (T...) -> any,
	
	Fire: (Connection<T...>, T...) -> nil,
	Disconnect: (Connection<T...>) -> nil,
	Reconnect: (Connection<T...>) -> nil,
	Destroy: (Connection<T...>) -> nil,
}

export type Signal<T...> = {
	Fire: (Signal<T...>, T...) -> nil,
	
	Connect: (Signal<T...>, (T...) -> any) -> Connection<T...>,
	Once: (Signal<T...>, (T...) -> any) -> Connection<T...>,
	Wait: (Signal<T...>) -> T...,
	
	DisconnectAll: (Signal<T...>) -> nil,
	
	Destroy: (Signal<T...>) -> nil,
}

-- ** Threads ** --

-- The currently idle thread to run the next handler on
local freeRunnerThread = nil

-- Function which acquires the currently idle handler runner thread, runs the
-- function fn on it, and then releases the thread, returning it to being the
-- currently idle one.
-- If there was a currently idle runner thread already, that's okay, that old
-- one will just get thrown and eventually GCed.
local function acquireRunnerThreadAndCallEventHandler(fn, ...)
	local acquiredRunnerThread = freeRunnerThread
	freeRunnerThread = nil
	fn(...)
	-- The handler finished running, this runner thread is free again.
	freeRunnerThread = acquiredRunnerThread
end

-- Coroutine runner that we create coroutines of. The coroutine can be 
-- repeatedly resumed with functions to run followed by the argument to run
-- them with.
local function runEventHandlerInFreeThread()
	-- Note: We cannot use the initial set of arguments passed to
	-- runEventHandlerInFreeThread for a call to the handler, because those
	-- arguments would stay on the stack for the duration of the thread's
	-- existence, temporarily leaking references. Without access to raw bytecode
	-- there's no way for us to clear the "..." references from the stack.
	while true do
		acquireRunnerThreadAndCallEventHandler(coroutine.yield())
	end
end

-- ** Connection ** --
local Connection = {}
Connection.__index = Connection

function Connection.new(signal, callback)
	return setmetatable({
		Connected = false,
		
		Signal = signal,
		Callback = callback,
		Next = nil,
	}, Connection)
end

-- Clears the instance and disconnects it
function Connection:Destroy()	
	-- check if already destroyed
	if self.Connected == nil then return end 
	
	if self.Connected then
		self:Disconnect()
	end
	
	table.clear(self)
end

-- Unhooks the node from the Signals linked Connection list
function Connection:Disconnect()
	if not self.Connected then return end
	self.Connected = false

	if self.Signal.ConnectionHead == self then
		self.Signal.ConnectionHead = self.Next
	else
		local connection = self.Signal.ConnectionHead
		while connection and connection.Next ~= self do
			connection = connection.Next
		end
		if connection then
			connection.Next = self.Next
		end
	end
end

-- Re-introduce the connection in the Signals linked Connection list
function Connection:Reconnect()
	if self.Connected then return end
	self.Connected = true
	
	if self.Signal.ConnectionHead then
		self.Next = self.Signal.ConnectionHead
	end
	
	self.Signal.ConnectionHead = self
end

-- Signal seperate Fire method which only fires this Connections callback
function Connection:Fire(...)
	if not freeRunnerThread then
		freeRunnerThread = coroutine.create(runEventHandlerInFreeThread)
		-- Get the freeRunnerThread to the first yield
		coroutine.resume(freeRunnerThread)
	end
	task.spawn(freeRunnerThread, self.Callback, ...)
end

-- ** Signal ** --
local Signal = {}
Signal.__index = Signal

function Signal.new<T...>(): Signal<T...>
	return setmetatable({
		ConnectionHead = nil,
	}, Signal) :: any
end

-- Creates a new Connection object and hooks it
function Signal:Connect(func)
	local connection = Connection.new(self, func)
	connection:Reconnect()
	return connection
end

-- Destroys the signal, rendering it inaccessable
function Signal:Destroy()
	local connection = self.ConnectionHead
	while connection do
		local next = connection.Next
		connection.Connected = false
		connection:Destroy()
		connection = next
	end
	table.clear(self)
end

-- Disconnect all active Connections
function Signal:DisconnectAll()
	local connection = self.ConnectionHead
	while connection do
		connection.Connected = false
		connection = connection.Next
	end
	self.ConnectionHead = nil
end

-- Fires each active Connection with the passed arguments
function Signal:Fire(...)
	local connection = self.ConnectionHead
	while connection do
		connection:Fire(...)
		connection = connection.Next
	end
end

-- Yields until signal is fired, returns fired arguments
function Signal:Wait()
	local waitingCoroutine = coroutine.running()
	local connection
	connection = self:Connect(function(...)
		connection:Destroy()
		if coroutine.status(waitingCoroutine) == 'suspended' then
			task.spawn(waitingCoroutine, ...)
		end
	end)
	return coroutine.yield()
end

-- Creates a new connection which will disconnect itself after being fired
function Signal:Once(func)
	local connection
	connection = self:Connect(function(...)
		if connection.Connected then
			connection:Disconnect()
		end
		connection.Callback = func -- incase we reconnect, we wont disconnect again
		func(...)
	end)
	return connection
end

return {new = Signal.new} -- return only constructor