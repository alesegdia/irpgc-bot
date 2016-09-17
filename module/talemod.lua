
local json = require("dkjson")
local http = require("socket.http")
local xml = require("pl.xml")
local gumbo = require("gumbo")
pl = require 'pl.pretty'

local util = require("util")

local taledata = util.json2table( "taledata.json" )

local TheMod = {

  init = function(self)
  end,

  cleanup = function(self)
    util.table2json("taledata.json", taledata)
  end,

  modloop = function(self)
  end,

  actions = {
  ["forget"] = function( botirc, nick, args )
    if args and args[1] and taledata[args[1]] then
      taledata[args[1]] = nil
      botirc:say_chan("Done.")
    end
  end,
  
  ["default"] = function( botirc, nick, cmd, args )
    pl.dump(args)
    if args[1] then
      if args[1] == "is" then
        local line = cmd .. " "
        
        for k,v in pairs(args) do
          line = line .. v .. " "
        end
        taledata[cmd] = line
        
        botirc:say_chan("Got it!")
      end
    else
      local matches = string.match(cmd, "^[^%s]+?")
      if matches then
        pl.dump(matches)
        local word = string.sub(matches, 1, -2)
        if taledata[word] then
          botirc:say_chan(taledata[word] ..", " .. nick)
        else
          botirc:say_chan( "Dunno." )
        end
      end
    end
  end
  }
}

TaleMod = class("TaleMod")
TaleMod:include(Mod)
TaleMod:include(TheMod)


return TaleMod()
