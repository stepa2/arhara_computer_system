-- See renderlib.lua top comment

util.AddNetworkString("ArhComp_SurfaceContentsUpdate")
util.AddNetworkString("ArhComp_SurfaceVisibilityUpdate")

local arhcomp_surface_render_range_sv = CreateConVar("arhcomp_surface_render_range_sv", "2048", FCVAR_ARCHIVE,
    "Range in which players can see surface contents", 64, nil) -- desc, min, max

local LiveSurfaces = {}
local LiveRenderDevices = {}

local SURF = {}

function ArhComp.RenderLib.CreateSurface(device, templateName, params)
    local index = #LiveSurfaces + 1

    local surf = setmetatable({
        Device = device,
        TemplateName = templateName,
        Template = ArhComp.RenderLib.GetTemplateByName(templateName),
        Index = index,
        ObserversRev = {},
        Params = params
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

function SURF:UpdateObservers(plysRev)
    local function indexFn(self2, i)
        return plysRev[i] or self.ObserversRev[i]
    end

    for ply, _ in pairs(setmetatable({}, {__index = indexFn})) do
        local prevHas = self.ObserversRev[ply] or false
        local curHas = plysRev[i] or false

        if prevHas ~= curHas then
            net.Start("ArhComp_SurfaceVisibilityUpdate")
                net.WriteUInt(self.Index, 24) -- Max 16777215
                net.WriteBool(curHas)

                if curHas then
                    net.WriteEntity(self.Device)
                    net.WriteVector(self.Params.Pos)
                    net.WriteNormal(self.Params.Normal)
                    net.WriteUInt(self.Params.SurfSize.X, 12)
                    net.WriteUInt(self.Params.SurfSize.Y, 12)
                    net.WriteString(TemplateName)
                end
            net.Send(ply)
        end

        if curHas then
            net.Start("ArhComp_SurfaceContentsUpdate")
                net.WriteUInt(self.Index, 24) -- Max 16777215
                
                -- TODO:
            net.Send(ply)
        end

    end
end

--[[
function SURF:SendDrawData(ply)
    net.Start("ArhComp_SurfaceUpdate")
        net.WriteUInt(self.Index, 24) -- Max 16777215
        net.WriteBit(true) -- IsVisible

        -- TODO:
    net.Send(ply)
end
]]


hook.Add("Think", "ArhComp_Surface_Think", function()
    local devices = LiveRenderDevices
    local players = player.GetHumans()

    local maxDist = arhcomp_surface_render_range_sv:GetFloat()
    local maxDistSqr = maxDist * maxDist

    local surfacesToPlys = {}


    for iply, ply in ipairs(players) do
        local plyPos = ply:GetPos()

        for device, surfaces in pairs(devices) do
            if IsValid(device) 
                and (plyPos:DistToSqr(device:GetPos()) <= maxDistSqr) 
                and ply:TestPVS(device) then

                for isurf, surf in pairs(surfaces) do
                    surfacesToPlys[surf] = surfacesToPlys[surf] or {}
                    surfacesToPlys[surf][ply] = true 
                end
            end
        end
    end

    for surf, plysRev in pairs(surfacesToPlys) do
        surf:UpdateObservers(plysRev)
    end

end)