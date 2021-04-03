--[[
    All ArhComp Devices are entities that contains set of SubDevices (e.g. screen, keyboard, programrunner)

    SubDevice interface:

    function nil SUBDEV:OnCreate(table params) - requred, called on creation
]]

AddCSLuaFile()

local function LoadDeviceFiles()
    local root = "arhcomp/subdevices/"

    for i, filename in ipairs(file.Find(root .. "sd_*.lua","LUA")) do
        AddCSLuaFile(root .. filename)
        include(root .. filename)
    end
end


local Lib = {}

ArhComp.SubDevice = Lib

if SERVER then
    local SubDeviceTypes = {}

    function Lib.RegisterType(sdtypename, data)
        data.__index = data

        SubDeviceTypes[sdtypename] = data
    end

    function Lib.Create(sdtypename, entity, params)
        local sdtype = SubDeviceTypes[sdtypename]

        local subdev = setmetatable({}, sdtype)

        subdev:OnCreated(params)

        entity.SubDevices[sdtypename] =
            table.ForceInsert(entity.SubDevices[sdtypename], subdev)
    end

    function Lib.InitHost(entity)
        if not IsValid(entity) or entity:GetClass() ~= "arhcomp_device" then
            return nil
        end

        entity.SubDevices = {}
    end

    function Lib.GetAll(entity)
        if not IsValid(entity) or entity:GetClass() ~= "arhcomp_device" then
            return nil
        end

        return entity.SubDevices
    end

    function Lib.GetAllOfType(entity, sdtypename)
        return entity.SubDevices[sdtypename] or {}
    end

    function Lib.GetSingleOfType(entity, sdtypename)
        local all = Lib.GetAllOfType(entity, sdtypename)

        return #all == 1 and all[1] or nil
    end

end

LoadDeviceFiles()