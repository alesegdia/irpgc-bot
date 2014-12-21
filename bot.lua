
class = require("lib.middleclass.middleclass")
util = require("util")
pl = require 'pl.pretty'
botdata = require("botdata")

local botirc = require("botirc")

botirc:connect()
botirc:login()

local basemod = require("module.misc")
botirc:add_module(basemod)

botirc:send_msg("JOIN " .. botdata.channel)
botirc:loop()

local automsg = nil



