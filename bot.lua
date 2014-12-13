

local util = require("util")
local botirc = require("botirc")
require("entities")
local botdata = require("botdata")


local string_split = function( str, sep )
  sep = sep or "%S+"
  words = {}
  for word in str:gmatch(sep) do
	table.insert(words, word)
  end
  return words
end

botirc:connect()
botirc:login()



local salir = false

local premios = {
  "a pizza", "a candy", "a hamburguer",
  "a night with Laci J. Mailey! http://www.cineol.net/galeria/fotos/laci-j-mailey_63371.jpg ",
  "a night with Jessy Schram! http://www.listal.com/viewimage/1608681h ",
  "a night with Sarah Carter! http://iv1.lisimg.com/image/350293/600full-sarah-carter.jpg "
}

local automsg = nil

local do_cmd =
{
  ["google"] = function( nick, args )
	if #args ~= 0 then
	  local glgstr = ""
	  for k,w in pairs(args) do
		glgstr = glgstr .. w
		if k ~= #args then glgstr = glgstr .. "+" end
	  end
	  botirc:say_chan("https://www.google.es/search?q=" .. glgstr)
	end
  end,
  ["arcarajo"] = function( nick, command, args )
	salir = true
  end,
  ["automsg"] = function( nick, args )
	if botdata.is_op(nick) then
	  local str = ""
	  for k,v in pairs(args) do
		str = str .. v .. " "
	  end
	  automsg = str
	end
  end,
  ["roll"] = function( nick, args )
	if botdata.is_op(nick) then
	  local numpremio = math.random(#premios)
	  botirc:say_chan("Your prize is " .. premios[numpremio] .. "!")
	else
	  botirc:say_chan("Ohhh, your price is a kick!")
	  botirc:send_msg("KICK " .. botdata.channel .. " " .. nick .. " :bad luck man, try next time D: ")
	end
  end
}

do_cmd.mt = {}
setmetatable(do_cmd, do_cmd.mt)

do_cmd.mt.__index = function( nick, args ) print "METATABLE!" end



local tablelength = function(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end


local game = {

  -- DATA
  players = {},
  players_all = {},

  -- GAME STATES
  next_state = function( g, state, force, command, args )
	force = force or false
	g.currentState = state
	if force then g.states[state][command](g, "god", args) end
  end,

  player_died = function( g, nick )
	botirc:say_chan(nick .. "'s soul rises to heaven.")
	local todel = {}
	for k,v in pairs(g.players_all) do
	  if v == nick then
		todel = k
	  end
	end
	table.remove(g.players_all,todel)

	todel = {}
	while todel ~= nil do
	  todel = nil
	  for k,v in pairs(g.turns) do
		if v == nick then todel = k break end
	  end
	  table.remove(g.turns,todel)
	end

	if #g.players_all < 1 then
  	  g.currentState = "none"
  	  for k,v in pairs(g.players_all) do
		g.players_all[k] = nil
	  end
	  botirc:say_chan("All died and nobody ever knew about them.")
	  g.turns = {}
	end

  end,

  damage = function(self, player, amount)
	player.hp = player.hp - amount
	if player.hp <= 0 then self:player_died(player.nick) end
  end,

  create_player = function( g, nick )
  	local p = g.players[nick] or false
  	if p == false then
	  g.players[nick] = {
		hp = 100,
		atk = 2,
		nick = nick,
		times_played = 0
	  }
	end
  end,

  enemy = nil,
  endturn = false,

  player_exists = function( g, player_name )
  	local var = g.players[player_name] or nil
  	if var == nil then return false end
  	return true
  end,

  turns = {},
  turn = "DEBUG_TURNO",
  reset = function(player)
	player.hp = 100
  end,

  states = {

  	-- Still no games!
	["none"] = {
	  cmd_valid = {
	  	"start"
	  },
	  ["start"] = function( g, nick, args )
		botirc:say_chan("GET READY TO PLAY IRPGC!! Awaiting registrations...")
		g.players = util.json2table("playersbak.dat")
		g:next_state( "start" )
	  end
	},

	-- Accepting players
	["start"] = {
	  cmd_valid = {
		"register", "begin"
	  },
	  ["register"] = function( g, nick, args )
	  	if not util.contains( g.players_all, nick ) then
		  if g.players[nick] == nil  then
			local newplayer = g:create_player( nick )
			botirc:say_chan(nick .. " registered! all applause ".. nick .. " for his/her first time fight iRPGc!")
		  else
			g.players[nick].times_played = g.players[nick].times_played + 1
			botirc:say_chan(nick .. " registered! " .. nick .. " with " .. g.players[nick].times_played .. " times played in total.")
		  end
		  --table.insert( g.players, nick )
		  table.insert(g.players_all, nick)
		  g.players[nick].hp = 100
		  g.reset(g.players[nick])
		end
	  end,
	  ["begin"] = function( g, nick, args )
	  	if #g.players_all > 0 then
		  botirc:say_chan("Game starts... NOW!")
		  g:next_state( "fight", true, "init", g, nick, 1 )
		end
	  end
	},

	-- Playing the game
	["fight"] = {
	  cmd_valid = {
		"init", "attack"
	  },
	  -- Select enemies and skill for this battle
	  ["init"] = function( g, nick, skill )
		g.enemy = {
		  hp = 100,
		  atk = 10,
		  turn = function( self, players )
			local numpl = math.random(tablelength(g.players_all))
			local tatocao
			for k,v in pairs(g.players_all) do
			  if numpl == 1 then tatocao = g.players[v]  end
			  numpl = numpl - 1
			end
			local deal = self.atk + math.random(5)
			local newhp = tatocao.hp - deal
			if newhp < 0 then newhp = 0 end
			botirc:say_chan("Orco: take this, bastard! (" .. tatocao.nick .. "'s health downs to " .. newhp .. " HP)")
			g:damage(tatocao,deal)
		  end
		}

		g:add_turns()
		print("num turnos: " .. #g.turns )
		for k,v in pairs(g.turns) do
		  print (v)
		end

		g:advance_turn()
		botirc:say_chan("A wild orc with " .. g.enemy.hp .. " HP appears.")
	  end,
	  ["attack"] = function( g, nick )
	  	if( g:player_exists(nick) and g.turn == nick ) then
		  g.enemy.hp = g.enemy.hp - (g.players[nick].atk + math.random(1,2))
		  botirc:say_chan(nick .. " attacks the ork (ork's health downs to " .. g.enemy.hp .. " HP.")
		  if g.enemy.hp <= 0 then

			botirc:say_chan(" Yeah! You defeated the enemy party! https://www.youtube.com/watch?v=8T_8xBUDHXs ")
			g.currentState = "none"
			g.players_all = {}
			g.turns = {}
		  end
		  g.endturn = true
		end
	  end
	}
  },

  advance_turn = function(self)
	table.remove(self.turns)
	self.turn = self.turns[#self.turns]
	botirc:say_chan("[" .. self.turn .. "'S TURN]")
  end,

  add_turns = function(self)
  	if self.turns == nil then self.turns = {} end
  	for i=1,3 do
	  for _,nick in pairs(self.players_all) do
		table.insert(self.turns, nick)
	  end
	  table.insert(self.turns, "orco")
	end
  end,

  post_step = function(self)
	self.turn = self.turns[#self.turns]
	if #self.turns < 10 then
	  self:add_turns()
	end
	self:advance_turn()
	if self.turn == "orco" then
	  self.enemy.turn( self.enemy, self.players )
	  if self.currentState == "fight" then self:advance_turn() end
	end
  end,

  step = function( self, nick, command, args )
	self.endturn = false
  	if botdata.is_op(nick) and command == "reset" then
  	  self.currentState = "none"
  	  self.players_all = {}
  	  self.turns = {}
  	  --[[
  	  for k,v in pairs(self.players_all) do
		self.players_all[k] = nil
	  end
	  --]]
	elseif command == "playerlist" then
	  if self.currentState == "fight" then
		str = "Players playing: "
		local i = 1
		for _,v in pairs(self.players_all) do
		  str = str .. v
		  if i ~= #self.players_all then str = str .. ", " end
		end
		botirc:say_chan(str)
	  end
	elseif util.contains(self.states[self.currentState].cmd_valid, command) then
	  self.states[self.currentState][command]( self, nick, args )
	end
	if self.currentState == "fight" and self.endturn then
	  print(self.turn)
	  self:post_step()
	end
  end,

  currentState = "none",
  players = {}
}
--require("rpgame")

local options = {
  valid = "!@",
  ["!"] = function( nick, command, args )
  	if util.contains_key(do_cmd, command) then
	if args ~= "" then
	  print("asd")
	  do_cmd[command](nick, string_split(args))
	else
	  print("qwe")
	  do_cmd[command](nick)
	end
  end
  end,
  ["@"] = function( nick, command, args )
	game:step( nick, command, string_split(args))
  end,
  ["invalid"] = function( nick, cmd, args ) end
}


local do_irc = {
  ["PING"] = function( src, channel, msg )
	print("PONG!")
	botirc:send_msg("PONG")
  end,
  ["PRIVMSG"] = function( src, channel, msg )
	local nick = string.match(src, "(.*)!")
	print ("SOMEONE: " .. nick .. ": " .. msg )
	local t, command, _, args = string.match(msg, "(["..options.valid.."])([^ ]*)( ?)(.*)")
	--if command ~= nil and args ~= nil and options[t] ~= nil then
	  if util.contains_key(options, t) then
		options[t]( nick, command, args )
	  end
	--end
  end
}


botirc:send_msg("JOIN " .. botdata.channel)
while not salir do
  local recv = botirc.server:receive()

  if recv ~= nil then
	local comando = util.ircparse(recv)
	print("UNFORMATTED: " .. recv)
	local nick, msg = string.match(recv,"^:(.*)!.*(:.*)")
	if util.contains_key( do_irc, comando[1]) then
	  do_irc[comando[1]]( comando[0], comando[2], comando[3] )
	end
	if salir then
	  util.table2json("playersbak.dat", game.players)
	  botirc:send_msg( "PART " .. botdata.channel .. " :ggbb" )
	end
	print("\n")
  end
end

