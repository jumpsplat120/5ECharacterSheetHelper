local Object  = require("lib.classic.main")
local Die     = require("bin.Die")
local private = require("bin.instances")
local inspect = require("lib.inspect.main")

local Roll = Object:extend()

function Roll:new()
    private[self.uuid] = private[self.uuid] or {}

    local p = private[self.uuid]

    p.d2 = Die(2)
    p.d4 = Die(4)
    p.d6 = Die(6)
    p.d8 = Die(8)
    p.d10 = Die(10)
    p.d12 = Die(12)
    p.d20 = Die(20)

    p.roll = 0
end

Roll.validDiceSizes = { nil, true, nil, true, nil, true, nil, true, nil, true, nil, true, nil, nil, nil, nil, nil, nil, nil, true }

local function validateDie(die)
    assert(type(die) == "number", "'" .. tostring(die) .. "' is not a number.")

    assert(Roll.validDiceSizes[die], "Invalid die size. Valid die sizes are 2, 4, 6, 8, 10, 12 and 20.")
end

function Roll:start(amt, die_size)
    validateDie(die_size)

    self.tbl = { {amt, private[self.uuid][die_size], {} } }

    return self
end

function Roll:plus(amt, die_size)
    assert(self.tbl, "No roll has been started. Start a roll with :start(die_size)")
    validateDie(die_size)

    self.tbl[#self.tbl + 1] = { amt, private[self.uuid][die_size], {} }

    return self
end

function Roll:add(num)
    assert(self.tbl, "No roll has been started. Start a roll with :start(die_size)")
    assert(type(num) == "number", "Expected number, recieved '" ..  type(num) .. "'.")

    local mods = self.tbl[#self.tbl][3]
    mods.add = num + (mods.add or 0)

    return self
end

function Roll:reroll(...)
    for _, num in ipairs({...}) do
        assert(self.tbl, "No roll has been started. Start a roll with :start(die_str)")
        assert(type(num) == "number", "Expected number, recieved '" ..  type(num) .. "'.")
        assert(num >= 1, "Unable to reroll " .. tostring(num) .. "'s, as a die will never have a value lower than 1.")
        assert(num <= self.tbl[#self.tbl][2].max, "Unable to reroll " .. tostring(num) .. "'s, as it is higher than the maximum size of the die. (" .. self.tbl[#self.tbl][2].max .. ")")

        local mods = self.tbl[#self.tbl][3]

        mods.reroll = mods.reroll or {}

        mods.reroll[#mods.reroll + 1] = num
    end

    return self
end

function Roll:advantage()
    assert(self.tbl, "No roll has been started. Start a roll with :start(die_str)")
    local mods = self.tbl[#self.tbl][3]

    mods.advantage = (mods.advantage or 0) + 1

    return self
end

function Roll:disadvantage()
    assert(self.tbl, "No roll has been started. Start a roll with :start(die_str)")
    local mods = self.tbl[#self.tbl][3]

    mods.disadvantage = (mods.disadvantage or 0) + 1

    return self
end

function Roll:output()
    assert(self.tbl, "No roll has been started. Start a roll with :start(die_str)")

    local result = 0

    for _, die_tbl in ipairs(self.tbl) do
        local amount, die_obj, mods_tbl, vantage

        amount   = die_tbl[1]
        die_obj  = die_tbl[2]
        mods_tbl = die_tbl[3]

        vantage = math.min(1, math.max((mods_tbl.advantage or 0) - (mods_tbl.disadvantage or 0), -1))

        for i = 1, amount, 1 do
            local roll, rerolls, max, valid_rolls
            
            rerolls = mods_tbl.reroll or {}
            max     = die_obj.max

            assert(#rerolls < max, "Unable to reroll every single die value.")

            roll = die_obj:roll()

            if vantage ~= 0    then roll = math[vantage > 0 and "max" or "min"](die_obj:roll(), roll) end
            if mods_tbl.reroll then roll = die_obj:rerollOn(unpack(mods_tbl.reroll)) end

            result = result + roll
        end

        result = result + (mods_tbl.add or 0)
    end

    private[self.uuid].result = result

    return result
end

function Roll:__tostring()
    local p, result = private[self.uuid], ""

    if self.tbl then
        for i, die_tbl in ipairs(self.tbl) do
            local amount, die_obj, mods_tbl, vantage
    
            amount   = die_tbl[1]
            die_obj  = die_tbl[2]
            mods_tbl = die_tbl[3]
            
            result = result .. tostring(amount) .. "d" .. tostring(die_obj.max)

            if mods_tbl.advantage or mods_tbl.disadvantage or mods_tbl.reroll then
                local reroll_str

                if mods_tbl.reroll then 
                    reroll_str = mods_tbl.reroll[1]
                    for j = 2, #mods_tbl.reroll, 1 do reroll_str = reroll_str .. ", " .. tostring(mods_tbl.reroll[j]) end
                end

                result = result .. " (" .. (mods_tbl.advantage and "advantages: " .. tostring(mods_tbl.advantage) .. ", " or "") .. (mods_tbl.disadvantage and "disadvantages: " .. tostring(mods_tbl.disadvantage) .. ", " or "") .. (reroll_str and "reroll on: " .. reroll_str or "") .. ")"
            end

            if mods_tbl.add then result = result ..  " + " .. tostring(mods_tbl.add) end

            result = result .. (i == #self.tbl and "" or " & ")
        end
    else
        result = "No roll created."
    end

	return result
end

Roll.__type = "roll"

return Roll