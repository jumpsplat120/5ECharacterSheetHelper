local Object  = require("lib.classic.main")
local Stat    = require("bin.Stat")
local private = require("bin.instances")
local inspect = require("lib.inspect.main")

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

    p.min   = Stat(min, reason)
    p.max   = Stat(max, reason)
    p.value = Stat(val, reason)
end

function BoundedStat:get_min()   return private[self.uuid].min.value   end
function BoundedStat:get_max()   return private[self.uuid].max.value   end
function BoundedStat:get_value() return private[self.uuid].value.value end

function BoundedStat:set_min(_)   error("Unable to set minimum. Please use the 'setMin' method.") end
function BoundedStat:set_max(_)   error("Unable to set maximum. Please use the 'setMax' method.") end
function BoundedStat:set_value(_) error("Unable to set value. Please use the 'setValue' method.") end

function BoundedStat:setMin(val, action, reason)
    local p = private[self.uuid]

    assert(val <= p.max.value, "Minimum value must be smaller than or equal to the maximum bound.")
    assert(val <= p.value.value, "Minimum value must be smaller than or equal to the main value.")
   
    p.min:change(val, action, reason)
end

function BoundedStat:setMax(val, action, reason)
    local p = private[self.uuid]

    assert(val >= p.min.value, "Maximum value must be larger than or equal to the minimum bound.")
    assert(val >= p.value.value, "Maximum value must be smaller than or equal to the main value.")

    p.max:change(val, action, reason)
end

function BoundedStat:setValue(val, action, reason)
    local p = private[self.uuid]

    assert(val >= p.min.value, "Input value must be bigger than the minimum bound.")
    assert(val <= p.max.value, "Input value must be smaller than the maximum bound.")

    p.value:change(val, action, reason)
end

function BoundedStat:revert(steps, reason)
    local p = private[self.uuid]

    assert(not p.obvert_entry, "Unable to revert as you've already reverted.")

    p.obvert_entry = p.history[#p.history].value
    
    self:change(p.history[math.max(#p.history - (steps or 1), 1)].value, "REVERT", reason or "No reason given.")
end

function BoundedStat:obvert()
end

BoundedStat.__type = "BoundedStat"

function BoundedStat:__tostring()
    local p = private[self.uuid]
	return "Min: " .. p.min.value .. ", Max: " .. p.max.value .. ", Value: " .. p.value.value
end

return BoundedStat