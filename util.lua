
local json = require("dkjson")

local util = {

  json2table = function( path )
	local f = io.open(path,"r")
	local tbl = json.decode(f:read("*all"))
	f:close()
	return tbl
  end,

  table2json = function( path, tbl )
	local f,err = io.open(path, "w+")
	if not f then return print(err) end
	f:write(json.encode(tbl))
	f:close()
	return true
  end,

  -- thanks to mniip on #lua@freenode.net
  ircparse = function( s )
	local command, source
	if s:sub(1, 1) == ":" then
	  source, command = s:match"^:([^ ]*)(.*)"
	else
	  command = " " .. s
	end
	local t = {}
	local n = 1
	for pos, word in command:gmatch" ()([^ ]*)" do
	  if word:sub(1, 1) == ":" then
		t[n] = command:sub(pos + 1)
		break
	  end
	  t[n] = word
	  n = n + 1
	end
	t[0] = source
	return t
  end,

  contains = function (table, element)
	for k,v in pairs(table) do
	  if v == element then
		return true
	  end
	end
	return false
  end,

  contains_key = function (table, key)
	for k,v in pairs(table) do
	  if k == key then
		return true
	  end
	end
	return false
  end

}

return util
