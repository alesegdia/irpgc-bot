
local TheMod = {

	init = function(self)

	end,

	cleanup = function(self)
		print("cleaning game")
	end,

	modloop = function(self)
		self:handleturn()
	end,

	handleturn = function(self)
		-- if some player turn,
		-- 		check movement from that player in player_moves queue
	end,

	actions = {
		["attack"] = function( botirc, nick, args )

		end
	}
}

RPGameMod = class("RPGameMod")
RPGameMod:include(Mod)
RPGameMod:include(TheMod)

return RPGameMod()
