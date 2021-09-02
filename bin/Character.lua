local Object   = require("lib.classic.main")
local Health   = require("bin.Health")
local Stat     = require("bin.Stat")
local private  = require("bin.instances")
--local inspect = require("lib.inspect.main")

local Character = Object:extend()

function Character:new(name, age, gender, height, weight)
    assert(type(name) == "string", "Character name must be a string.")

    private[self.uuid] = private[self.uuid] or {}

    local p = private[self.uuid]

    p.age    = Stat(age, "CC")
    p.name   = Stat(name, "CC")
    p.gender = Stat(gender, "CC")
    p.height = Stat(height, "CC")
    p.weight = Stat(weight, "CC")
end

Character.__type = "character"

function Character:__tostring()
    return "Character: " .. private[self.uuid].name
end

