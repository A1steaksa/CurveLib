AddCSLuaFile()
if SERVER then return end

local Colors = {
    Background      = Color(  60,  60,  60 ),
    AxisLine        = Color( 200, 200, 200 ),
    AxisGridLine    = Color( 100, 100, 100 ),
    AxisLabel       = Color( 200, 200, 200 )
}

local Fonts = {
    AxisLabel       = "CurveEditor_AxisLabel",
    NumberLineLarge = "CurveEditor_NumberLine_Large",
    NumberLineSmall = "CurveEditor_NumberLine_Large"
}

surface.CreateFont( Fonts.AxisLabel, {
    font = "Roboto Regular",
    extended = false,
    size = 28,
    weight = 500,
} )

surface.CreateFont( Fonts.NumberLineLarge, {
    font = "Roboto Regular",
    extended = false,
    size = 24,
    weight = 500,
} )

surface.CreateFont( Fonts.NumberLineSmall, {
    font = "Roboto Regular",
    extended = false,
    size = 16,
    weight = 500,
} )

---@class CurveEditorSettings
---@field Axis table

--- Instantiates and returns a new CurveEditorSettings with the default values
function CurveEditorSettings()
    return {
        Background = {
            Color = Colors.Background
        },

        Curve = {

        },

        Points = {
            Radius = 5
        },

        Handles = {
            Radius = 2.5
        },

        Axis = {
            Horizontal = {
                Width = 1,
                Margins = {
                    Bottom  = 65,
                    Right   = 30
                },
                Label = {
                    Text = "Time",
                    Font = Fonts.AxisLabel,
                    Color = Colors.AxisLabel,
                    Rotation = 0,
                    TopMargin = 25
                },
                NumberLine = {
                    Margins = {
                        LargeText = 23,
                        SmallText = 18
                    },
                    SpaceBetween = 256
                }
            },

            Vertical = {
                Width = 1,
                Margins = {
                    Top     = 35,
                    Left    = 85
                },
                Label = {
                    Text = "Position",
                    Font = Fonts.AxisLabel,
                    Color = Colors.AxisLabel,
                    Rotation = -90,
                    RightMargin = 40
                },
                NumberLine = {
                    Margins = {
                        LargeText = 23,
                        SmallText = 18
                    },
                    SpaceBetween = 256
                }
            }
        }
    }
end