AddCSLuaFile()

TOOL.Name = "ArhComp Spawner"
TOOL.ClientConVar = {
    devname = ""
}

local function SetSpawnedDevice(device)
    RunConsoleCommand("arhcomp_spawner_devname", device.Name)
end

function TOOL:GetSpawnedDevice()
    local name = self:GetClientInfo("devname")
    return name ~= "" and ArhComp.GetDeviceConfigsByName(name) or nil
end

function TOOL.BuildCPanel(panel)
    panel:Help("Use this tool to spawn devices")

    local IconLayout = vgui.Create("DIconLayout")
    IconLayout:SetSpaceX(5)
    IconLayout:SetSpaceY(5)

    for capname, cap in pairs(ArhComp.DeviceCapabilities) do
        local Label = vgui.Create("DLabel")
        Label.OwnLine = true
        Label:SetText(capname)

        IconLayout:Add(Label)

        for i, device in ipairs(ArhComp.GetDeviceConfigsByCapability(cap)) do
            if device.PrimaryCapability ~= cap then continue end

            local model = device.Model

            local ModelDisplay = vgui.Create("SpawnIcon")
            ModelDisplay:SetSize(128, 128)
            ModelDisplay:SetModel(model)

            ModelDisplay.DoClick = function()
                SetSpawnedDevice(device)
            end

            IconLayout:Add(ModelDisplay)
        end
    end

    panel:AddItem(IconLayout)
end

function TOOL:LeftClick(trace)
    if CLIENT then return end -- No prediction now

    local device_to_spawn = self:GetSpawnedDevice()

    if device_to_spawn == nil then
        return false
    end

    local entity = ents.Create("arhcomp_device")

    entity:SetPos(trace.HitPos + Vector(0,0,entity:OBBMins().z))

    entity:InitFromConfig(device_to_spawn)

    entity:Spawn()
    entity:Activate()

    undo.Create("ArhComp device")
    do
        undo.AddEntity(entity)
        undo.SetPlayer(self:GetOwner())
    end
    undo.Finish()

    return true
end

function TOOL:Think()
    local device_to_spawn = self:GetSpawnedDevice()

    if device_to_spawn == nil then
        self:ReleaseGhostEntity()
        return
    end

    if not IsValid( self.GhostEntity ) or self.GhostEntity:GetModel() ~= device_to_spawn.Model then
        self:MakeGhostEntity(device_to_spawn.Model, vector_origin, angle_zero)
    end

    self:UpdateGhostEntity()
end

function TOOL:UpdateGhostEntity()
    local ghost = self.GhostEntity

    if not IsValid(ghost) then return end

    local trace = self:GetOwner():GetEyeTrace()
    if not trace.Hit then
        ghost:SetNoDraw(true)
        return
    end

    ghost:SetPos(trace.HitPos + Vector(0,0,ghost:OBBMins().z))
    ghost:SetNoDraw(false)
end