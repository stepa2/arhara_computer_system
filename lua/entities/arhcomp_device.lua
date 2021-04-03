AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.AutomaticFrameAdvance = true
ENT.Category = "ArhComp"

if SERVER then
    function ENT:InitFromConfig(config)
        ArhComp.SubDevice.HostInit(self)

        self.SpawnConfig = config
        self:SetModel(config.Model)

        ArhComp.SubDevice.HostConfigurateDevs(self, config.SubDevices)
    end

    function ENT:Use(activator)
        local keyboard = ArhComp.SubDevice.GetSingleOfType(self, "keyboard")
    
        if keyboard then
            keyboard:OnHostUsed(activator)
        end
    end
    
    function ENT:OnRemove()
        ArhComp.SubDevice.HostRemove(self)
    end

    function ENT:Think()
        for _, subdevs in pairs(ArhComp.SubDevice.GetAll(self)) do
            for _, subdev in pairs(subdevs) do
                if subdev.OnThink then
                    subdev.OnThink()
                end
            end
        end
    end
end

function ENT:Initialize()
    if SERVER then
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetUseType( SIMPLE_USE )
    end
end

