
class = require("lib.middleclass.middleclass")
util = require("util")
pl = require 'pl.pretty'
botdata = require("botdata")

local botirc = require("botirc")

local basemod = require("module.misc")
botirc:add_module(basemod)

botirc:connect()
botirc:login()
botirc:send_msg("JOIN " .. "#irpgc")
botirc:loop()

local automsg = nil



