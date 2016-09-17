
class = require("lib.middleclass.middleclass")
util = require("util")
pl = require 'pl.pretty'
botdata = require("botdata")

local botirc = require("botirc")

local basemod = require("module.misc")
local glmod = require("module.glmod")
local talemod = require("module.talemod")

botirc:add_module(basemod)
botirc:add_module(glmod)
botirc:add_module(talemod)

botirc:connect()
botirc:login()
botirc:send_msg("JOIN " .. botdata.channel)
botirc:loop()

local automsg = nil



