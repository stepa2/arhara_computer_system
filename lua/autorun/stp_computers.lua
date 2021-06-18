AddCSLuaFile()

print("STPComputers initialized " .. (SERVER and "serverside" or "clientside"))

if SERVER then
    AddCSLuaFile("stpc/loader.lua")
end

include("stpc/loader.lua")