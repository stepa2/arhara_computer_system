AddCSLuaFile()

STPC.DeviceCapabilities = {
    COMPUTER = 1,
    MONITOR = 2,
    KEYBOARD = 4
}

local CapabilityToList = {
    [STPC.DeviceCapabilities.COMPUTER] = "STPC_computers",
    [STPC.DeviceCapabilities.MONITOR] = "STPC_monitors",
    [STPC.DeviceCapabilities.KEYBOARD] = "STPC_keyboards",
}

local DeviceConfigs = {}

function STPC.GetDeviceConfigsByCapability(capability)
    local listname = CapabilityToList[capability]

    return listname and list.Get(listname) or nil
end

function STPC.GetDeviceConfigsByName(name)
    return DeviceConfigs[name]
end

function STPC.RegisterDevice(capabilities, data)
    for cap, listname in pairs(CapabilityToList) do
        if bit.band(capabilities, cap) == cap then
            list.Add(listname, data)
        end
    end

    DeviceConfigs[data.Name] = data
end

AddCSLuaFile("model_configuration_db.lua")
include("model_configuration_db.lua")