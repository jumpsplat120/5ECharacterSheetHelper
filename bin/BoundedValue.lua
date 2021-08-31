local Object  = require("lib.classic.main")
local private = require("bin.instances")
--local inspect = require("lib.inspect.main")

local BoundedValue = Object:extend()

function BoundedValue:new(min, max, val)
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
    p.value = val
end

function BoundedValue:get_min()   return private[self.uuid].min   end
function BoundedValue:get_max()   return private[self.uuid].max   end
function BoundedValue:get_value() return private[self.uuid].value end

function BoundedValue:set_min(val)
    local p = private[self.uuid]

    assert(type(val) == "number", "Minimum value must be a number.")
    assert(val <= p.max, "Minimum value must be smaller than or equal to the maximum bound.")
    assert(val <= p.value, "Minimum value must be smaller than or equal to the main value.")
   
    p.min = val
end

function BoundedValue:set_max(val)
    local p = private[self.uuid]

    assert(type(val) == "number", "Maximum value must be a number.")
    assert(val >= p.min, "Maximum value must be larger than or equal to the minimum bound.")
    assert(val >= p.value, "Maximum value must be smaller than or equal to the main value.")

    p.max = val
end

function BoundedValue:set_value(val)
    local p = private[self.uuid]

    assert(type(val) == "number", "Input value must be a number.")
    assert(val >= p.min, "Input value must be bigger than the minimum bound.")
    assert(val <= p.max, "Input value must be smaller than the maximum bound.")

    p.value = val
end

BoundedValue.__type = "boundedvalue"

function BoundedValue:__tostring()
    local p = private[self.uuid]
	return "Min: " .. p.min .. ", Max: " .. p.max .. ", Value: " .. p.value
end

return BoundedValue