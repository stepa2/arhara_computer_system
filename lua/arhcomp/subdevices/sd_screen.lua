if SERVER then
    local SUBDEV = {}

    function SUBDEV:OnCreated(params)
        print("Hello world")
    end

    function SUBDEV:OnRemoved()
        print("Goodbye world")
    end

    ArhComp.SubDevice.RegisterType("screen", SUBDEV)

end