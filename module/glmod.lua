
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
  ["!gl"] = function( botirc, nick, args )
  	if args then
  		local r, c, h = http.request("http://docs.gl")
  		local data = gumbo.parse(r)
		local versions = data:getElementById("version-select")
		local glvers = {}
  		for k,v in pairs(versions.childNodes) do
  		  if v["attributes"] then
  		  	  table.insert(glvers, v["attributes"][1]["value"])
		  end
		end

		local availhash = {}
		local availglvers = "Available GL versions: "
		for k,v in pairs(glvers) do
			availglvers = availglvers .. " " .. v
			availhash[v] = true
		end


		botirc:say_chan(availglvers)
		botirc:say_chan(args[1])

		local elemclas = data:getElementsByClassName("indexcommand")
		
		for k,v in pairs(elemclas) do
			print(k)
			print(string.match(v.id, '^command_(.*)'))
			print(v.className)
		end
		print(elemclas[1].childNodes[1])
	end
  end,
  ["default"] = function( botirc, nick, args )
  end
  }
}

GLMod = class("GLMod")
GLMod:include(Mod)
GLMod:include(TheMod)


return GLMod()
