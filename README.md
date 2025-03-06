# BetterSignal

BetterSignal is an improved and more up-to-date version of [stravant's GoodSignal](https://github.com/stravant/goodsignal) module which mimicks
Robloxs `RBXScriptSignal`

This version improves on GoodSignal without sacrificing on its performance or ease-of-use

## Use

Example code

```lua
local BetterSignal = require('BetterSignal') -- replace path
type Signal<T...> = BetterSignal.Signal<T...> -- import type as Signal

local signal: Signal<number> = BetterSignal.new()

local connection = signal:Connect(function(points)
    someExternalValue += points
    print('Points Added:', points) -- Output: 7
end)

-- fire one value, 7
signal:Fire(7)
```

## Changes

List of changes made from the original GoodSignal module

**Type Annotations**

BetterSignal supports type annotations, it exports two types `Signal` and `Connection`

When instantiating a new Signal object, pass in the type annotations for fired arguments

```lua
-- this signal fires a number, string and thread
local signal: Signal<number, string, thread> = BetterSignal.new()
```

**Reconnecting**

BetterSignal allows for disconnected Signals to be reconnected to their Signal object using `:Reconnect()`

```lua
connection:Disconnect()
-- :Reconnect() undoes :Disconnect()
connection:Reconnect()
```

**Destroying**

A new `:Destroy()` method has been added to both the Connection and Signal objects

Calling `:Destroy()` on a connection will also disconnect it from its signal, and calling `:Destroy()` on a signal will destroy all of its connections

```lua
signal:Destroy() -- goodbye
```

**Notes**

BetterSignal uses --optimize 2 and --native attributes

⚠️ When yielding a thread with `:Wait()`, if Wait's connection is disconnected, the affected thread will forever yield

The `:Wait()` dead thread called with arguments bug is fixed in this version

## License

Do anything you want with my code, credits not needed

[UNI](https://choosealicense.com/licenses/unlicense/)