require "wpa_supp"
xml = require('LuaXml')
-- wpa_supp = require("wpa_supp") --RH, can't make this work either!!!
serialize = require("ser")
file = require("file")

EmptyFileName = "./ugent.empty.xml"
BaseFileName = "./ugent.xml"
UpdateFileName = "./ugent.update.xml"


function import()

	
	
	
  -- The key exists in the table.
	
	if #arg < 3 then 
		print("Not enough arguments. See Help")
		print("imports a configuration file and sets the check value. If base, the file is ugent.xml, then overrides the current file and clears the update file. If update then the file is ugent.update.xml then the base file is untouched and the update file is overwritten.")
		return
	end
	
	if type(parameters["value_2"]) ~= "nil" then
			if string.upper(parameters["value_2"]) ==  "BASE" then
				dest = "ugent.xml"
			elseif string.upper(parameters["value_2"]) ==  "UPDATE" then
				dest = "ugent.update.xml"
			end
	
		file.copy(parameters["value_3"], dest)
	else
		print("it's nil")
	end
	
	
	
end



function configure()
	print("re-creates the configuration file for the services specified.")
end

function set()
	print("imports a string or changes an existing string in the update file ")
end

function state()
	if string.upper(parameters.value_2) == "REVERT" then
		print("found revert")
	elseif string.upper(parameters.value_2) == "UPDATE" then
		print("found update")
	else
		print("sets ugent to restart services using the settings for the base file or use/renew the setting from the base + update file (changes a setting in sysserv). This command causes a restart of the system through a socket call to sysserv ")
	end
end 

function help()
	if #arg > 1 then
		if arg[2] == "-c" then
			print "changelog"
		end
	else
		local f = assert(io.open("README.md", "r"))
		local t = f:read("*all")
		print(t)
		f:close()
	end
end

function Salutations()
	io.write("Hello There\n")
	--wpa_supp:generate()
	generate()
	print("arg1",arg[1])
	print("")
end



function LoadXml()
	
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



--Parse the Arguments from the command line:
function PrintNames()
	names = {'John', 'Joe', 'Steve'}
	for i, name in ipairs(names) do
	  print (name)
	end
end

--UgentFunctions = {HELP = help, IMPORT = import, CONFIGURE = configure, SET = set, STATE = state, SAL = Salutations, XML = LoadXml, NAMES = PrintNames}

if #arg < 1 then print("You must provide arguments to continue") return end

parameters = {}

function ParseCommandLine()
	SkipNext = false
	--Parse the command line
	for i,v in ipairs(arg) do

		
		--Get our command
		if i == 1 then 
			table.insert(parameters,command) 
			parameters.command = v  
		else		
			if SkipNext ~= true then		
				--check for option flag
				if string.sub(v,1,1) == "-" then 
	--				print("found", v)  
					
					p = string.sub(v,2)
					
					-- are there more arguments? could be a option value
					if #arg >= i+1 then 
						pnext = arg[i+1]		
						--No dash means it's an option value. RH THIS IS WRONG, COULD BE LAST VALUE. NEEDS MORE LOGIC
						if string.sub(pnext,1,1) ~= "-" then 
							parameters[p] = pnext
							SkipNext = true						
	--						print("Next:",pnext)
	--						print(SkipNext)
							goto continue
						end
					end
				else
					--print(i,v)
					valLabel = "value_"..i				
					parameters[valLabel] = v
				end	
			end
			SkipNext = false
			::continue::
		end
	end

	print("Paramenter Count",#parameters)
	print(serialize(parameters))
	print("Command to execute:", parameters.command)
end

ParseCommandLine()
_G[string.lower (parameters.command)]()



