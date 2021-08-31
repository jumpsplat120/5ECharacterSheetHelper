local Object  = require("lib.classic.main")
local private = require("bin.instances")

local Stat = Object:extend()

local function createEntry(value, action, reason)
    reason = reason or "None"

    assert(type(action) == "string", "'" .. tostring(action) .. "' is not a string.")
    assert(type(reason) == "string", "'" .. tostring(reason) .. "' is not a string.")

    action = action:upper()

    assert(Stat.validActions[action], "'" .. action .. "' is not a valid stat change action.")

    return { timestamp = os.time(os.date("!*t")), value = value, action = action, reason = reason }
end

Stat.validActions = { INIT = true, LVLUP = true, INCREASE = true, DECREASE = true, CHANGE = true, DEBUG = true, REVERT = true, OBVERT = true }

function Stat:new(value, reason)
    private[self.uuid] = private[self.uuid] or {}

    private[self.uuid].value = value

    private[self.uuid].history = { createEntry(value, "INIT", reason) }
    private[self.uuid].index   = 1
end

function Stat:get_value() return private[self.uuid].value end
function Stat:set_value(val) error("Use the 'change' method to update a stat.") end

function Stat:change(val, action, reason)
    local p       = private[self.uuid]
    local old_val = self.value

    assert(type(val) == type(old_val), "You have changed your stat's type, which is not allowed. Your previous value's type was '" .. type(old_val) .. "' but the new type is '" .. type(val) .. "'.")
    
    p.value = val

    p.history[#p.history + 1] = createEntry(val, action, reason)
    p.index = p.index + 1
end

function Stat:revert(steps, reason)
    local p  = private[self.uuid]
    local ni = math.max(math.min(p.index - (steps or 1), 1), #p.history - 1)
    assert(not p.obvert_entry, "Unable to revert as you've already reverted.")

    p.obvert_entry = p.history[#p.history].value
    p.index = ni
    
    self:change(p.history[ni].value, "REVERT", reason or "No reason given.")
end

function Stat:obvert(reason)
    local p = private[self.uuid]

    assert(p.obvert_entry, "Unable to obvert as you have not reverted.")

    self:change(p.obvert_entry, "OBVERT", reason or "No reason given.")

    p.obvert_entry = nil
end

return Stat