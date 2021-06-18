if SERVER then
    local SUBDEV = {}

    function SUBDEV:OnCreated(params)
    end

    function SUBDEV:OnRemoved()
    end

    function SUBDEV:OnHostUsed(ply)
        print(ply, "used me!")
    end

    STPC.SubDevice.RegisterType("keyboard", SUBDEV)

end