local BoundedStat = require("bin.BoundedStat")
local BoundedStat = require("bin.Roll")
local Object  = require("lib.classic.main")
local private = require("bin.instances")
local inspect = require("lib.inspect.main")

local Ability = Object:extend()

--[ total, modifier, roll(), rollSave() ]
function Ability:new(name, value, proficent, reason)
    value = value or 1

    assert(name, "Abilities require a name.")
    assert(type(name) == "string", "Ability name must be a string.")
    assert(type(value) == "number", "Input value must be a number.")

    private[self.uuid] = private[self.uuid] or {}

    local p = private[self.uuid]

    p.name = name
    p.stat = BoundedStat(0, 20, value, reason)

    self.proficent = proficent
end

function Ability:get_stat() return private[self.uuid].stat.value end
function Ability:get_total() return private[self.uuid].stat.value.value end
function Ability:get_modifier() return math.round(((private[self.uuid].stat.value.value - 10) / 2) + 0.5) end
function Ability:set_stat(_) error("Unable to set stat. Get the stat, then adjust it's relevant values.") end
function Ability:set_total(_) error("Unable to set value. Please use the 'setValue' method.") end
function Ability:set_modifier(_) error("Unable to set modifier directly. Adjust the stat instead.") end

function Ability:increase(val, reason)
end

function Ability:decrease(val, reason)
end

function Ability:roll()
    local p = private[self.uuid]

    Roll
end

function Ability:rollSave(prof_bonus)
end

Ability.__type = "Ability"

function Ability:__tostring()
    local p = private[self.uuid]
	return p.name + ": " + self.value.value
end