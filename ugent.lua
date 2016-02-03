require "wpa_supp"
require "LuaXml" 
-- wpa_supp = require("wpa_supp") --RH, can't make this work either!!!

-- import the LuaXML module as xml


function Salutations()
	io.write("Hello There\n")
	--wpa_supp:generate()
	generate()
	print("")
end

---[[
--RH - This is the block that doesn't work
function XML()
	
	-- load XML data from file "test.xml" into local table xfile 
	local xfile = xml.load("comp-parts.xml") 
	-- search for substatement having the tag "scene" 
	local xscene = xfile:find("parts") 
	-- if this substatement is found... 
	if xscene ~= nil then 
	  -- ...print it to screen
	  print(xscene)
	  -- print attribute id and first substatement
	  print( xscene.id, xscene[1] )
	  -- set attribute id
	  xscene["id"] = "newId"
	end 
end

XML()
--]]

Salutations()
