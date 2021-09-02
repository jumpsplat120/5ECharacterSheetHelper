require("lib.extended_types.main")

function table.contains(table, element)
    for _, value in pairs(table) do if value == element then return true end end
    return false
end

local socket       = require("socket")
local inspect      = require("lib.inspect.main")
local BoundedValue = require("bin.BoundedValue")
local Die          = require("bin.Die")
local Health       = require("bin.Health")
local Roll         = require("bin.Roll")
local Character    = require("bin.Character")

math.randomseed(socket.gettime() * 1000)

health = Health(25)
print(health)
--health.value:revert()
--print(health)

health:damage(15)
print(health)
print(inspect(health.value.history))

health.value:revert()
print(health)
print(inspect(health.value.history))

health.value:obvert()
print(health)
print(inspect(health.value.history))

health:damage(5)
print(health)
print(inspect(health.value.history))
--
--print(health)
--
--health:setBonus(5, "debug", "bob")
--print(health.history)