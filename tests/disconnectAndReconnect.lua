local BetterSignal = require(script.Parent)
type Signal<T...> = BetterSignal.Signal<T...>

local signal: Signal<string> = BetterSignal.new()

local connection = signal:Connect(print)
signal:Fire('Disconnecting and Reconnecting') -- yes
connection:Disconnect()
signal:Fire('connection disconnected, wont print') -- no
connection:Reconnect()
signal:Fire('after reconnecting, this will print') -- yes
signal:DisconnectAll()
signal:Fire('due to the full disconnection, this wont print') -- no
connection:Reconnect()
signal:Fire('after reconnecting again, this will print') -- yes
connection:Disconnect()
connection:Fire('firing the connection object, this will print') -- yes

local once = signal:Once(print)
signal:Fire('this will print') -- yes
signal:Fire('connection disconected, this wont print') -- no
once:Reconnect()
signal:Fire('after reconnecting it, this will print') -- yes
signal:Fire('...and we can fire it again and itll still print') -- yes
signal:DisconnectAll()
signal:Fire('sadly this wont print anymore due to the disconnectAll') -- no

local secondOnce = signal:Once(print)
secondOnce:Disconnect()
signal:Fire('simple disconect, this wont print') -- no