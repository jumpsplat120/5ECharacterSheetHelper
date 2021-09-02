local Object  = require("lib.classic.main")
local Bounded = require("bin.BoundedStat")
local private = require("bin.instances")
local inspect = require("lib.inspect.main")

local Ability = Object:extend()

--[ total, roll(), relavant_ability, proficeny ]
function Ability:new(name, value, reason)
    value = value or 1

    assert(name, "Abilities require a name.")
    assert(type(value) == "number", "Input value must be a number.")

    private[self.uuid] = private[self.uuid] or {}

    local p = private[self.uuid]

    p.stat = BoundedStat(0, 20, value, reason)
end