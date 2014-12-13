
local util = require("util")
local botdata = util.json2table( "config.json" )

botdata.is_op = function(nick)
  return util.contains(botdata.ops, nick)
end

return botdata
