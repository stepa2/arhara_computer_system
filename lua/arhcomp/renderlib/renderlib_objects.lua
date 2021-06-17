AddCSLuaFile()

ArhComp.RenderObj = {}

local ManagerBySurfaceId = {}

if SERVER then
    util.AddNetworkString("ArhComp_SurfaceData")
end

local MANAGER = {}

function ArhComp.RenderObj.CreateManager(surfIndex)
    assert(ManagerBySurfaceId[surfIndex] == nil, 
        "Render object manager for surface "..tostring(surfIndex).." is already created")

    local manager = setmetatable({
        SurfIndex = surfIndex,
        ObjectByObjectId = {}
    }, {__index = MANAGER}) 

    if SERVER then
        manager.IsActualByObjectIdByPlayer = {}

        for _, ply in ipairs(player.GetHumans()) do
            manager.IsActualByObjectIdByPlayer[ply] = {}
        end
    end

    ManagerBySurfaceId[surfIndex] = manager

    return manager
end

function ArhComp.RenderObj.GetOrCreateManager(surfIndex)
    if ManagerBySurfaceId[surfIndex] ~= nil then
        return ManagerBySurfaceId[surfIndex]
    end

    return ArhComp.RenderObj.CreateManager(surfIndex)
end

function MANAGER:Free()
    ManagerBySurfaceId[self.SurfIndex] = nil
end

function MANAGER:GetObjectsByOId()
    return self.ObjectByObjectId
end

local InvalidateObject

if SERVER then

local function InvalidateObject(manager, object)
    local oid = object.ObjectId

    for _, ply in ipairs(player.GetHumans()) do
        manager.IsActualByObjectIdByPlayer[ply][oid] = nil
    end
end

-- oldObject may be null
function MANAGER:AddOrReplaceObject(newObject, oldObject)
    local id

    if oldObject ~= nil then
        id = oldObject.ObjectId
        InvalidateObject(oldObject)
    else
        id = #self.ObjectByObjectId + 1
    end

    newObject.ObjectId = id

    self.ObjectByObjectId[id] = newObject

    return newObject
end

function MANAGER:RemoveObject(object)
    self.ObjectByObjectId[object.ObjectId] = { ObjectId = object.ObjectId, IsForRemove = true }
    InvalidateObject(object)
end

gameevent.Listen("player_connect")
hook.Add("player_connect", "ArhComp_PlyConnected", function(data)
    local ply = Player(data.userid)

    for surfId, manager in pairs(ManagerBySurfaceId) do
        manager.IsActualByObjectIdByPlayer[ply] = {}
    end
end)

hook.Add("PlayerDisconnected", "ArhComp_PlyDisconnected", function(ply)
    for surfId, manager in pairs(ManagerBySurfaceId) do
        manager.IsActualByObjectIdByPlayer[ply] = nil
    end
end)


end

if SERVER then -- Networking

