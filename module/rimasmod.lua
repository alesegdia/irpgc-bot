
local json = require("dkjson")
local http = require("socket.http")
local xml = require("pl.xml")
local gumbo = require("gumbo")
pl = require 'pl.pretty'

local TheMod = {

  init = function(self)
  end,

  cleanup = function(self)
  	print("cleaning base")
  end,

  modloop = function(self)
  end,

  actions = {
  ["default"] = function( botirc, nick, cmd, args )
    local str = cmd .. " "
    for k,v in pairs(args) do
      str = str .. v .. " "
    end
    
    local rimas = {
      ["^.*inco[%s%?]*$"] = "po por er culo te la jinco!",
      ["^.*ote[%s%?]*$"] = "po me trinca tor pijote!",
      ["^.*eve[%s%?]*$"] = "po me la agarra y me la mueve!",
      ["^.*atos*[%s%?]*$"] = "po agarramela un rato!",
      ["^.*on[%s%?]*$"] = "po agarrame el cojon!",
      
    }
    
    for k,v in pairs(rimas) do
      if string.match(str, k) ~= nil then
        botirc:say_chan(nick .. ", " .. v)
      end
    end

  end
  }
}

RimasMod = class("RimasMod")
RimasMod:include(Mod)
RimasMod:include(TheMod)


return RimasMod()
