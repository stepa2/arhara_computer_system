if SERVER then

    local SUBDEV = {}

    function SUBDEV:OnCreated(params)
        self.Surface = STPC.RenderLib.CreateSurface(self.Device, params.SurfaceTemplate, {
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

    -- if oldObj is not nil, oldObj will be replaced with this object
    -- vertexes are array of { X = number, Y = number, U = number, V = number}
    -- material can be nil
    function SUBDEV:RenderObjectAddPolygon(vertexes, color, material, oldObj)
        return self.Surface:RenderObjectAddPolygon(vertexes, color, material, oldObj)
    end

    -- if oldObj is not nil, oldObj will be replaced with this object
    function SUBDEV:RenderObjectAddText(pos, color, text, font, oldObj)
        return self.Surface:RenderObjectAddText(pos, color, text, font, oldObj)
    end

    function SUBDEV:RenderObjectRemove(object)
        self.Surface:RenderObjectRemove(object)
    end

    STPC.SubDevice.RegisterType("screen", SUBDEV)
end