local function SendObjectPolygon(object)
    net.WriteUInt(object.ObjectId, 16)
    net.WriteColor(object.Color)

    local vertexes = object.Vertexes

    net.WriteUInt(#vertexes, 16)

    for _, vertex in ipairs(vertexes) do
        net.WriteUInt(vertex.X, 16)
        net.WriteUInt(vertex.Y, 16)
        net.WriteUInt(vertex.U * 65535, 16)
        net.WriteUInt(vertex.V * 65535, 16)
    end

    net.WriteString(object.Material and object.Material:GetName() or "")
end

local function SetObjectText(object)
    net.WriteUInt(object.ObjectId, 16)

    net.WriteUInt(object.Position.X, 16)
    net.WriteUInt(object.Position.Y, 16)

    net.WriteColor(object.Color)
    
    net.WriteString(object.Font)
    net.WriteString(object.Text)
end

local function SendSurfaceData(surfIndex, objectsData, ply)
    net.Start("ArhComp_SurfaceData")
        net.WriteUInt(surfIndex, 24)
        net.WriteUInt(#objectsData, 16)

        for _, object in ipairs(objectsData) do
            if object.IsForRemove == true then
                net.WriteUInt(0, 2)
                net.WriteUInt(object.ObjectId, 16)
            elseif object.Type == "poly" then
                net.WriteUInt(1, 2) -- Object type
                SendObjectPolygon(object)
            elseif object.Type == "text" then
                net.WriteUInt(2, 2) -- Object type
                SendObjectText(object)
            else
                Error("Unknown object type:", object.Type)
            end
            
        end
    net.Send(ply)
end

local function ActualizeSurfaceDataForPlayer(manager, ply)
    local isActualByObjectId = manager.IsActualByObjectIdByPlayer[ply]

    assert(isActualByObjectId ~= nil)

    local nonActualObjects = {}

    for id, obj in pairs(manager.ObjectByObjectId) do
        if obj.IsForRemove or isActualByObjectId[id] ~= true then
            nonActualObjects[#nonActualObjects + 1] = obj
        end
    end

    SendSurfaceData(manager.SurfIndex, nonActualObjects, ply) -- TODO: send objects using queue

    for _, obj in ipairs(nonActualObjects) do
        isActualByObjectId[obj.ObjectId] = true
    end
end

local function RemoveObjectsForDelete(manager, observers)
    local toDelete = {}

    for oid, obj in pairs(manager.ObjectByObjectId) do
        if not obj.IsForRemove then continue end

        local isActualEverywhere = true

        for _, ply in ipairs(observers) do
            if not manager.IsActualByObjectIdByPlayer[ply][oid] then
                isActualEverywhere = false
                break
            end
        end

        if isActualEverywhere then
            toDelete[#toDelete + 1] = oid
        end
    end

    for _, oid in ipairs(toDelete) do
        manager.ObjectByObjectId[oid] = nil
    end
end

function MANAGER:DoNetworking(observers)
    for i, ply in pairs(observers) do
        ActualizeSurfaceDataForPlayer(self, ply)
    end

    RemoveObjectsForDelete(self, observers)
end

end -- End networking


if CLIENT then
    local function ReceiveObjectPolygon()
        local id = net.ReadUInt(16)

        local color = net.ReadColor()

        local vertexes = {}

        for i = 0, net.ReadUInt(16) do
            vertexes[i] = { -- Matches PolygonVertex structure
                x = net.ReadUInt(16),
                y = net.ReadUInt(16),
                u = net.ReadUInt(16) / 65536,
                v = net.ReadUInt(16) / 65536,
            }
        end

        local materialName = net.ReadString()
        local material

        if materialName ~= "" then
            material = Material(materialName)
        end

        return {
            ObjectId = id,
            Vertexes = vertexes,
            Material = material,
            Color = color
        }
    end

    local function ReceiveObjectText()
        local id = net.ReadUInt(16)

        local pos = {
            X = net.ReadUInt(16),
            Y = net.ReadUInt(16)
        }

        local color = net.ReadColor()

        local font = net.ReadString()
        local text = net.ReadString()

        return {
            ObjectId = id,
            Position = pos,
            Color = color,
            Font = font,
            Text = text
        }
    end

    net.Receive("ArhComp_SurfaceData", function()
        local surfaceId = net.ReadUInt(24)
        local manager = ArhComp.RenderObj.GetOrCreateManager(surfaceId)

        for i = 1, net.ReadUInt(16) do
            local objectTypeId = net.ReadUInt(2)
            local object

            if objectTypeId == 0 then
                manager.ObjectByObjectId[net.ReadUInt(16)] = nil
                continue
            elseif objectTypeId == 1 then
                object = ReceiveObjectPolygon()
                object.Type = "poly"
            elseif objectTypeId == 2 then
                object = ReceiveObjectText()
                object.Type = "text"
            else
                Error("Unknown object type id: ", objectTypeId)
            end

            manager.ObjectByObjectId[object.ObjectId] = object
        end
    end)
end