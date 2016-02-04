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

print (md5_as_hex)