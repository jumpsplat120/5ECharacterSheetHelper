local Object  = require("lib.classic.main")
local Stat    = require("bin.Stat")
local private = require("bin.instances")
local inspect = require("lib.inspect.main")

local StatBoundedStat = Object:extend()

function StatBoundedStat:new(min, max, val, reason)
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

function StatBoundedStat:get_min()   return private[self.uuid].min   end
function StatBoundedStat:get_max()   return private[self.uuid].max   end
function StatBoundedStat:get_value() return private[self.uuid].value end

function StatBoundedStat:set_min(_)   error("Unable to set minimum. Please use the 'setMin' method.") end
function StatBoundedStat:set_max(_)   error("Unable to set maximum. Please use the 'setMax' method.") end
function StatBoundedStat:set_value(_) error("Unable to set value. Please use the 'setValue' method.") end

function StatBoundedStat:setMin(val, action, reason)
    local p = private[self.uuid]

    assert(val <= p.max.value, "Minimum value must be smaller than or equal to the maximum bound.")
    assert(val <= p.value.value, "Minimum value must be smaller than or equal to the main value.")
   
    p.min:change(val, action, reason)
end

function StatBoundedStat:setMax(val, action, reason)
    local p = private[self.uuid]

    assert(val >= p.min.value, "Maximum value must be larger than or equal to the minimum bound.")
    assert(val >= p.value.value, "Maximum value must be smaller than or equal to the main value.")

    p.max:change(val, action, reason)
end

function StatBoundedStat:setValue(val, action, reason)
    local p = private[self.uuid]

    assert(val >= p.min.value, "Input value must be bigger than the minimum bound.")
    assert(val <= p.max.value, "Input value must be smaller than the maximum bound.")

    p.value:change(val, action, reason)
end

StatBoundedStat.__type = "StatBoundedStat"

function StatBoundedStat:__tostring()
    local p = private[self.uuid]
	return "Min: " .. p.min.value .. ", Max: " .. p.max.value .. ", Value: " .. p.value.value
end

return StatBoundedStat