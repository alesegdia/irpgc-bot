
local botdata = require("botdata")
local socket = require("socket")

local botirc = {

  -- BASIC IRC FUNCTIONALITY -------------------------------
  -- irc server socket connection
  server = nil,

  -- send message to irc server
  send_msg = function( self, msg )
  	self.server:send( msg .. "\r\n" )
  end,

  -- say message to connected channel
  say_chan = function( self, msg )
  	self:send_msg("PRIVMSG " .. botdata.channel .. " :" .. msg)
  end,

  receive = function(self)
	recv = self.server:receive()
	return recv
  end,

  -- connect to server
  connect = function( self )
  	print("connecting")
  	print(self.server)
	self.server = assert(socket.connect( botdata.server, 6667 ))
  	print(self.server)
  end,

  -- login with proper nick and user
  login = function( self )
	print("hago el nick")
	self:send_msg("NICK " .. botdata.nick)
	print("hago el user")
	self:send_msg("USER " .. botdata.login .. " 8 * :" .. botdata.name)
  end,

  -- MODULE HANDLING --------------------------------------
  -- running modules
  modules = {},

  -- add a module
  add_module = function(self, mod)
  	mod:init()
	table.insert( self.modules, mod )
  end
}


return botirc
