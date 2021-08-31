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

    self.age    = Stat(age, "CC")
    self.name   = Stat(name, "CC")
    self.gender = Stat(gender, "CC")
    self.height = Stat(height, "CC")
    self.weight = Stat(weight, "CC")
end

Character.__type = "character"

function Character:__tostring()
    return "Character: " .. private[self.uuid].name
end

