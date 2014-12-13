

local premios = {
  "a pizza", "a candy", "a hamburguer",
  "a night with Laci J. Mailey! http://www.cineol.net/galeria/fotos/laci-j-mailey_63371.jpg ",
  "a night with Jessy Schram! http://www.listal.com/viewimage/1608681h ",
  "a night with Sarah Carter! http://iv1.lisimg.com/image/350293/600full-sarah-carter.jpg "
}

local Base = {

  init = function(self)

  end,

  cleanup = function(self)
  	print("cleaning base")
  end,

  modloop = function(self)
  end,

  actions = {
	["google"] = function( botirc, nick, args )
	  if #args ~= 0 then
		local glgstr = ""
		for k,w in pairs(args) do
		  glgstr = glgstr .. w
		  if k ~= #args then glgstr = glgstr .. "+" end
		end
		botirc:say_chan("https://www.google.es/search?q=" .. glgstr)
	  end
	end,
  ["arcarajo"] = function( botirc, nick, args )
	botirc.exit = true
  end,
  ["automsg"] = function( botirc, nick, args )
	if botirc:isop(nick) then
	  local str = ""
	  for k,v in pairs(args) do
		str = str .. v .. " "
	  end
	  automsg = str
	end
  end,
  ["roll"] = function( botirc, nick, args )
	if botirc:isop(nick) then
	  local numpremio = math.random(#premios)
	  botirc:say_chan("Your prize is " .. premios[numpremio] .. "!")
	else
	  botirc:say_chan("Ohhh, your price is a kick!")
	  botirc:send_msg("KICK " .. botirc:getchannel() .. " " .. nick .. " :bad luck man, try next time D: ")
	end
  end
  }
}

BaseMod = class("BaseMod")
BaseMod:include(Mod)
BaseMod:include(Base)


return BaseMod()
