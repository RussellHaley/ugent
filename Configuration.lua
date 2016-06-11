--~ stringio = require("pl.stringio")
--~ config = require("pl.config")


local Conf = {}

function convert_true(conftable)
  for i,v in pairs(conftable) do
    if type(v) == 'string' then
      --convert this to a proper regex later please. 
      if v:upper() == "YES" or v:upper() =="\"YES\"" or v:upper() =="TRUE" or v:upper() =="\"TRUE\"" or v:upper() =="ON" or v:upper() =="\"ON\"" then
        v = true
      elseif v:upper() == "NO" or v:upper() =="\"NO\"" or v:upper() =="FALSE" or v:upper() =="\"FALSE\"" or v:upper() =="OFF" or v:upper() =="\"OFF\"" then

        v = false

      end
    end
  end
end

function Conf.Read(filePath)
	--foreachline, split on the first =
	--everything before is a key, everything after is a value
	--if not file_exists(file) then return {} end
  kvps = {}
  for line in io.lines(filePath) do 
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

--THIS FUNCTION WIPES OUT CONF FILES!
function Conf.Write(item,value)
  --table.insert(t,item,value)
--Read in the file and look for the "Item value	
  local f = assert(io.open(Conf.conf_file_path, "r"))
  local c = f:read("*all")
  f:close()  
  i,j = c:find(item)
  if i then --if item is found   
    --replace item=<anything> with item=value
    -- THIS SUBSTITUTION DOESN"T WORK PROPERLY IT ONLY FINDS LINEFEED 
    -- not the end of string
    c = c:gsub(item.."=.-[%\n]",item.."="..value.."\n")	  	  
  else --item wasn't found 
    if c:sub(#c, 1) == "\n" then 
      c = c..item.."="..value
    else	
      c = c.."\n"..item.."="..value
    end
  end
  c = remove_ending_newlines(c)
  print(c)
  f = assert(io.open(Conf.conf_file_path, "w"))
  f:write(c.."morestuff")
  f:close()
end

function remove_ending_newlines(str) 
  local x = #str
  local pos = 0
  --print("starting:",str)
  while(string.find(str,"\n",-1) ~= nil 
    or string.find(str,"\r",-1) ~= nil)
  do
    str = string.sub(str,1,-2)
    x = x - 1
  end

  return str
end

return Conf
