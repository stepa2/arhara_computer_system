-- See renderlib.lua top comment

util.AddNetworkString("ArhComp_SurfaceVisibilityUpdate")

local arhcomp_surface_render_range_sv = CreateConVar("arhcomp_surface_render_range_sv", "2048", FCVAR_ARCHIVE,
    "Range in which players can see surface contents", 64, nil) -- desc, min, max

local LiveSurfaces = {}
local LiveRenderDevices = {}


local SURF = {}

function ArhComp.RenderLib.CreateSurface(device, templateIn, params)
    local index = #LiveSurfaces + 1
    assert(index < 16777215, "Too many surfaces active")

    local template

    if istable(templateIn) then
        template = templateIn
    else
        template = ArhComp.RenderLib.GetTemplateByName(templateIn)
    end

    local surf = setmetatable({
        Device = device,
        Template = template,
        Index = index,
        ObserversRev = {},
        Params = params,
    }, {__index = SURF})

    LiveSurfaces[index] = surf
    LiveRenderDevices[device] = LiveRenderDevices[device] or {}
    LiveRenderDevices[device][index] = surf

    return surf
end



function SURF:UpdateObservers(plysRev)
    local combined = {}

    for ply, _ in pairs(self.ObserversRev) do
        combined[ply] = { Prev = true }
    end

    for ply, _ in pairs(plysRev) do
        combined[ply] = combined[ply] or {}
        combined[ply].Cur = true
    end

    

    for ply, data in pairs(combined) do
        local prevHas = data.Prev or false
        local curHas = data.Cur or false

        if prevHas ~= curHas then
            net.Start("ArhComp_SurfaceVisibilityUpdate")
                net.WriteUInt(self.Index, 24) -- Max 16777215
                net.WriteBool(curHas)

                if curHas then
                    net.WriteEntity(self.Device)
                    net.WriteVector(self.Params.Pos)
                    net.WriteAngle(self.Params.Angle)
                    net.WriteUInt(self.Params.SurfSize.X*100, 16)
                    net.WriteUInt(self.Params.SurfSize.Y*100, 16)
                    net.WriteUInt(self.Params.SurfPixelPerWorld, 8)
                    net.WriteString(self.Template.Name)
                end
            net.Send(ply)
        end
    end

    self.ObserversRev = plysRev
end

hook.Add("Think", "ArhComp_Surface_Think", function()
    local devices = LiveRenderDevices
    local players = player.GetHumans()

    local maxDist = arhcomp_surface_render_range_sv:GetFloat()
    local maxDistSqr = maxDist * maxDist

    local surfacesToPlysRev = {}
    local surfacesToPlys = {}

    for iply, ply in ipairs(players) do
        local plyPos = ply:GetPos()

        for device, surfaces in pairs(devices) do

            if IsValid(device)
                and (plyPos:DistToSqr(device:GetPos()) <= maxDistSqr)
                and ply:TestPVS(device) then

                for isurf, surf in pairs(surfaces) do
                    surfacesToPlysRev[surf] = surfacesToPlysRev[surf] or {}
                    surfacesToPlysRev[surf][ply] = true
                
                    surfacesToPlys[surf] = surfacesToPlys[surf] or {}
                    table.insert(surfacesToPlys[surf], ply)
                end
            end
        end
    end

    for surfi, surf in pairs(LiveSurfaces) do
        surf:UpdateObservers(surfacesToPlysRev[surf] or {})
    end

    -- TODO

end)

function SURF:Free()
    LiveSurfaces[self.Index] = nil

    LiveRenderDevices[self.Device][self.Index] = nil

    if table.IsEmpty(LiveRenderDevices[self.Device]) then
        LiveRenderDevices[self.Device] = nil
    end

    self:UpdateObservers({})
end