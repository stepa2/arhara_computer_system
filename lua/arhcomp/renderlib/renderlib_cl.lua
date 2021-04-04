-- See renderlib.lua top comment

local SurfTempToSTIndex = {}
local STIndexToSurfTemp = {}

function ArhComp.RenderLib.ImplCl_RegisterSurfaceTemplate(templateName, template)
    SurfTempToSTIndex[template] = templateName
    STIndexToSurfTemp[templateName] = template
end

local AllocatedSurfaces = {}

local ServerSurfaces = {}

local function AllocateSurfaceImpl(index, templateName, size)
    local template = STIndexToSurfTemp[templateName]
    local opaque = templateName.Opaque

    local rtName = "arhcomp_rt_" .. templateName .. "_inst_" .. tostring(index)

    local rt = GetRenderTargetEx(rtName,
        size.X, size.Y, RT_SIZE_NO_CHANGE, MATERIAL_RT_DEPTH_NONE, 
        bit.bor(16, Either(opaque, 0, 8192), 32768),
        0, Either(opaque, IMAGE_FORMAT_RGB888, IMAGE_FORMAT_RGBA8888)) -- rtFlags, imageFormat

    local shader            = template.Shader
    local matTableFactory   = template.MaterialTableFactory

    local mat = CreateMaterial(rtName, shader, matTableFactory(rtName))

    return mat
end

local function AllocateSurface(templateName, size)
    local put_to = AllocatedSurfaces[templateName] or {}
    local index = #put_to + 1

    local material = AllocateSurfaceImpl(index, templateName, size)

    local surf = { Material = material, Used = false }

    put_to[index] = surf

    AllocatedSurfaces[templateName] = put_to

    return surf
end

local function GetOrAllocateSurface(templateName, size)
    local surfacesOfTemplate = AllocatedSurfaces[templateName]

    for i, surf in ipairs(surfacesOfTemplate or {}) do
        if not surf.Used then
            return surf
        end
    end

    return AllocateSurface(templateName, size)
end

net.Receive("ArhComp_SurfaceVisibilityUpdate", function(len)
    local index = net.ReadUInt(24)
    local is_visible = net.ReadBool()

    local surf = ServerSurfaces[index]

    if is_visible then
        assert(surf == nil)

        surf = {}
        surf.Device = net.ReadEntity()
        surf.Pos = net.ReadVector()
        surf.Angle = net.ReadAngle()
        surf.SurfSize = {
            X = net.ReadUInt(16)/100,
            Y = net.ReadUInt(16)/100
        }
        surf.SurfPixelPerWorld = net.ReadUInt(8)
        surf.SurfPixelScale = 1 / surf.SurfPixelPerWorld

        surf.DrawSurfTemplateName = net.ReadString()

        local drawSurf = AllocateSurface(surf.DrawSurfTemplateName, surf.SurfSize)
        drawSurf.Used = true

        surf.DrawSurface = drawSurf

        PrintTable(surf)
    else
        assert(surf ~= nil)
        surf.DrawSurface.Used = false
        surf = nil
    end

    ServerSurfaces[index] = surf
end)

local ColorRed = Color(255,0,0)
local ColorGreen = Color(0,255,0)
local ColorBlue = Color(0,0,255)

hook.Add("PostDrawOpaqueRenderables", "ArhComp_PostDrawOpaqueRenderables", function(is_depth, is_skybox)
    if --[[is_depth or]] is_skybox then return end


    for surf_i, surf in pairs(ServerSurfaces) do
        local ent = surf.Device

        if not IsValid(ent) then continue end

        local pos = ent:LocalToWorld(surf.Pos)
        local ang = ent:LocalToWorldAngles(surf.Angle)
        local ratio = surf.SurfPixelPerWorld
        local scale = surf.SurfPixelScale

        local sizeX = surf.SurfSize.X * ratio
        local sizeY = surf.SurfSize.Y * ratio

        cam.Start3D2D(pos, ang, scale)
            surface.SetDrawColor(255,255,255,255)
            surface.SetMaterial(surf.DrawSurface.Material)
            surface.DrawRect(0,0, sizeX, sizeY)
        cam.End3D2D()
    end
end)