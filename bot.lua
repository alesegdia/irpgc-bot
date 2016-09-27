
class = require("lib.middleclass.middleclass")
util = require("util")
pl = require 'pl.pretty'
botdata = require("botdata")

local botirc = require("botirc")
botirc:add_module(require("module.misc"))
botirc:add_module(require("module.glmod"))
botirc:add_module(require("module.talemod"))
botirc:add_module(require("module.rimasmod"))
botirc:add_module(require("module.correctormod"))

botirc:connect()
botirc:login()
botirc:send_msg("JOIN " .. botdata.channel)
botirc:loop()

local automsg = nil



