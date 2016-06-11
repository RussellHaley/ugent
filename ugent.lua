require "wpa_supp"
xml = require('LuaXml')
-- wpa_supp = require("wpa_supp") --RH, can't make this work either!!!
serialize = require("ser")
file = require("file")

--[[
EmptyFileName = "../etc/ugent/ugent.empty.xml"
BaseFileName = "../etc/ugent/ugent.xml"
UpdateFileName = "../etc/ugent/ugent.update.xml"
--]]


HashExtension = ".hash"
XmlExtension = ".xml"
TempExtension = ".tmp"
ConfExtension = ".conf"

BaseDir = "./"
AppName = "ugent"
ConfFileName = BaseDir..AppName..ConfExtension

BaseFileName = BaseDir..AppName
UpdateFileName = BaseDir..AppName..".update"
EmptyFileName = BaseDir..AppName..".empty"

VERSION = 0.2

--[[
Imports the file into the ugent system. 
If base is specified, then the base file is modified 
If update is specified, the update file is  modified
Parameters: BASE|UPDATE <source-filename>

RH - Need to fix this to handle Own file name commands.
--]]
function import()

--[[
1 - check for args
2 - is it base or update?
3 - rename old files (xml,hash)
4 - create new file
4 - create new file (xml,hash)
5 - if base, remove any update file
6 - remove old files
--]]
	
	if #arg < 3 then 
		print("Not enough arguments. See Help")
		return
	end
	
	
	if type(parameters["value_2"]) ~= "nil" then
		if string.upper(parameters["value_2"]) ==  "BASE" then
			dest = BaseFileName..XmlExtension
			hash = BaseFileName..HashExtension
		elseif string.upper(parameters["value_2"]) ==  "UPDATE" then
			dest = UpdateFileName..XmlExtension
			hash = UpdateFileName..HashExtension
		else
			print("Incorrect import directive. See Help.")
			return
		end
		
	
		print("Creating tmp files")
		file.move(dest,dest..TempExtension)
		file.move(hash,hash..TempExtension)
		
		file.copy(parameters["value_3"], dest)
		file.createhashfile(dest,hash)
		print("Done. Removing Temp Files")
		file.remove(dest..TempExtension)
		file.remove(hash..TempExtension)		
		print("Created", dest, "from", parameters["value_3"], "With a hash of", file.getmd5Hex(dest), "at".. os.date("%c", file.getlastmodified(dest)))
		
	else
		print("No source file was included. See help")
		return 
	end	
	
end

--[[
Search the conf file for a key and check if it's true or not.
RH - This will need to be improved to allow for other values
--]]
function GetValuesFromConf(file)
  --if not file_exists(file) then return {} end
  kvps = {}
  for line in io.lines(file) do 
    eqIndex = string.find(line,"=")
    if eqIndex == 0 then
      kvps[line]=true
    else
      kvps[line:sub(0,eqIndex - 1)]=line:sub(eqIndex+1)
      --Need to test the value for Qoutes (Should they be removed?)
      -- Need to test the value for yes/ok/true and no/notokay/false
    end 
  end
  return kvps
end


