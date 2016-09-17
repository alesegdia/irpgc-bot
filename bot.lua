
class = require("lib.middleclass.middleclass")
util = require("util")
pl = require 'pl.pretty'
botdata = require("botdata")

local botirc = require("botirc")

local basemod = require("module.misc")
local glmod = require("module.glmod")
botirc:add_module(basemod)
botirc:add_module(glmod)

botirc:connect()
botirc:login()
botirc:send_msg("JOIN " .. "#irpgc")
botirc:loop()

local automsg = nil



