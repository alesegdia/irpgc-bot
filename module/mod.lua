
Mod = {

  initialize = function(self)
    self.commands = {}
  end,

  loop = function( self, botirc )
	-- process all commands
	for _,cmd in pairs(self.commands) do
	  if util.contains_key(self.actions, cmd.cmd) then
	  	self.actions[cmd.cmd](botirc, cmd.nick, cmd.args)
      else
      	if self.actions["default"] then
      	  self.actions["default"](botirc, cmd.nick, cmd.cmd, cmd.args)
	    end
      end
	end
	for k,v in pairs(self.commands) do self.commands[k]=nil end
	self:modloop()
  end,

  notify = function( self, n, c, a )
  	local entry = { nick = n, cmd = c, args = a }
	table.insert( self.commands, entry)
  end,
}

