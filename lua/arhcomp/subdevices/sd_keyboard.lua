if SERVER then
    local SUBDEV = {}

    function SUBDEV:OnCreated(params)
        print("Hello world")
    end

    function SUBDEV:OnRemoved()
        print("Goodbye world")
    end

    function SUBDEV:OnHostUsed(ply)
        print(ply, "used me!")
    end

    ArhComp.SubDevice.RegisterType("keyboard", SUBDEV)

end