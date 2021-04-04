if SERVER then
    local AllScreens = {}

    local SUBDEV = {}

    function SUBDEV:OnCreated(params)
        self.AllScreensI = #AllScreens + 1

        AllScreens[self.AllScreensI] = self

        self.Position = params.Position
        self.Normal = params.Normal
        self.Size = params.Size
        self.Opaque = params.Opaque

        self.Surface = ArhComp.RenderLib.CreateSurface(self.Device, params.SurfaceTemplate)
    end

    function SUBDEV:OnRemoved()
        AllScreens[self.AllScreensI] = nil
        self.Surface:Free()
    end



    ArhComp.SubDevice.RegisterType("screen", SUBDEV)
end