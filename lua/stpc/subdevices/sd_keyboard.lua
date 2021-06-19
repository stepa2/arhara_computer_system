if SERVER then
    util.AddNetworkString("STPC_SDKeyboard_LockPlayer")

    local PlayersToActiveKeyboards = {}

    local SUBDEV = {}

    function SUBDEV:OnCreated(params)
    end

    function SUBDEV:OnRemoved()
        self:DetachPlayer()
    end

    function SUBDEV:AttachPlayer(ply)
        PlayersToActiveKeyboards[ply] = self
        self.User = ply
        net.Start("STPC_SDKeyboard_LockPlayer")
            net.WriteBool(true)
        net.Send(ply)
    end

    function SUBDEV:DetachPlayer()
        if self.User then
            PlayersToActiveKeyboards[self.User] = nil 

            net.Start("STPC_SDKeyboard_LockPlayer")
                net.WriteBool(false)
            net.Send(self.User)

            self.User = nil
        end
    end

    function SUBDEV:OnHostUsed(ply)
        self:AttachPlayer(ply)
    end

    function SUBDEV:OnKey(button, isPressed)
        print("keyboard:OnKey", button, isPressed)
    end

    hook.Add("PlayerButtonDown", "STPC_SD_Keyboard", function(ply, button)
        local keyboard = PlayersToActiveKeyboards[ply]

        if keyboard then
           if button == KEY_RSHIFT then
               keyboard:DetachPlayer()
           else
               keyboard:OnKey(button, true)
           end
        end
    end)

    hook.Add("PlayerButtonUp", "STPC_SD_Keyboard", function(ply, button)
        local keyboard = PlayersToActiveKeyboards[ply]

        if keyboard then
            keyboard:OnKey(button, false)
        end
    end)

    hook.Add("PlayerDisconnected", "STPC_SD_Keyboard", function(ply)
        PlayersToActiveKeyboards[ply]:DetachPlayer()
    end)

    hook.Add("StartCommand", "STPC_SD_Keyboard", function(ply, usercmd)
        if PlayersToActiveKeyboards[ply] then -- This player uses some keyboard
            usercmd:ClearMovement()
            usercmd:ClearButtons()
        end
    end)


    
    STPC.SubDevice.RegisterType("keyboard", SUBDEV)
end

if CLIENT then
    local BlockInput = false

    hook.Add("StartChat", "STPC_SD_Keyboard", function()
        if BlockInput then
            return true
        end
    end)

    hook.Add("PlayerBindPress", "STPC_SD_Keyboard", function()
        if BlockInput then
            return true
        end
    end)

    net.Receive("STPC_SDKeyboard_LockPlayer", function()
        BlockInput = net.ReadBool()
    end)
end