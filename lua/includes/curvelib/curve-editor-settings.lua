AddCSLuaFile()
if SERVER then return end
require( "vguihotload" )

local DefaultLabels = {
    Horizontal = "Time",
    Vertical = "Position"
}

local DefaultColors = {
    Background      = Color(  60,  68,  75 ),
    AxisLine        = Color( 200, 200, 200 ),
    AxisGridLine    = Color( 100, 100, 100 ),
    AxisLabel       = Color( 200, 200, 200 ),
    Curve           = Color( 200, 200, 250 ),
    Points          = Color( 78, 80, 255 ),
    Handles         = Color( 55, 67, 180 ),
    HandleLines     = Color( 200, 200, 200 )
}

local DefaultFonts = {
    AxisLabel       = "CurveEditor_AxisLabel",
    NumberLineLarge = "CurveEditor_NumberLine_Large",
    NumberLineSmall = "CurveEditor_NumberLine_Small"
}

surface.CreateFont( DefaultFonts.AxisLabel, {
    font = "Roboto Regular",
    extended = false,
    size = 28,
    weight = 500,
} )

surface.CreateFont( DefaultFonts.NumberLineLarge, {
    font = "Roboto Regular",
    extended = false,
    size = 24,
    weight = 500,
} )

surface.CreateFont( DefaultFonts.NumberLineSmall, {
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
            Color = DefaultColors.Background
        },

        Curve = {
            Color = DefaultColors.Curve,
            Width = 4
        },

        Points = {
            Color = DefaultColors.Points,
            Radius = 5
        },

        Handles = {
            Color = DefaultColors.Handles,
            Radius = 2.5,
            Line = {
                Color = DefaultColors.HandleLines,
                Width = 2
            }
        },

        Axis = {
            Horizontal = {
                Color = DefaultColors.AxisLine,
                Width = 1,
                Margins = {
                    Bottom  = 65,
                    Right   = 30
                },
                Label = {
                    Text = DefaultLabels.Horizontal,
                    Font = DefaultFonts.AxisLabel,
                    Color = DefaultColors.AxisLabel,
                    Rotation = 0,
                    TopMargin = 20
                },
                NumberLine = {
                    Fonts = {
                        LargeNumbers = DefaultFonts.NumberLineLarge,
                        SmallNumnbers = DefaultFonts.NumberLineSmall
                    },
                    TextColor = DefaultColors.AxisLabel,
                    Margin = 10,
                    SpaceBetween = 256
                }
            },

            Vertical = {
                Color = DefaultColors.AxisLine,
                Width = 1,
                Margins = {
                    Top     = 35,
                    Left    = 85
                },
                Label = {
                    Text = DefaultLabels.Vertical,
                    Font = DefaultFonts.AxisLabel,
                    Color = DefaultColors.AxisLabel,
                    Rotation = -90,
                    RightMargin = 35
                },
                NumberLine = {
                    Fonts = {
                        LargeNumbers = DefaultFonts.NumberLineLarge,
                        SmallNumnbers = DefaultFonts.NumberLineSmall
                    },
                    TextColor = DefaultColors.AxisLabel,
                    Margin = 10,
                    SpaceBetween = 256
                }
            }
        }
    }
end

vguihotload.HandleHotload( "CurveEditor" )