--[[
    All STPC Devices are entities that contains set of SubDevices (e.g. screen, keyboard, programrunner)

    SubDevice interface:

    function nil SUBDEV:OnCreate(table params) - requred, called on creation
]]

AddCSLuaFile()

local function LoadDeviceFiles()
    local root = "STPC/subdevices/"

    for i, filename in ipairs(file.Find(root .. "sd_*.lua","LUA")) do
        AddCSLuaFile(root .. filename)
        include(root .. filename)
    end
end


local Lib = {}

STPC.SubDevice = Lib

if SERVER then
    local SubDeviceTypes = {}

-- Device (subdevice host) functions

    function Lib.HostInit(entity)
        if not IsValid(entity) or entity:GetClass() ~= "stpc_device" then
            return nil
        end

        entity.SubDevices = {}
    end

    function Lib.HostConfigurateDevs(entity, sdconfigs)
        for name, sdconfig in pairs(sdconfigs) do
            Lib.Create(sdconfig.Type, name, entity, sdconfig)
        end

    end

    function Lib.HostRemove(entity)
        local subdevs = entity.SubDevices

        timer.Simple(0, function() -- https://github.com/Facepunch/garrysmod-issues/issues/4675
            if IsValid(entity) then return end

            for sdtype, sdevs in pairs(subdevs) do
                for name, sdev in pairs(sdevs) do
                    sdev:OnRemoved()
                end
            end
        end)
    end

-- Subdevice type functions

    function Lib.RegisterType(sdtypename, data)
        data.__index = data

        SubDeviceTypes[sdtypename] = data
    end

-- Subdevice functions

    function Lib.Create(sdtypename, name, entity, params)
        local sdtype = SubDeviceTypes[sdtypename]

        local subdev = setmetatable({ Device = entity }, sdtype)

        subdev:OnCreated(params)

        entity.SubDevices[sdtypename] = entity.SubDevices[sdtypename] or {}
        entity.SubDevices[sdtypename][name] = subdev
    end

    function Lib.GetAll(entity)
        if not IsValid(entity) or entity:GetClass() ~= "stpc_device" then
            return nil
        end

        return entity.SubDevices
    end

    function Lib.GetAllByType(entity, sdtypename)
        return entity.SubDevices[sdtypename] or {}
    end

    function Lib.GetByTypeAndName(entity, sdtypename, sdname)
        return Lib.GetAllByType(entity, sdtypename)[sdname]
    end

    function Lib.HasAnyByType(entity, sdtypename)
        return entity.SubDevices[sdtypename] ~= nil
    end

    function Lib.GetSingleByType(entity, sdtypename)
        local all = Lib.GetAllByType(entity, sdtypename)

        local k1, v1 = next(all) -- First key-value as would pairs(all) return
        local k2, v2 = next(all, k1) -- Second key-value as would pairs(all) return

        if k1 ~= nil and k2 == nil then -- Return value only if first key exists and second does not
            return v1
        else
            return nil
        end
    end

end

LoadDeviceFiles()