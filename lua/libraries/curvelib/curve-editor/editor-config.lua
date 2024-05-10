require( "vguihotload" )

local DefaultLabels = {
    Horizontal = "Time",
    Vertical = "Position"
}

local DefaultColors = {
    
    AxisLine            = Color( 200, 200, 200 ),
    AxisGridLine        = Color( 100, 100, 100 ),
    AxisLabel           = Color( 200, 200, 200 ),
    Curve               = Color( 200, 200, 250 ),
    Point               = Color(  78,  80, 255 ),
    Handle              = Color(  55,  67, 180 ),
    HandleLine          = Color( 200, 200, 200 ),

    NumberLineLargeText = Color(   0,   0,   0 ),
    NumberLineSmallText = Color( 100, 100, 100 ),

    GraphBackground     = Color( 200, 200, 200 ),
    SidebarBackground   = Color( 175, 175, 175 ),
    ToolbarBackground   = Color( 150, 150, 150 )
}

local DefaultFonts = {
    AxisLabel       = "CurveEditor_AxisLabel",
    NumberLineLargeText = "CurveEditor_NumberLine_Large",
    NumberLineSmallText = "CurveEditor_NumberLine_Small"
}

surface.CreateFont( DefaultFonts.AxisLabel, {
    font = "Roboto Regular",
    extended = false,
    size = 28,
    weight = 500,
} )

surface.CreateFont( DefaultFonts.NumberLineLargeText, {
    font = "Roboto Regular",
    extended = false,
    size = 24,
    weight = 500,
} )

surface.CreateFont( DefaultFonts.NumberLineSmallText, {
    font = "Roboto Regular",
    extended = false,
    size = 16,
    weight = 500,
} )

-- Editor Config  
-- The visual settings for this Curve Editor.
---@class (exact) CurveEditor.EditorConfig
---@field GraphConfig   CurveEditor.EditorConfig.GraphConfig
---@field SidebarConfig CurveEditor.EditorConfig.SidebarConfig
---@field ToolbarConfig CurveEditor.EditorConfig.ToolbarConfig

    -- The visual settings for this Curve Editor's Graph.
    ---@class (exact) CurveEditor.EditorConfig.GraphConfig
    ---@field BackgroundColor Color
    ---@field Axes CurveEditor.EditorConfig.GraphConfig.Axes

        ---@class (exact) CurveEditor.EditorConfig.GraphConfig.Axes
        ---@field Horizontal CurveEditor.EditorConfig.GraphConfig.Axes.Axis
        ---@field Vertical CurveEditor.EditorConfig.GraphConfig.Axes.Axis

            -- A single Axis on the Graph
            ---@class (exact) CurveEditor.EditorConfig.GraphConfig.Axes.Axis
            ---@field Color Color The Color of the Axis line.
            ---@field Width integer The width, in pixels, of the Axis' line.
            ---@field EndMargin integer The amount of padding, in pixels, between the end of the Axis and the edge of the Panel that the Axis points towards.
            ---@field Label CurveEditor.EditorConfig.GraphConfig.Axes.Axis.Label
            ---@field NumberLine CurveEditor.EditorConfig.GraphConfig.Axes.Axis.NumberLine

                -- The text next to a Graph Axis indicating what that Axis represents.
                ---@class (exact) CurveEditor.EditorConfig.GraphConfig.Axes.Axis.Label
                ---@field Text string
                ---@field Font string The name of the created font to use.
                ---@field Color Color
                ---@field Rotation number How far, in degrees, to rotate the Axis Label.
                ---@field EdgeMargin integer How far away, in pixels, the Axis Label should be from the nearest edge of the Panel.

                -- The numbers adjacent to a Graph Axis that indicate that Axis' coordinate range.
                ---@class (exact) CurveEditor.EditorConfig.GraphConfig.Axes.Axis.NumberLine
                ---@field LargeTextFont string The created font name to use for numbers at the extremes of the Number Line.
                ---@field LargeTextColor Color
                ---@field SmallTextFont string The created font name used for the numbers in-between the extremes of the Number Line.
                ---@field SmallTextColor Color
                ---@field AxisMargin integer The distance, in pixels, between the edge of the Axis line and the numbers of the Number Line.
                ---@field LabelMargin integer How far, in pixels, the Number Line's numbers should be from the Axis' Label

    -- Sidebar Config
    ---@class (exact) CurveEditor.EditorConfig.SidebarConfig
    ---@field BackgroundColor Color

    -- Toolbar Config
    ---@class (exact) CurveEditor.EditorConfig.ToolbarConfig
    ---@field BackgroundColor Color

---@type CurveEditor.EditorConfig
local DefaultConfig = {
    GraphConfig = {
        BackgroundColor = DefaultColors.GraphBackground,
        Axes = {
            Horizontal = {
                Color = DefaultColors.AxisLine,
                Width = 3,
                EndMargin = 10,
                Label = {
                    Text = "X",
                    Color = DefaultColors.AxisLabel,
                    Rotation = 0,
                    EdgeMargin = 10,
                    Font = DefaultFonts.AxisLabel,
                },
                NumberLine = {
                    LargeTextFont   = DefaultFonts.NumberLineLargeText,
                    LargeTextColor  = DefaultColors.NumberLineLargeText,
                    SmallTextFont   = DefaultFonts.NumberLineSmallText,
                    SmallTextColor  = DefaultColors.NumberLineSmallText,
                    AxisMargin  = 10,
                    LabelMargin = 10
                }
            },
            Vertical = {
                Color = DefaultColors.AxisLine,
                Width = 3,
                EndMargin = 10,
                Label = {
                    Text = "Y",
                    Color = DefaultColors.AxisLabel,
                    Rotation = 0,
                    EdgeMargin = 10,
                    Font = DefaultFonts.AxisLabel,
                },
                NumberLine = {
                    LargeTextFont   = DefaultFonts.NumberLineLargeText,
                    LargeTextColor  = DefaultColors.NumberLineLargeText,
                    SmallTextFont   = DefaultFonts.NumberLineSmallText,
                    SmallTextColor  = DefaultColors.NumberLineSmallText,
                    AxisMargin  = 10,
                    LabelMargin = 10
                }
            }
        }
    },
    SidebarConfig = {
        BackgroundColor = DefaultColors.SidebarBackground
    },
    ToolbarConfig = {
        BackgroundColor = DefaultColors.ToolbarBackground
    }
}

-- The metatable that provides default values to these config tables
local ConfigMetatable = {}
ConfigMetatable.__index = DefaultConfig

-- Creates a new Curve Editor Graph Config table with the default settings
---@return CurveEditor.EditorConfig
function CurveEditorGraphConfig()
    local config = {}
    setmetatable( config, ConfigMetatable )
    return config
end

vguihotload.HandleHotload( "CurveLib.EditorFrame" )