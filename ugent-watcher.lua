sys = require("sys")
thread = sys.thread
serialize = require("ser")
lfs = require("lfs")
conf = require("Configuration")
libFile = require("file")
xml = require('LuaXml')
log = require('log')


  local function read_stdin()
    while true do
      local line = stdin:read("*l")
      if line == 'quit\n' then
        print("Worker:", "Notify controller")
        worker:interrupt()
        stdin:close(true)  -- Win32 workaround
        assert(worker:wait() == -1)
        evq:del(evid)
      else
        sys.stdout:write("Worker:\tInput: ", line)
      end
    end
  end
  
local function on_change(evq, evid, path, ev)
  --print(evid,path,ev)    
local ugentcommand = "sh ugent"
  for file in lfs.dir(path) do

    if file ~= "." and file ~= ".." then 
      local fullpath = path.."/"..file
      local extension = libFile.getfileextension(file)

      if(extension) then
        if extension == "xml" then
          if containsUgentContent(fullpath) then
            local command = ugentcommand.." import update "..fullpath
            os.execute(command)
          end
          print("found xml file")
        elseif extension == "xz" then
          print("found xzfile")
        elseif extension == "zip" then
          print("found zip file")
        else 
          print("extension not recognized? ", extension)
        end
      end

      if file == watchfile then
        
        os.execute("rm "..fullpath)  
      end
    end

  end
  assert(ev == 'r', "file change notification expected")

  --assert(evq:add_dirwatch(watchpath, on_change, 1000000, true, true))
end


function containsUgentContent(filename)
  local xfile = assert(xml.load(filename))

  if xfile ~= nil then
    local header = xfile:find("ugentXml") 

    if header ~= nil then
      return true
    else
      return false
    end
  else
    print("Not a ugent XML file.")
  end    
end

--[[
Starts the application, initialize globals and other things. 
]]--
function Begin()
  kvps = conf.Read("watcher.conf")

  watchpath = kvps["watchpath"]
  watchfile = kvps["watchfile"]
  logfile = kvps["logfile"]
  evq = assert(sys.event_queue())
  thread.init()
  log.logfile = logfile
  stdin = sys.stdin
 
end

 --[[
  This is where we check the timeout/error and decide if we wish to continue processing.
  ]]--
function Continue()
   local _, err = pcall(read_stdin)
    if err and not (thread.self():interrupted()
        and err == thread.interrupt_error()) then
      print("Error:", err)
      err = nil
    end
    if not err then
      error("Thread Interrupt Error expected")
    end
    print("Worker:", "Terminated")
    return -1
end



function Start()
--Should this be done in Continue so we can call it in a loop?
  if libFile.directoryexists(watchpath) then 
    --RH: Need to test if the path exists, if not, create it
    assert(evq:add_dirwatch(watchpath, on_change, 1000000, false, true)) -->path, delegate, timeout,exit_on_event,updates only)
    log.info('started')
  else
    print("The watchpath variable required in the conf file is either missing or not valid: ", watchpath)

  end

  worker = assert(thread.run(Continue))
    
--Start the loop
  assert(evq:loop())
    
end

function Stop()
  evq:stop()
end 

function End()
  print "Closing."
end



Begin()
Start()
Continue()
End()