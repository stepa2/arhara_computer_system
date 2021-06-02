if SERVER then
    local SUBDEV = {}

    function SUBDEV:OnCreated(params)
        timer.Simple(1, function()
            local screen = ArhComp.SubDevice.GetByTypeAndName(self.Device, "screen", "screen")

            local obj = screen:RenderObjectAddPolygon({
                { X = 16, Y = 16, Color = Color(255, 0, 0) },
                { X = 16, Y = 48, Color = Color(0, 255, 0) },
                { X = 48, Y = 48, Color = Color(0, 0, 255) }
            }, nil) -- Material

        end)
    end

    function SUBDEV:OnRemoved()
    end

    ArhComp.SubDevice.RegisterType("program_runner", SUBDEV)

end