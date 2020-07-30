--Spaceb.in for OpenComputers.
--Allows you to get things from Spacebin..in OpenComputers!
--Why did I do this.
--Author PeachMaster, 2020
local component = require("component")
local fs = require("filesystem")
local interwebz = require("internet")
local filesystem = require("filesystem")
local shell = require("shell")
local serialization = require("serialization")

if not component.isAvailable("internet") then
  print("This program requires an internet card to run.")
  return
end

if not filesystem.exists("/usr/lib/json.lua") then
    shell.execute("mkdir /usr/lib")
    shell.execute("pastebin get E32pxWMu /usr/lib/json.lua")
end

local json = require("json")

local args, options = shell.parse(...)

local function get(theID, filename)
    local f, reason = io.open(filename, "w")
    io.write("Downloading from spaceb.in...")
    local url = "https://api.spaceb.in/api/v1/document/"..theID.."/raw"
    local handle = interwebz.request(url, {}, {["User-Agent"] = "OpenComputers", ["Accept"] = "*/*"}, "GET")
    local result = ""
     for chunk in handle do
         result = result..chunk 
    
    end 
    io.write("done! \n")
    local io = require("io")
    f:write(result)
    f:close()
    print("Completed successfully!")
end

local function put(filename)
    local io = require("io")
    local file, reason = io.open(filename, "r")

    if not file then
      io.stderr:write("Failed opening file for reading: " .. reason)
      return
    end
    local data = file:read("*a")
    file:close()
    local url = "https://api.spaceb.in/api/v1/document/"
    local handle = interwebz.request(url, json.encode({content = data}), {["Content-Type"] = "application/json", ["User-Agent"] = "OpenComputers", ["Accept"] = "*/*"}, "POST")
    local result = ""
     for chunk in handle do
         result = result..chunk 
    end 

    local jsonResult = json.decode(result)
    print("Completed successfully!")
    print("Use the ID "..jsonResult["payload"]["id"].." to use your paste anywhere!")
end

local function run(theID, ...)
    local tmpFile = os.tmpname()
    get(theID, tmpFile)
    print("Running "..theID.."...")
    local success, reason = shell.execute(tmpFile, nil, ...)
    if not success then
      io.stderr:write(reason)
    end
    fs.remove(tmpFile)
end

local command = args[1]

if command == "help" or command == nil then
    print("Downloads a file from Spaceb.in, text sharing for the final frontier. ")
    print("")
    print("spacebin get <id> <filename> to get a file and save it.")
    print("spacebin put <filename> to put a file up on the site.")
    print("spacebin run <filename> to directly run a program, without saving it.")
end

if command == "get" then
    if (args[2]==nil) then
        print("You need to put an id to get from.")
        print("spacebin get <id> <filename>")
        return
    end
    if (args[3]==nil) then
        print("You need a file to put it to.")
        print("spacebin get <id> <filename>")
        return
    end
    get(args[2], args[3])
end


if command == "put" then
    put(args[2])
end

if command == "run" then
    run(args[2], table.unpack(args, 3))
end
