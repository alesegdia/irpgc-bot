class = require("lib.middleclass.middleclass")
util = require("util")
pl = require 'pl.pretty'
botdata = require("botdata")

local botirc = require("botirc")

local basemod = require("module.misc")
local glmod = require("module.glmod")
local talemod = require("module.talemod")
local rimasmod = require("module.rimasmod")

botirc:add_module(basemod)
botirc:add_module(glmod)
botirc:add_module(talemod)
botirc:add_module(rimasmod)



local fl = require( "fltk4lua" )
fl.scheme( "gtk+" )

local win = fl.Window( 500, 500, "BotGUI" )

local pack = fl.Pack{ 5, 5, 490, 490, box="FL_DOWN_FRAME" }
local connect_button = fl.Button{ 5, 5, 90, 25, "Connect", callback= function ()
    botirc:connect()
    botirc:login()
    botirc:send_msg("JOIN " .. botdata.channel)
  end}

connect_button.color = 92

local label = fl.Browser(100, 10, 380, 200)
label.type = "FL_MULTI_BROWSER"
label:add("This is a very large message to test the feature that we want to test, because if the paragraph is too short, we won't see the effect.")


pack:end_group()

win.resizable = pack

win:end_group()
win:show( arg )



local f0, f1, delta, accum, period
period = 0.1
accum = 0
f0 = os.clock()
f1 = f0
delta = 0

while not botirc.exit do
  f1 = os.clock()
  delta = f1 - f0
  accum = accum + delta
  f0 = f1
  if accum >= period then
    botirc:step()
    accum = accum - period
  end
  fl.check()
end
