--[[
t = {command="first"}
--t["value_1"] = "value1"

print("Command", type(t.command), t.command)
print("value 1", type(t["value_1"]), t["value_1"])

--Why does this test always evaluate to NOT NIL even if the previous statement shows it as nil?
if type(t["value_1"]) ~= "nil" then print("it's not nil") end

print("value 1", type(t["value_1"]), t["value_1"])

--]]

message = "This is a test of MD5"

local md5 = require 'md5'

local md5_as_hex   = md5.sumhexa(message)   -- returns a hex string

--print (md5_as_hex)

local CRC = require 'digest.crc32lua'
--print(CRC.crc32 'test') --> 0xD87F7E0C or -662733300



t={}

for i,v in string.gmatch([[/usr/local/ugent/ugent.udpate.xml]], "(.-)([^//]-([^%.]+))$") do
--	t[i]=v
--print(i,v)
end

t = string.gmatch([[/usr/local/ugent/ugent.udpate.xml]], "(.-)([^//]-([^%.]+))$")


--print(t)
--print(type(t))

--serialize = require("ser")
--print(serialize(t))

--return string.match([[/usr/local/ugent/ugent.udpate.xml]], "(.-)([^//]-([^%.]+))$")

your_string = [[/usr/local/ugent/ugent.udpate.xml]]

wind_string = [[c:\my\windows\file.txt]]



function GetFileName(url)
 --return url:match "([^/]-([^.]+))$"
--return url:match "([^/]-([^.]+))$"
  i = url:find("/")
  if i == nil then
	return url:match("^.+\\(.+)$")
  else
	return url:match("^.+/(.+)$")
  end
end

function GetFileExtension(url)
  --return url:match("^.+(%..+)$")
  ext = url:match "[^.]+$"
  if #ext==#url then return nil else return ext end  
end

print(GetFileName(your_string))
print(GetFileName(wind_string))

print( GetFileExtension(GetFileName(your_string)))