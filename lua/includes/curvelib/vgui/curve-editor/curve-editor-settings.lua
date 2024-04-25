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

-- Instantiates and returns a new CurveEditorSettings with the default values
---@return CurveEditorSettings
function CurveEditorSettings()

    ---@class (exact) CurveEditorSettings
    ---@field Background CurveEditor.BackgroundSettings
    ---@field Curve CurveEditor.CurveSettings
    ---@field Points CurveEditor.PointSettings
    ---@field Handles CurveEditor.HandleSettings
    ---@field Axis CurveEditor.AxisSettings
    return {

        ---@class (exact) CurveEditor.BackgroundSettings
        ---@field Color Color The Curve Editor's background Color.
        Background = {
            Color = DefaultColors.Background
        },

        ---@class (exact) CurveEditor.CurveSettings
        ---@field Color Color The Curve's line color.
        ---@field Width number The Curve's line width, in pixels.
        Curve = {
            Color = DefaultColors.Curve,
            Width = 4
        },

        ---@class (exact) CurveEditor.PointSettings
        ---@field Color Color The Color for each of the Points on this Curve.
        ---@field Radius number The radius of the Curve Points on this curve, in pixels
        ---@field VertexDistance number How far apart each of the vertices of the Point's Circle should be, in pixels.  This effectively controls the smoothness of the Circle.  Lower values are smoother, higher values are coarser.
        Points = {
            Color = DefaultColors.Points,
            Radius = 10,
            VertexDistance = 2
        },

        ---@class (exact) CurveEditor.HandleSettings
        ---@field Color Color The Color for each of the Handles on this Curve.
        ---@field Radius number The radius of the Curve Handles on this curve, in pixels.
        ---@field VertexDistance number How far apart each of the vertices of the Handle's Circle should be, in pixels.  This effectively controls the smoothness of the Circle.  Lower values are smoother, higher values are coarser.
        ---@field Line CurveEditor.HandleLineSettings
        Handles = {
            Color = DefaultColors.Handles,
            Radius = 2.5,
            VertexDistance = 2,
            ---@class (exact) CurveEditor.HandleLineSettings
            ---@field Color Color The Color of the line that connects the Handle to the Point, in pixels.
            ---@field Width number The Width of the line that connects the Handle to the Point, in pixels.
            Line = {
                Color = DefaultColors.HandleLines,
                Width = 2
            }
        },

        ---@class (exact) CurveEditor.AxisSettings
        ---@field Horizontal table
        ---@field Vertical table
        Axis = {
            
            ---@class (exact) CurveEditor.AxisSettings.Horizontal
            ---@field Color Color The Color of the Horizontal Axis.
            ---@field Width number The Width of the Horizontal Axis, in pixels.
            ---@field Margins CurveEditor.AxisSettings.HorizontalMargins The Margins for the Horizontal Axis.
            ---@field Label CurveEditor.AxisSettings.HorizontalLabel The Label settings for the Horizontal Axis.
            ---@field NumberLine CurveEditor.AxisSettings.NumberLine The Number Line settings for the Horizontal Axis.
            Horizontal = {
                Color = DefaultColors.AxisLine,
                Width = 1,

                ---@class (exact) CurveEditor.AxisSettings.HorizontalMargins
                ---@field Bottom number How far from the bottom of the Curve Editor the Horizontal Axis will be, in pixels.
                ---@field Right number How far from the right of the Curve Editor the Horizontal Axis will end, in pixels.
                Margins = {
                    Bottom  = 65,
                    Right   = 30
                },

                ---@class (exact) CurveEditor.AxisSettings.HorizontalLabel
                ---@field Text string The text that will be displayed on the Horizontal Axis.
                ---@field Font string The Font that the Horizontal Axis Label will use.
                ---@field Color Color The Color of the Horizontal Axis Label.
                ---@field Rotation number The Rotation of the Horizontal Axis Label, in degrees.
                ---@field TopMargin number How far below the Horizontal Axis that the label will be, in pixels.
                Label = {
                    Text = DefaultLabels.Horizontal,
                    Font = DefaultFonts.AxisLabel,
                    Color = DefaultColors.AxisLabel,
                    Rotation = 0,
                    TopMargin = 20
                },

                ---@class (exact) CurveEditor.AxisSettings.NumberLine
                ---@field Fonts table The Fonts that the Number Line will use.
                ---@field TextColor Color The Color of the numbers on the Number Line.
                ---@field Margin number The margin between the Number Line and what it is labeling, in pixels.
                ---@field SpaceBetween number The distance between each number on the Horizontal Axis, in pixels.
                NumberLine = {
                    ---@class (exact) CurveEditor.AxisSettings.NumberLineFonts
                    ---@field LargeNumbers string The Font that the Large Numbers on the Number Line will use.
                    ---@field SmallNumnbers string The Font that the Small Numbers on the Number Line will use.
                    Fonts = {
                        LargeNumbers = DefaultFonts.NumberLineLarge,
                        SmallNumnbers = DefaultFonts.NumberLineSmall
                    },
                    TextColor = DefaultColors.AxisLabel,
                    Margin = 10,
                    SpaceBetween = 256
                }
            },

            ---@class (exact) CurveEditor.AxisSettings.Vertical
            ---@field Color Color The Color of the Vertical Axis.
            ---@field Width number The Width of the Vertical Axis, in pixels.
            ---@field Margins CurveEditor.AxisSettings.VerticalMargins The Margins for the Vertical Axis.
            ---@field Label CurveEditor.AxisSettings.VerticalLabel The Label settings for the Vertical Axis.
            ---@field NumberLine CurveEditor.AxisSettings.NumberLine The Number Line settings for the Vertical Axis.
            Vertical = {
                Color = DefaultColors.AxisLine,
                Width = 1,

                ---@class (exact) CurveEditor.AxisSettings.VerticalMargins
                ---@field Top number How far from the top of the Curve Editor the Vertical Axis will end, in pixels.
                ---@field Left number How far from the left of the Curve Editor the Vertical Axis will be, in pixels.
                Margins = {
                    Top     = 35,
                    Left    = 85
                },

                ---@class (exact) CurveEditor.AxisSettings.VerticalLabel
                ---@field Text string The text that will be displayed on the Vertical Axis.
                ---@field Font string The Font that the Vertical Axis Label will use.
                ---@field Color Color The Color of the Vertical Axis Label.
                ---@field Rotation number The Rotation of the Vertical Axis Label, in degrees.
                ---@field RightMargin number How far to the right of the Vertical Axis that the label will be, in pixels.
                Label = {
                    Text = DefaultLabels.Vertical,
                    Font = DefaultFonts.AxisLabel,
                    Color = DefaultColors.AxisLabel,
                    Rotation = -90,
                    RightMargin = 35
                },

                ---@type CurveEditor.AxisSettings.NumberLine
                NumberLine = {
                    ---@type CurveEditor.AxisSettings.NumberLineFonts
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