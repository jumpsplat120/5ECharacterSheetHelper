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

    p.bonus = Stat(bonus, reason)
    p.value = BoundedStat(0, max, val, reason)
end

function Health:get_max() return private[self.uuid].value.max end
function Health:get_value() return private[self.uuid].value.value end
function Health:get_bonus() return private[self.uuid].bonus end
function Health:set_max(_) error("Unable to set max health. Adjust the max health as it's own Stat.") end
function Health:set_value(_) error("Unable to set value. Please use the 'damage' or 'heal' methods.") end
function Health:set_bonus(_) error("Unable to set bonus. Use the 'setBonus' method.") end

--setBonus clamps at zero, and has some contextual error checking
function Health:setBonus(num, action, reason)
    assert(num, "Missing numeric value for health.")
    assert(action, "Missing action for health.")
    assert(type(num) == "number", "'" .. tostring(num) .. "' is not a number.")
    assert(num >= 0, "You are not able to set temporary health less than zero.")

    private[self.uuid].bonus:change(num, action, reason)
end

--Returns DEAD, DOWN, or OKAY based on remaining health
function Health:damage(num, reason)
    local p, val, bonus = private[self.uuid]

    val   = p.value.value
    bonus = p.bonus.value

    if bonus > 0 then
        p.bonus:change(math.max(bonus - num, 0), "DECREASE", reason)
        num = math.max(num - bonus, 0)
    end

    p.value:setValue(math.max(val - num, 0), "DECREASE", reason)
    num = num - val

    return num >= p.value.max.value +  and "DEAD" or num >= 0 and "DOWN" or "OKAY"
end

--Returns how much was actually healed by
function Health:heal(num, reason)
    local p, val, bound
    
    p = private[self.uuid]
    bound = p.value
    val   = bound.value.value

    bound:setValue(math.min(val + num, bound.max.value), "INCREASE", reason)

    return bound.value.value - val
end

--Returns how much was actually healed by
function Health:fullHeal(reason)
    local p, val, bound
    
    p = private[self.uuid]
    bound = p.value
    val   = bound.value.value

    bound:setValue(bound.max.value, "INCREASE", reason)

    return bound.value.value - val
end

function Health:__tostring()
    local p = private[self.uuid]
	return "current: " .. p.value.value .. " / max: " .. p.max.value .. " (Temp: " .. p.bonus.value .. ")"
end

Health.__type = "health"

return Health