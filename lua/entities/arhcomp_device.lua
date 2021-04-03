AddCSLuaFile()

ENT.Type = "anim"
ENT.Base = "base_anim"
ENT.Category = "ArhComp"

if SERVER then
    function ENT:InitFromConfig(config)
        ArhComp.SubDevice.InitHost(self)

        self.SpawnConfig = config
        self:SetModel(config.Model)

        for i, sdconfig in ipairs(config.SubDevices) do
            ArhComp.SubDevice.Create(sdconfig.Type, self, sdconfig)
        end
    end
end

function ENT:Initialize()
    if SERVER then
        self:PhysicsInit(SOLID_VPHYSICS)
        self:SetUseType( SIMPLE_USE )
    end
end

function ENT:Use(activator)
    local keyboard = ArhComp.SubDevice.GetSingleOfType(self, "keyboard")

    if keyboard then
        keyboard:OnHostUsed(activator)
    end
end

function ENT:OnRemove()
 timer.Simple( 0, function()
        if not IsValid( self ) then
            -- TODO
        end
    end)
end