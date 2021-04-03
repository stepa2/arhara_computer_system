if SERVER then
    local AllScreens = {}

    local SUBDEV = {}

    function SUBDEV:OnCreated(params)
        self.AllScreensI = #AllScreens + 1

        AllScreens[self.AllScreensI] = self

        self.Position = params.Position
        self.Normal = params.Normalize
        self.Size = params.Size

    end

    function SUBDEV:OnRemoved()
        AllScreens[self.AllScreensI] = nil
    end

    function SUBDEV:RenderDataDelta()

    end

    ArhComp.SubDevice.RegisterType("screen", SUBDEV)
end