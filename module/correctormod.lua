
local nick_table = {}

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
    
    local stype, old, new
    stype, old, new = string.match(util.trimlimitspaces(str), "^(%a)/(.*)/(.*)$")
    
    if stype then
      if stype == "s" then
        local correct_str = string.gsub(nick_table[nick], old, new, 1)
        botirc:say_chan(correct_str)
      elseif stype == "g" then
        local correct_str = string.gsub(nick_table[nick], old, new, 99)
        botirc:say_chan(correct_str)
      else
        botirc:say_chan("unknown replace command " .. stype)
      end
    else
      nick_table[nick] = str
    end
  end
  }
}

CorrectorMod = class("CorrectorMod")
CorrectorMod:include(Mod)
CorrectorMod:include(TheMod)


return CorrectorMod()
