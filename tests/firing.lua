local BetterSignal = require(script.Parent)
type Signal<T...> = BetterSignal.Signal<T...>

local signal: Signal<any, ...any> = BetterSignal.new()

local connection = signal:Connect(print)

signal:Fire('Firing')

signal:Fire('You', 'can', 'fire', 'many', 'args', 'this', 'will', 'print') -- yes
signal:Fire(1, { someValue = true }, true, nil, false, 'this', 'will', print) -- yes

connection:Fire('you can even fire individual connections', 'this', 'will', print) -- yes

signal:DisconnectAll()
signal:Fire('obviously this wont fire then, so no print') -- no