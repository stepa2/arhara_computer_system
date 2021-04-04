-- See renderlib.lua top comment

local arhcomp_surface_render_range_sv = CreateConVar("arhcomp_surface_render_range_sv", "2048", FCVAR_ARCHIVE,
    "Range in which players can see surface contents", 64, nil) -- desc, min, max

local LiveSurfaces = {}
local LiveRenderDevices = {}

local SURF = {}

function ArhComp.RenderLib.CreateSurface(device, templateName)
    local index = #LiveSurfaces + 1

    local surf = setmetatable({
        Device = device,
        Template = ArhComp.RenderLib.GetTemplateByName(templateName),
        Index = index
    }, {__index = SURF})

    LiveSurfaces[index] = surf
    LiveRenderDevices[device] = LiveRenderDevices[device] or {}
    LiveRenderDevices[device][index] = surf

    return surf
end

function SURF:Free()
    LiveSurfaces[self.Index] = nil

    LiveRenderDevices[self.Device][self.Index] = nil
    
    if table.IsEmpty(LiveRenderDevices[self.Device]) then
        LiveRenderDevices[self.Device] = nil
    end

end

function SURF:SendDrawData(ply)
    print("Surface", self, "will be draw on", ply)
end

hook.Add("Think", "ArhComp_Surface_Think", function()
    local devices = LiveRenderDevices
    local players = player.GetHumans()

    local maxDist = arhcomp_surface_render_range_sv:GetFloat()
    local maxDistSqr = maxDist * maxDist

    for iply, ply in ipairs(players) do
        local plyPos = ply:GetPos()

        for device, surfaces in pairs(devices) do
            if not IsValid(device) then continue end

            if (plyPos:DistToSqr(device:GetPos()) <= maxDistSqr) and ply:TestPVS(device) then
                for isurf, surf in pairs(surfaces) do
                    surf:SendDrawData(ply)
                end
            end
        end
    end
end)