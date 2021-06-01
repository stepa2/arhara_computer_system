if SERVER then

    local SUBDEV = {}

    function SUBDEV:OnCreated(params)
        self.Surface = ArhComp.RenderLib.CreateSurface(self.Device, params.SurfaceTemplate, {
            Pos = params.Position,
            Angle = params.Angle,
            Opaque = params.Opaque,
            SurfSize = params.Size,
            SurfPixelPerWorld = params.SurfPixelPerWorld
        })
    end

    function SUBDEV:OnRemoved()
        self.Surface:Free()
    end

    function SUBDEV:RenderObjectAdd(type, params)
        return self.Surface:RenderObjectAdd(type, params)
    end

    function SUBDEV:RenderObjectUpdated(object_index)
        self.Surface:RenderObjectUpdated(object_index)
    end

    function SUBDEV:RenderObjectRemove(object_index)
        self.Surface:RenderObjectRemove(object_index)
    end

    ArhComp.SubDevice.RegisterType("screen", SUBDEV)
end