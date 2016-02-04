require "wpa_supp"
xml = require('LuaXml')
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
	local xscene = xfile:find("part") 
	-- if this substatement is found... 
	if xscene ~= nil then 
	  -- ...print it to screen
	  print(xscene)
	  -- print attribute id and first substatement
	  
	  print("mytag: ", xscene:tag())
	  print("yourtag: ", xscene[2]:tag())
	  --#print("yourvalue: ", xscene[2]:text())
	  
	  print( xscene[1].icode, xscene[2])
	  -- set attribute id
	  xscene["id"] = "newId"
	end 
end

XML()
--]]

Salutations()
