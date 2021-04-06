if SERVER then
    local SUBDEV = {}

    function SUBDEV:OnCreated(params)
        timer.Simple(1, function()
            local screen = ArhComp.SubDevice.GetByTypeAndName(self.Device, "screen", "screen")

            local obj = screen:RenderObjectAdd("polygon", { Vertexes = {
                { x = 16, y = 16 },
                { x = 16, y = 48 },
                { x = 48, y = 48}
            }, Color = Color(0, 255, 0)})

        end)
    end

    function SUBDEV:OnRemoved()
    end

    ArhComp.SubDevice.RegisterType("program_runner", SUBDEV)

end