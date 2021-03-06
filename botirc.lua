
local socket = require("socket")
require('module.mod')

local botirc = {

  -- BASIC IRC FUNCTIONALITY -------------------------------
  -- irc server socket connection
  server = nil,
  exit = false,

  -- send message to irc server
  send_msg = function( self, msg )
  	self.server:send( msg .. "\r\n" )
  end,

  -- say message to connected channel
  say_chan = function( self, msg )
  	self:send_msg("PRIVMSG " .. botdata.channel .. " :" .. msg)
  end,

  -- connect to server
  connect = function( self )
  	print("connecting to " .. botdata.server)
	self.server = assert(socket.connect( botdata.server, 6667 ))
  	self.server:settimeout(0)
  end,

  -- login with proper nick and user
  login = function( self )
    self:send_msg("USER " .. botdata.login .. " 8 * :" .. botdata.name)
    self:send_msg("NICK " .. botdata.nick)
  end,

  notify_privmsg = function(msg)
    print(msg)
  end,
  
  notify_unformatted = function(msg)
    print(msg)
  end,

  -- IRC base layer
  do_irc = {
	["PING"] = function( self, src, channel, msg )
	  self:send_msg("PONG " .. channel)
	  self:send_msg("JOIN " .. botdata.channel)
	end,
	["PRIVMSG"] = function( self, src, channel, msg )
	  local nick = string.match(src, "(.*)!")
	  if channel == botdata.nick then
		print ("IGNORE: " .. nick .. ": " .. msg )
	  else
		self.notify_privmsg ("PRIVMSG: <" .. nick .. "> " .. msg )
		local command, _, args = string.match(msg, "([^ ]*)( ?)(.*)")
		if command ~= nil and args ~= nil then
		  for _,mod in pairs(self.modules) do
			mod:notify( nick, command, util.string_split(args) )
		  end
		end
		--if command ~= nil and args ~= nil and options[t] ~= nil then
		  --if util.contains_key(options, t) then
		  --  options[t]( nick, command, args )
		  --end
		--end
	  end
	end
  },

  isop = function( self, nick )
  	return botdata.is_op(nick)
  end,

  getchannel = function( self )
  	return botdata.channel
  end,

  step = function( self )
    if self.server then
	  local recv = self.server:receive()
	  if recv ~= nil then
		local comando = util.ircparse(recv)
		self.notify_unformatted("UNFORMATTED: " .. recv)
		local nick, msg = string.match(recv,"^:(.*)!.*(:.*)")
		if util.contains_key( self.do_irc, comando[1]) then
		  self.do_irc[comando[1] ]( self, comando[0], comando[2], comando[3] )
		end
	  end
	  for _,mod in pairs(self.modules) do
	  	mod:loop(self)
	  end

	  if self.exit then
	  	-- place in game mod cleanup
		--util.table2json("playersbak.dat", game.players)
	  	for _,mod in pairs(self.modules) do
	  	  mod:cleanup()
		end
		self:send_msg( "PART " .. botdata.channel .. " :xxa1drp" )
  end
  end
  end,

  -- main IRC loop
  loop = function( self )
    while not self.exit do
      self:step()
      os.execute("sleep 0.1")
    end
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
