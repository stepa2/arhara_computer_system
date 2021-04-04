if SERVER then
    local AllScreens = {}

    local SUBDEV = {}

    function SUBDEV:OnCreated(params)
        self.AllScreensI = #AllScreens + 1

        AllScreens[self.AllScreensI] = self

        self.Surface = ArhComp.RenderLib.CreateSurface(self.Device, params.SurfaceTemplate, {
            Pos = params.Position,
            Normal = params.Normal,
            Opaque = params.Opaque,
            SurfSize = params.Size 
        })
    end

    function SUBDEV:OnRemoved()
        AllScreens[self.AllScreensI] = nil
        self.Surface:Free()
    end



    ArhComp.SubDevice.RegisterType("screen", SUBDEV)
end