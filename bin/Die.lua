local BoundedValue = require("bin.BoundedValue")
local private      = require("bin.instances")
local inspect      = require("lib.inspect.main")

local Die = BoundedValue:extend()

function Die:new(size)
    size = size or 2

    assert(type(size) == "number", "Die size must be a number.")
    assert(size >= 2, "Die size must be larger than or equal to 2.")

    Die.super.new(self, 1, size, 1)
end

function Die:set_min(val) error("Unable to set minimum. Die's always start at a minimum of 1.") end

function Die:set_max(val)
    assert(type(val) == "number", "Die size must be a number.")
    assert(val >= 2, "Die size must be larger than or equal to 2.")
    
    private[self.uuid].max = val
end

function Die:roll()
    local p = private[self.uuid]

    p.value = math.random(p.min, p.max)    
    return p.value
end

function Die:rerollOn(...)
    local reroll_on, options, p
    
    p         = private[self.uuid]
    reroll_on = {}
    options   = {}

    for _, v in ipairs({...}) do reroll_on[v] = true end

    for j = 1, p.max, 1 do
        if not reroll_on[j] then options[#options + 1] = j end 
    end

    p.value = options[math.random(1, #options)]

    return p.value
end

function Die:weightedRoll(weight, val)
    local p = private[self.uuid]

    assert(type(weight) == "number", "Weight must be a number.")
    assert(type(val) == "number", "The value you'd wish to roll must be a number.")

    assert(weight <= 1 and weight >= 0, "Weight must be between 0 and 1, inclusive.")
    assert(val >= p.min and val <= p.max, "The value to be rolled must be within the size of the die.")

    if math.random() >= weight then 
        p.value = val
    else 
        local newval = math.random(p.min, p.max)
        while newval == val do newval = math.random(p.min, p.max) end
        p.value = newval
    end

    return p.value
end

Die.__type = "die"

function Die:__tostring()
	return "d" .. private[self.uuid].max
end

return Die