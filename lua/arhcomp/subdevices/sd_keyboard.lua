if SERVER then
    local SUBDEV = {}

    function SUBDEV:OnCreated(params)
    end

    function SUBDEV:OnHostUsed(ply)
        print(ply, "used me!")
    end

    ArhComp.SubDevice.RegisterType("keyboard", SUBDEV)

end