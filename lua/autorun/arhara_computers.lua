AddCSLuaFile()

print("Arhara Computer System initialized " .. (SERVER and "serverside" or "clientside"))

if SERVER then
    AddCSLuaFile("arhcomp/loader.lua")
end

include("arhcomp/loader.lua")