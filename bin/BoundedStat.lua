local Object  = require("lib.classic.main")
local private = require("bin.instances")
--local inspect = require("lib.inspect.main")

local BoundedStat = Object:extend()

function BoundedStat:new(min, max, val, reason)
    min = min or 0
    max = max or 0
    val = val or 0

    assert(type(min) == "number", "Minimum value must be a number.")
    assert(type(max) == "number", "Maximum value must be a number.")
    assert(type(val) == "number", "Input value must be a number.")

    assert(min <= max, "Minimum value must be smaller than or equal to the maximum bound.")
    assert(max >= min, "Maximum value must be larger than or equal to the minimum bound.")
    assert(val >= min, "Input value must be bigger than the minimum bound.")
    assert(val <= max, "Input value must be smaller than the maximum bound.")

    private[self.uuid] = private[self.uuid] or {}

    local p = private[self.uuid]

    p.min   = min
    p.max   = max
    p.value = Stat(val, reason)
end

function BoundedStat:get_min()   return private[self.uuid].min   end
function BoundedStat:get_max()   return private[self.uuid].max   end
function BoundedStat:get_value() return private[self.uuid].value end
function BoundedStat:set_value(val) error("Unable to set value; use 'setValue' method.") end

function BoundedStat:set_min(val)
    local p = private[self.uuid]

    assert(type(val) == "number", "Minimum value must be a number.")
    assert(val <= p.max, "Minimum value must be smaller than or equal to the maximum bound.")
   
    p.min = val

    if p.min > p.value.value then p.value:change(p.min, "increase", "Increase to new minimum.") end
end

function BoundedStat:set_max(val)
    local p = private[self.uuid]

    assert(type(val) == "number", "Maximum value must be a number.")
    assert(val >= p.min, "Maximum value must be larger than or equal to the minimum bound.")

    p.max = val

    if p.max < p.value.value then p.value:change(p.max, "decrease", "Decrease to new maximum.") end
end

function BoundedStat:setValue(val, action, reason)
    local p = private[self.uuid]

    assert(val >= p.min, "You may not set a value lower than the minimum bound.")
    assert(val >= p.max, "You may not set a value higher than the maximum bound.")

    p.value:change(val, action, reason)
end

BoundedStat.__type = "BoundedStat"

function BoundedStat:__tostring()
    local p = private[self.uuid]
	return "Min: " .. p.min .. ", Max: " .. p.max .. ", Value: " .. p.value.value
end

return BoundedStat