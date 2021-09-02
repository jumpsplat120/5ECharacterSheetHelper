local StatBoundedStat = require("bin.StatBoundedStat")
local BoundedStat = require("bin.BoundedStat")
local Stat        = require("bin.Stat")
local private     = require("bin.instances")
--local inspect = require("lib.inspect.main")

local Health = Object:extend()

function Health:new(max, bonus, val, reason)
    bonus = bonus or 0
    max   = max   or 0
    val   = val   or max

    assert(type(max)   == "number", "Maximum health must be a number.")
    assert(type(val)   == "number", "Starting health must be a number.")
    assert(type(bonus) == "number", "Starting temporary health must be a number.")

    assert(max >= 0,   "Maximum value must be larger than or equal to zero.")
    assert(val >= 0,   "Starting health must be bigger than or equal to zero.")
    assert(val <= max, "Starting health must be smaller than or equal to the maximum health.")
    assert(bonus >= 0, "Starting temporary health must be bigger than or equal to zero.")

    private[self.uuid] = private[self.uuid] or {}

    local p = private[self.uuid]

    p.bonus = BoundedStat(0, math.huge, bonus, reason)
    p.value = StatBoundedStat(0, max, val, reason)
end

function Health:get_max() return private[self.uuid].value.max end
function Health:get_value() return private[self.uuid].value.value end
function Health:get_bonus() return private[self.uuid].bonus end
function Health:set_max(_) error("Unable to set max health. Adjust the max health as its own Stat.") end
function Health:set_value(_) error("Unable to set value. Please use one of the respective methods.") end
function Health:set_bonus(_) error("Unable to set bonus. Adjust the bonus as its own Stat.") end

--Returns DEAD, DOWN, or OKAY based on remaining health
function Health:damage(num, reason)
    local p, val, bonus = private[self.uuid]

    val   = self.value.value
    bonus = p.bonus.value

    if bonus > 0 then
        p.bonus:change(math.max(bonus - num, 0), "DECREASE", reason)
        num = math.max(num - bonus, 0)
    end

    p.value:setValue(math.max(val - num, 0), "DECREASE", reason)
    num = num - val

    return num >= self.max.value and "DEAD" or num >= 0 and "DOWN" or "OKAY"
end

--Returns how much was actually healed by
function Health:heal(num, reason)
    local p, val = private[self.uuid]

    val = self.value.value

    p.value:setValue(math.min(val + num, self.max.value), "INCREASE", reason)

    return self.value.value - val
end

--Returns how much was actually healed by
function Health:fullHeal(reason)
    local p, val = private[self.uuid]

    val = self.value.value

    bound:setValue(self.max.value, "INCREASE", reason)

    return self.value.value - val
end

function Health:__tostring()
	return "current: " .. self.value.value .. " / max: " .. self.max.value .. " (Temp: " .. private[self.uuid].bonus.value .. ")"
end

Health.__type = "health"

return Health