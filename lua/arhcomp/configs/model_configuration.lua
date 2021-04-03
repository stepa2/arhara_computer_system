AddCSLuaFile()

ArhComp.DeviceCapabilities = {
    COMPUTER = 1,
    MONITOR = 2,
    KEYBOARD = 4
}

local CapabilityToList = {
    [ArhComp.DeviceCapabilities.COMPUTER] = "arhcomp_computers",
    [ArhComp.DeviceCapabilities.MONITOR] = "arhcomp_monitors",
    [ArhComp.DeviceCapabilities.KEYBOARD] = "arhcomp_keyboards",
}

local DeviceConfigs = {}

local function RegisterDevice(capabilities, data)
    for cap, listname in pairs(CapabilityToList) do
        if bit.band(capabilities, cap) == cap then
            list.Add(listname, data)
        end
    end

    DeviceConfigs[data.Name] = data
end

function ArhComp.GetDeviceConfigsByCapability(capability)
    local listname = CapabilityToList[capability]

    return listname and list.Get(listname) or nil
end

function ArhComp.GetDeviceConfigsByName(name)
    return DeviceConfigs[name]
end

-- Devices go here

RegisterDevice(bit.bor(
    ArhComp.DeviceCapabilities.COMPUTER,
    ArhComp.DeviceCapabilities.MONITOR,
    ArhComp.DeviceCapabilities.KEYBOARD),
    {
        Name = "combine_interface_mid",
        PrimaryCapability = ArhComp.DeviceCapabilities.COMPUTER,
        Model = "models/props_combine/combine_interface002.mdl",
        SubDevices = {
            keyboard = {
                Type = "keyboard"
            },
            screen = {
                Type = "screen"
            }
        }
})