--[[
Writes values to the applications internal conf file. 
RH - This has a bug. If there is no final \\n then the 
Parsing doesn't always work. Need to improve the matching.
--]]
function SetConf(item,value)
--Read in the file and look for the "Item value	
  conf=file.read(ConfFileName)		
  i,j = conf:find(item)
  if i then --if item is found   
    --replace item=<anything> with item=value
      -- THIS SUBSTITUTION DOESN"T WORK PROPERLY IT ONLY FINDS LINEFEED not the end of string
    conf = conf:gsub(item.."=.-[%\n|$]",item.."="..value.."\n")	  	  
  else --item wasn't found 
	  if conf:sub(#conf, 1) == "\n" then 
	      conf = conf..item.."="..value
	  else	
	      conf = conf.."\n"..item.."="..value
	  end
  end
  print(conf)
  file.write(ConfFileName,conf)
end

function set()
	item = arg[2]:upper()
	enabled = arg[3]:upper()
	
	--print(item,enabled)
	SetConf(item,enabled)
end


--[[
Configure creates is used to either UPDATE or REVERT configuration files.
--]]
function configure()
  --[[
  - Check command line parameters for a list of files to generate
  - Check the configuration file if IGNORE_UDPATE
  - call the correct function for the configuration item. 
  * are functions in this file or in other files? How do I 
  call other files cleanly?

  --]]
  if checkfor("-verbose","-s") then
    print("Re-creates the configuration file for the services specified.")
  end 

  if type(parameters["value_2"]) ~= "nil" then
    local subcommand = string.upper(parameters["value_2"])
    local filename
    if subcommand ==  "LIST" then
      
      local fileTypes = GetFileTypes(UpdateFileName..XmlExtension)
      
      for i,v in ipairs(fileTypes) do
	print (i, v)
      end
      return 
    elseif subcommand ==  "UPDATE" then
	filename = UpdateFileName..XmlExtension
    elseif subcommand ==  "REVERT" then
	filename = BaseFileName..XmlExtension
    else
      print("Sub command must be \"revert\", \"update\" or \"list\"")
      return 
    end        
    
    if type(parameters["value_3"]) ~= nil then 
      GenerateContent(filename, parameters["value_3"])
    else
	print("Configure requires three parameters please")			
    end				  

    
  end
end


--[[
Returns the scripts element from the specified XML file.
The system assumes the XML file is valid and in the 
expected format otherwise it blows up.
--]]
function GetScriptsElement(filename)
  if checkfor("-verbose","-s") then
    print("loading "..filename)
  end
  local xfile = xml.load(filename)
  
  if xfile ~= nil then
    local scripts = xfile:find("scripts") 
    
    if scripts ~= nil then
      return scripts
    else
      lua_error()
    end
  else
    lua_error()
  end
end


--[[
gets a table of all the named elements in the XML file provided
--]]
function GetFileTypes(filename)  
    local scripts =  GetScriptsElement(filename)
    local fileTypes = {}
    for i in ipairs(scripts) do
      fileTypes[#fileTypes+1] = scripts[i].name           
    end      
  return fileTypes
end

--[[
--filename: the XML file
Reads an XML file and when a section name (contentName) is matched or equals 
ALL, the function creates the new config file 
--]]
function GenerateContent(filename,contentName)
  
  local scripts = GetScriptsElement(filename) 
  local gflag = false;
    
    for i in ipairs(scripts) do
	if contentName:upper() == "ALL" then 
	  gflag = true
	elseif contentName:upper() == scripts[i].name:upper() then 
	  gflag = true
	end
	
	if gflag == true then
	  if file.exists(scripts[i].dir)~=true then
	      print("didn't find dir. creating...")
	      os.execute("mkdir -p "..scripts[i].dir)	      
	  end	
	  file.write(scripts[i].dir.."/"..scripts[i].name, scripts[i][1],"w")
	  print("Wrote file "..scripts[i].dir.."/"..scripts[i].name)
	end
	
	gflag = false;
    end

end

--[[
Prints the help or ugent help -c prints the changelog
--]]
function help()
	if #arg > 1 then
		if arg[2] == "-c" then
			print "changelog"
		elseif arg[2] == "-v" then
		      print ("User Settings Agent v" .. VERSION)
		end
		
	else
		local f = assert(io.open("help.txt", "r"))
		local readme = f:read("*all")
		f:close()
		i,e = readme:find("(Expanded)")
		if i ~=nil then  
			t = readme:sub(1,i-2)
		elseif arg[2] == "-v" then
			t = readme
		end
		print(t)
		
	end
end


--[[
March 27 2016 - The parsing is broken. parameters aren't added correclty.
This needs an overhall or removal
--]]
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

	if checkfor("-verbose","-s") then
	  print("Paramenter Count",#parameters)
	  print(serialize(parameters))
	  print("Command to execute:", parameters.command)
	end
end

--[[
Checks the command line arguments for a value.
Doesn't use matching and it could.
--]]
function checkfor(val,altVal)
   for i,v in ipairs(arg) do
    if v == val or v == altVal then 
      return true
    end
  end
  return false
end


--[[
Main()
This section is equivelant to main. 
We parse the command line and if the "command" is found 
in the _G table (which lists all functions), it executes it. 
This is native lua functionality.
--]]
ParseCommandLine()
if type(_G[string.lower (parameters.command)]) ~= "nil" then
	_G[string.lower (parameters.command)]()
else
	print("Bad command. Call \"ugent help\"")
end
