local BetterSignal = require(script.Parent)
type Signal<T...> = BetterSignal.Signal<T...>

local signal: Signal<string> = BetterSignal.new()

print('Threads and Waiting')

local newThread = task.spawn(function()
	-- in this new thread we will be waiting for our signal to be fired
	
	local message = signal:Wait()
	print(message)
	
	local secondMessage = signal:Wait()
	print(secondMessage)
	
	local thirdMessage = signal:Wait()
	print(thirdMessage) -- this wont print
end)

-- we wait 1 second before firing our signal
task.wait(1)
signal:Fire('boom!! this will print') -- yes

task.wait(2)
signal:Fire('we waited 2 seconds for this to print') -- yes

task.wait(1)
signal:DisconnectAll()
signal:Fire('since the signal disconnected everything this final message wont be printed') -- no

local soonToBeDeadThread = task.spawn(function()
	signal:Wait()
end)

task.wait(1)

task.cancel(soonToBeDeadThread)
signal:Fire('this will not error (unlike most signal modules)') -- no