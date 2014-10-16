
local socket = require("socket")
local server = assert(socket.connect("irc.freenode.net", 8001))
local json = require("dkjson")

local f = io.open("config.cfg","r")
local botdata = json.decode(f:read("*all"))

local send_msg = function( msg )
  server:send(msg .. "\r\n")
end

local string_split = function( str, sep )
  sep = sep or "%S+"
  words = {}
  for word in str:gmatch(sep) do
  	table.insert(words, word)
  end
  return words
end


print("hago el nick")
send_msg("NICK " .. botdata.nick)
print("hago el user")
send_msg("USER " .. botdata.login .. " 8 * :" .. botdata.name)
--local recv = server:receive()
--server:send("PONG\r\n")

local saychan = function( msg )
  send_msg("PRIVMSG " .. botdata.channel .. " :" .. msg)
end


local salir = false
local premios = {
  "a pizza", "a candy",
  "a night with Laci J. Mailey! http://www.cineol.net/galeria/fotos/laci-j-mailey_63371.jpg ",
  "a night with Jessy Schram! http://www.listal.com/viewimage/1608681h ",
  "a night with Sarah Carter! http://iv1.lisimg.com/image/350293/600full-sarah-carter.jpg "
}

local do_cmd = function( nick, command, args )
  if command == "google" then
	local glgstr = ""
	for k,w in pairs(args) do
	  glgstr = glgstr .. w
	  if k ~= #args then glgstr = glgstr .. "+" end
	end
	saychan("https://www.google.es/search?q=" .. glgstr)
  elseif command == "arcarajo" then
	salir = true
  elseif command == "roll" then
  	if nick == "rx9" or nick == "razieliyo" then
  	  local numpremio = math.random(#premios)
  	  saychan("Your prize is " .. premios[numpremio] .. "!")
	else
	  saychan("Ohhh, your price is a kick!")
	  send_msg("KICK " .. botdata.channel .. " " .. nick .. " :bad luck man, try next time D: ")
	end
  end
  args = args or {}
  for k,w in pairs(args) do
  	print ("ARG"..k..": "..w)
  end
end

local contains = function (table, element)
  for k,v in pairs(table) do
	if v == element then
	  return true
	end
  end
  return false
end

local tablelength = function(T)
  local count = 0
  for _ in pairs(T) do count = count + 1 end
  return count
end

local is_op = function(nick)
  return nick == "rx9"
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
	saychan(nick .. "'s soul rises to heaven.")
	-- elmina a nick
  end,

  damage = function(self, player, amount)
	player.hp = player.hp - amount
	if player.hp <= 0 then self:player_died(player.player) end
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

  states = {

  	-- Still no games!
	["none"] = {
	  cmd_valid = {
	  	"start"
	  },
	  ["start"] = function( g, nick, args )
		saychan("GET READY TO PLAY IRPGC!! Awaiting registrations...")
		local f = io.open("playersbak.dat","r")
		g.players = json.decode(f:read("*all"))
		g:next_state( "start" )
	  end
	},

	-- Accepting players
	["start"] = {
	  cmd_valid = {
		"register", "begin"
	  },
	  ["register"] = function( g, nick, args )
	  	if not contains( g.players_all, nick ) then
		  if g.players[nick] == nil  then
			local newplayer = g:create_player( nick )
			saychan(nick .. " registered! all applause ".. nick .. " for his/her first time playing iRPGc!")
		  else
			g.players[nick].times_played = g.players[nick].times_played + 1
			saychan(nick .. " registered! " .. nick .. " with " .. g.players[nick].times_played .. " times played in total.")
		  end
		  --table.insert( g.players, nick )
		  table.insert(g.players_all, nick)
		end
	  end,
	  ["begin"] = function( g, nick, args )
		saychan("Game starts... NOW!")
		g:next_state( "playing", true, "prebattle", g, nick, 1 )
	  end
	},

	-- Playing the game
	["playing"] = {
	  cmd_valid = {
		"prebattle", "attack"
	  },
	  -- Select enemies and skill for this battle
	  ["prebattle"] = function( g, nick, skill )
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
			g.damage(g,tatocao,self.atk + math.random(5))
			saychan("Orco: take this, bastard! (" .. tatocao.nick .. "'s health downs to " .. tatocao.hp .. " HP)")
		  end
		}

		g:add_turns()
		print("num turnos: " .. #g.turns )
		for k,v in pairs(g.turns) do
		  print (v)
		end

		g:advance_turn()
		saychan("A wild orc with " .. g.enemy.hp .. " HP appears.")
	  end,
	  ["attack"] = function( g, nick )
	  	g.endturn = false
	  	if( g:player_exists(nick) and g.turn == nick ) then
		  g.enemy.hp = g.enemy.hp - (g.players[nick].atk + math.random(1,2))
		  saychan(nick .. " attacks the ork (ork's health downs to " .. g.enemy.hp .. " HP.")
		  g.endturn = true
		end
	  end
	}
  },

  advance_turn = function(self)
	table.remove(self.turns)
	self.turn = self.turns[#self.turns]
	saychan("===================================")
	saychan("Turno de " .. self.turn)
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
	  self:advance_turn()
	end
  end,

  step = function( self, nick, command, args )
  	if is_op(nick) and command == "reset" then
  	  self.currentState = "none"
  	  for k,v in pairs(self.players_all) do
		self.players_all[k] = nil
	  end
	elseif contains(self.states[self.currentState].cmd_valid, command) then
	  self.states[self.currentState][command]( self, nick, args )
	end
	if self.currentState == "playing" and self.endturn then
	  print(self.turn)
	  self:post_step()
	end
  	--[[
	if self.state == "none" then
	  if command == "start" then
	  	saychan("PREPARAOS PARA JUGAR A IRPGC!! Esperando registros...")
	  	self.state = "registering"
	  end
	end
	]]--
  end,

  currentState = "none",
  players = {}
}


send_msg("JOIN " .. botdata.channel)
while not salir do
  local recv = server:receive()
  print("UNFORMATTED: " .. recv)
  local nick, msg = string.match(recv,"^:(.*)!.*:(.*)")

  if string.find(recv,"PING") then
  	print("PONG!")
  	send_msg("PONG")
  elseif string.find(recv,"JOIN") then
	send_msg("PRIVMSG ChanServ op " .. botdata.channel .. " " .. botdata.nick)
	print("PRIVMSG ChanServ op " .. botdata.channel .. " " .. botdata.nick)
	print("OP OP OP OP")
  elseif nick ~= nil and msg ~= nil then
	print ("SOMEONE: " .. nick .. ": " .. msg )
	local command, args = string.match(msg, "!([^ ]*) (.*)")
	if args == nil then
	  command, args = string.match(msg, "!([^ ]*)")
	end
	if command ~= nil then
	  --print("COMMAND: " .. command) print("ARGS" .. args)
	  if args ~= nil then do_cmd( nick, command, string_split(args) )
	  else do_cmd( nick, command ) end
	else
	  print("aver..")
	  local command, args = string.match(msg, "@([^ ]*)")
	  if command ~= nil then
	  	print("GAME!")
	  	if args == nil then game:step( nick, command )
		else game:step( nick, command, string_split(args) ) end
	  end
	end
  end
  if salir then
	local f,err = io.open("playersbak.dat", "w+")
	if not f then return print(err) end
	f:write(json.encode(game.players))
	f:close()
  	send_msg("PART " .. botdata.channel .. " :que os follen, hijos de puta")
  end
  print("\n")
end
