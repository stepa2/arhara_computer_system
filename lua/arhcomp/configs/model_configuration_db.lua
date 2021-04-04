local SurfTemp_ScreenCombineSolid = ArhComp.RenderLib.RegisterSurfaceTemplate(
    "screen_combine_solid", "UnlitTwoTexture", true, -- Opaque
    function(rt) return {
        ["$model"] = 1,
        ["$basetexture"] = rt,
        ["$texture2"] = "models/props_combine/combinescanline",
        ["$selfillum"] = 1,
        ["$mod2x"] = 1,

        Proxies = {
            --[[Sine = {
                resultVar = "$color[0]",
                sineperiod = 0.2,
                sinemin = 0.99,
                sinemax = 1
            },
            Sine = {
                resultVar = "$color[1]",
                sineperiod = 0.12,
                sinemin = 0.98,
                sinemax = 1
            },
            Sine = {
                resultVar = "$color[2]",
                sineperiod = 0.1,
                sinemin = 0.99,
                sinemax = 1
            },]]
            TextureScroll = {
                texturescrollvar = "$texture2transform",
                texturescrollrate = 1,
                texturescrollangle = -90
            }
        }
    } end)

local function TransformAngle(angIn)
    local AxisX = -angIn:Right()
    local AxisY = -angIn:Up()
    return AxisX:AngleEx(AxisX:Cross(-AxisY))
end

ArhComp.RegisterDevice(bit.bor(
    ArhComp.DeviceCapabilities.COMPUTER,
    ArhComp.DeviceCapabilities.MONITOR,
    ArhComp.DeviceCapabilities.KEYBOARD),
    {
        Name = "combine_interface_mid",
        PrimaryCapability = ArhComp.DeviceCapabilities.COMPUTER,
        Model = "models/props_combine/combine_interface002.mdl",
        SubDevices = {
            keyboard = {
                Type = "keyboard"
            },
            screen = {
                Type = "screen",
                SurfaceTemplate = SurfTemp_ScreenCombineSolid,

                Position = Vector( -1.8, -14.5, 47.5 ),
                Angle = TransformAngle(Angle(312, 0, 0)), --Angle( 313.75, 357.39, 0 ):Up():Angle(),
                Size = { X = 26, Y = 5.4 },
                SurfPixelPerWorld = 16--16
            }
        }
})

