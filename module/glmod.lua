
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
    pl.dump(args)
  	if args and args[1] then
      local fnarg = args[1]
      local versionarg = nil
      if args[2] then
        versionarg = args[2]
      end
      
  		local r, _, _ = http.request("http://docs.gl")
  		local web_data = gumbo.parse(r)
      
      local available_gl_versions = {}
      local glcommands = {}
      local commands_data = web_data:getElementsByClassName("indexcommand")
      
      for _,html_command in pairs(commands_data) do
        if type(html_command) == "table" and html_command.id then
          local glcmd = string.match(html_command.id, '^command_(.*)')
          local glversions = {}
          
          -- create glcommands entry
          glcommands[glcmd] = {
            name = glcmd,
            versions = {},
            versionshash = {}
          }

          for available_version in string.gmatch(string.match(html_command.className, '^indexcommand (.*)'), "%S+") do
            print(available_version)
            local av = string.sub(available_version, 1, -2)
            print(av)
            print("===")
            if not available_gl_versions[av] then
              available_gl_versions[av] = 1
            end
            if not glcommands[glcmd].versionshash[av] then
              table.insert(glcommands[glcmd].versions, av)
              glcommands[glcmd].versionshash[av] = true
            end
          end
        end
      end
      
      if glcommands[fnarg] then
        
        local versions_response = ""
        for k,v in pairs(glcommands[fnarg].versions) do
          versions_response = versions_response .. v .. " "
        end

        if versionarg then
          if glcommands[fnarg].versionshash[versionarg] then
            botirc:say_chan("docs.gl: http://docs.gl/" .. versionarg .. "/" .. glcommands[fnarg].name)
          else
            botirc:say_chan("Usage: !gl <command> <version>")
            botirc:say_chan("Version " .. versionarg .. " not found for command " .. glcommands[fnarg].name .. ".")
            botirc:say_chan("Available versions for " .. glcommands[fnarg].name .. ": " .. versions_response)
          end
        else
          botirc:say_chan("Usage: !gl <command> <version>")
          botirc:say_chan("Available versions for " .. glcommands[fnarg].name .. ": " .. versions_response)
        end
        
      else
        botirc:say_chan("Unknown command " .. fnarg .. ".")
      end
		else
      botirc:say_chan("Usage: !gl <command> <version>")
    end
  end,
  
  ["default"] = function( botirc, nick, cmd, args )
  end
  }
}

GLMod = class("GLMod")
GLMod:include(Mod)
GLMod:include(TheMod)


return GLMod()
