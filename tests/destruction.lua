local BetterSignal = require(script.Parent)
type Signal<T...> = BetterSignal.Signal<T...>

local signal: Signal<string> = BetterSignal.new()

local connection = signal:Connect(print)

signal:Fire('Destruction') -- yes
connection:Destroy()
signal:Fire('after destroying, this wont print') -- no
pcall(connection.Reconnect, connection) -- throws error, will not run, wrapped in pcall for a reason

signal:Destroy()