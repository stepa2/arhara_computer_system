if SERVER then
    local SUBDEV = {}

    function SUBDEV:OnCreated(params)
        timer.Simple(1, function()
            local screen = STPC.SubDevice.GetByTypeAndName(self.Device, "screen", "screen")

            local obj = screen:RenderObjectAddPolygon({
                { X = 16, Y = 16, U = 0, V = 0 },
                { X = 48, Y = 16, U = 0, V = 0 },
                { X = 48, Y = 48, U = 0, V = 0 }
            }, Color(255,255,255), nil) -- Material

        end)
    end

    function SUBDEV:OnRemoved()
    end

    STPC.SubDevice.RegisterType("program_runner", SUBDEV)

end