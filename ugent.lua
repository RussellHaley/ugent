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


--[[
Parameters: BASE|UPDATE <source-filename>
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

function CheckConf(item)	
	conf=file.read(ConfFileName)
	i,j = conf:find(item)
	if i then 
		--~ match everything from <item> to the end of the line"
		--~ I can't make this work ???
		--~ matchPattern = "^.*"..item..".*$"
		--~ print(matchPattern)
		--~ line = conf:match(matchPattern)
		--~ print("The Line:", line)
		--~ print("is not what I was looking for")
		--~ one, two = line:match("([^,]+)=([^,]+)")
		--~ print(one,two)
		
		--~Oh computer gods, please forgive me for this brutal hack...
		enabled = conf:sub(j+2,j+4)
		if enabled:upper() == "YES" then
			return true 
		else
			return false
		end		
	else 
		return false 
	end
end

function SetConf(item,value)
--Read in the file and look for the "Item value	
  conf=file.read(ConfFileName)		
  i,j = conf:find(item)
  if i then --if item is found   
    --replace item=<anything> with item=value
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

function configure()
	--[[
		- Check command line parameters for a list of files to generate
		- Check the configuration file if IGNORE_UDPATE
		- call the correct function for the configuration item. 
			* are functions in this file or in other files? How do I 
			call other files cleanly?
			
	--]]
	print("re-creates the configuration file for the services specified.")
	
	if type(parameters["value_2"]) ~= "nil" then
		if string.upper(parameters["value_2"]) ==  "REVERT" then
			print("REVERT YALL")
			
		elseif string.upper(parameters["value_2"]) ==  "UPDATE" then
			print("LETS UPDATE")
			
		elseif string.upper(parameters["value_2"]) ==  "LIST" then
			print("1","rc.conf")
			print("2","wpa_supplicant.conf")
			print("3","racoon.conf")
			print("4","ipsec-tools.conf")
			print("5","kerberos.conf")
			print("6","app.conf")
			
		else
			print("Sub command must be \"revert\", \"update\" or \"list\"")
			return
		end	
		
		
	end
	
	--[[
	if CheckConf("IGNORE_UPDATE") then
		print("Use Base File")
	else
		print("use update")
	end
	--]]
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

function loadxml(filename)
	
  -- load XML data from file "test.xml" into local table xfile 
  local xfile = xml.load(filename) 
  -- search for substatement having the tag "scripts" 
  local xscripts= xfile:find("scripts") 

    --print(type(xscripts))
    for i,v in ipairs(xscripts) do
      
      if file.exists(xscripts[i].dir)~=true then
	  print("didn't find dir. creating...");
	  os.execute("mkdir -p "..xscripts[i].dir)	      
      end	    
--      print(xscripts[i].dir.."/"..xscripts[i].name..xscripts[i][1])
      file.write(xscripts[i].dir.."/"..xscripts[i].name,xscripts[i][1],"w")
      --newfile.write(xscripts[i][1])
      --newfile.close()	
      --print(xscripts[i].dir.."/"..xscripts[i].name)
      --print(xscripts[i][1])
      
    end
    
  -- set attribute id
    --xscripts["id"] = "newId"

end

function checkForConfType(typename)
    local xfile = xml.load(xmlfilename) 
    local xscripts= xfile:find("scripts") 
    for i,v in ipairs(xscripts) do
      if xscripts[i].name then
	return true, xscripts[i].dir.."/"..xscripts[i].name,xscripts[i][1], xscripts[i][1]
      end
    end
    return false
end

function chooseFileType(filetype)
  
  if filetype == 1 then -- rc.conf
    
  elseif filefype == 2 then --wpa_supplicant.conf
    
  elseif filefype == 3 then --racoon.conf
  
  elseif filefype == 4 then --ipsec-tools.conf
  elseif filefype == 5 then -- kerberos.conf
  elseif filefype == 6 then --app.conf
  elseif filefype == 7 then
  elseif filefype == 8 then
  
  
    
  end
end

function createConfFile(path, content,permissions)
  --[[
  1) check if exists
  2) overwrite
  --]]
end


--UgentFunctions = {HELP = help, IMPORT = import, CONFIGURE = configure, SET = set, STATE = state, SAL = Salutations, XML = LoadXml, NAMES = PrintNames}

--if #arg < 1 then print("You must provide arguments to continue") return end

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
if type(_G[string.lower (parameters.command)]) ~= "nil" then
	_G[string.lower (parameters.command)]()
else
	print("Bad command. Call \"ugent help\"")
end
