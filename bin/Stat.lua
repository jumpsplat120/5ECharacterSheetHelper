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
    private[self.uuid].index   = 0
end

function Stat:get_value() return private[self.uuid].value end
function Stat:get_history() return private[self.uuid].history end
function Stat:set_value(_) error("Use the 'change' method to update a stat.") end
function Stat:set_history(_) error("You may not change the history table directly.") end

function Stat:change(val, action, reason)
    local p       = private[self.uuid]
    local old_val = self.value

    assert(type(val) == type(old_val), "You have changed your stat's type, which is not allowed. Your previous value's type was '" .. type(old_val) .. "' but the new type is '" .. type(val) .. "'.")
    
    p.value = val

    p.index = p.index + 1
    p.history[p.index] = createEntry(val, action, reason)
    while p.index ~= #p.history do p.history[#p.history] = nil end
end

function Stat:revert(steps, reason)
    local p  = private[self.uuid]
    
    steps = steps or 1

    assert(p.index == 1, "Unable to revert as you as there is nothing to revert to.")
    assert(type(steps) == "number", "You can only revert a numeric amount.")
    assert(steps < 1, "You can only revert a positive number of steps. Use obvert if you'd like to 'redo'.")
    assert(p.index - steps > 0, "You can only revert to the first entry. (Tried to revert " .. steps .. " times, there are only " .. #p.history .. " entries.)")

    p.index = p.index - steps

    self:change(p.history[steps].value, "REVERT", reason or "No reason given.")
end

function Stat:obvert(steps, reason)
    local p = private[self.uuid]

    steps = steps or 1

    assert(p.index == #p.history, "Unable to obvert as you as there is nothing to obvert to.")
    assert(type(steps) == "number", "You can only obvert a numeric amount.")
    assert(steps < 1, "You can only obvert a positive number of steps. Use revert if you'd like to 'undo'.")
    assert(p.index + steps > #p.history, "You can only obvert to the last entry. (Tried to obvert to the " .. steps .. " entry, there are only " .. #p.history .. " entries.)")

    p.index = p.index + steps

    self:change(p.obvert_entry, "OBVERT", reason or "No reason given.")
end

return Stat