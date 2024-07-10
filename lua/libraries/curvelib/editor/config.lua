require( "vguihotload" )

---@type CurveLib.Editor.Utils
local curveUtils = include( "libraries/curvelib/editor/utils.lua" )

--#region Default Values

local DefaultLabels = {
    Horizontal = "Time",
    Vertical = "Position"
}

local DefaultColors = {
    AxisLine            = Color(  50,  50,  50 ),
    AxisGridLine        = Color( 100, 100, 100 ),
    AxisLabel           = Color( 200, 200, 200 ),
    Curve               = Color( 100, 100, 150 ),
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
    AxisLabel       = "CurveLib_AxisLabel",
    NumberLineLargeText = "CurveLib_NumberLine_Large",
    NumberLineSmallText = "CurveLib_NumberLine_Small"
}

local DefaultFormatStrings = {
    TwoDecimals = "%.2f"
}

--#region Fonts

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

--#endregion Fonts

--#endregion Default Values

--#region Class Definitions

-- Editor Config  
-- The settings for this Curve Editor.
---@class (exact) CurveLib.Editor.Config
---@field GraphConfig   CurveLib.Editor.Config.Graph
---@field SidebarConfig CurveLib.Editor.Config.Sidebar
---@field ToolbarConfig CurveLib.Editor.Config.Toolbar
---@field __index table

--#region Graph Settings

-- The settings for the Graph
---@class (exact) CurveLib.Editor.Config.Graph
---@field BackgroundColor Color
---@field Borders CurveLib.Editor.Config.Graph.Borders
---@field Handles CurveLib.Editor.Config.Graph.Handles
---@field Curve CurveLib.Editor.Config.Graph.Curve
---@field Axes CurveLib.Editor.Config.Graph.Axes
---@field Caches table The cache of all data that is stored for the Graph.

-- The edges of the Graph that do not have Axes on them.
---@class (exact) CurveLib.Editor.Config.Graph.Borders
---@field Right CurveLib.Editor.Config.Graph.Border
---@field Top CurveLib.Editor.Config.Graph.Border

-- A single, non-Axis edge of the Graph
---@class (exact) CurveLib.Editor.Config.Graph.Border
---@field Enabled boolean
---@field Thickness integer The width, in pixels, of the border.
---@field Color Color 

-- The Handles of the Graph
---@class (exact) CurveLib.Editor.Config.Graph.Handles
---@field Main CurveLib.Editor.Config.Graph.Handles.Handle
---@field Side CurveLib.Editor.Config.Graph.Handles.Handle
---@field Line CurveLib.Editor.Config.Graph.HandleLine

-- A single Handle on the Graph
---@class (exact) CurveLib.Editor.Config.Graph.Handles.Handle
---@field Idle CurveLib.Editor.Config.Graph.Handles.Handle.State The configuration of the Handle when it is not being hovered over or dragged.
---@field Hovered CurveLib.Editor.Config.Graph.Handles.Handle.State The configuration of the Handle when it is being hovered over.
---@field Dragged CurveLib.Editor.Config.Graph.Handles.Handle.State The configuration of the Handle when it is being dragged.

-- A Handle's configuration for a given state.
---@class (exact) CurveLib.Editor.Config.Graph.Handles.Handle.State
---@field Radius integer The radius, in pixels, of the Handle.
---@field RadiusChangeRate number The speed at which the Handle's radius changes when to this state.
---@field Color Color The Color of the Handle.
---@field ColorChangeRate number The speed at which the Handle's color changes when transitioning to this state.

-- The line that connects two Handles on the Graph
---@class (exact) CurveLib.Editor.Config.Graph.HandleLine
---@field Color Color The Color of the Handle Line.
---@field Thickness integer The width, in pixels, of the Handle Line.

-- Settings for the curve of the Graph.
---@class (exact) CurveLib.Editor.Config.Graph.Curve
---@field Color Color The Color of the curve line.
---@field Thickness integer The width, in pixels, of the curve line.
---@field VertexCount integer The number of vertices to use when drawing the curve.
---@field HoverSize integer The size, in pixels, of the area around the curve that should be considered "hovering" on it.
---@field Hover CurveLib.Editor.Config.Graph.Curve.Hover

-- Settings for the Curve hover indicator
---@class (exact) CurveLib.Editor.Config.Graph.Curve.Hover
---@field Color Color The Color of the hover indicator.
---@field Thickness integer The width, in pixels, of the hover indicator.
---@field Length integer The length, in pixels, of the hover indicator.

---@class (exact) CurveLib.Editor.Config.Graph.Axes
---@field Horizontal CurveLib.Editor.Config.Graph.Axes.Axis
---@field Vertical CurveLib.Editor.Config.Graph.Axes.Axis

-- A single Axis on the Graph
---@class (exact) CurveLib.Editor.Config.Graph.Axes.Axis
---@field Color Color The Color of the Axis line.
---@field Thickness integer The width, in pixels, of the Axis' line.
---@field EndMargin integer The amount of padding, in pixels, between the end of the Axis and the edge of the Panel that the Axis points towards.
---@field Label CurveLib.Editor.Config.Graph.Axes.Axis.Label
---@field NumberLine CurveLib.Editor.Config.Graph.Axes.Axis.NumberLine

-- The text next to a Graph Axis indicating what that Axis represents.
---@class (exact) CurveLib.Editor.Config.Graph.Axes.Axis.Label
---@field Text string
---@field Font string The name of the created font to use.
---@field Color Color
---@field Rotation number How far, in degrees, to rotate the Axis Label.
---@field EdgeMargin integer How far away, in pixels, the Axis Label should be from the nearest edge of the Panel.

-- The numbers adjacent to a Graph Axis that indicate that Axis' coordinate range.
---@class (exact) CurveLib.Editor.Config.Graph.Axes.Axis.NumberLine
---@field StartingValue number The value to be shown at the start of this Number Line. Default: 0
---@field EndingValue number The value to be shown at the end of this Number Line. Default: 100
---@field FormatString string The `printf` format string to use when displaying the Number Line. Default: A float with 2 decimal points.
---@field MaxNumberCount integer The maximum amount of numbers the number line should display (Not including the starting and ending numbers)
---@field LargeTextFont string The created font name to use for numbers at the extremes of the Number Line.
---@field LargeTextColor Color
---@field SmallTextFont string The created font name used for the numbers in-between the extremes of the Number Line.
---@field SmallTextColor Color
---@field AxisMargin integer The distance, in pixels, between the edge of the Axis line and the numbers of the Number Line.
---@field LabelMargin integer How far, in pixels, the Number Line's numbers should be from the Axis' Label

--#endregion Graph Settings

--#region Sidebar Config

-- Sidebar Config
---@class (exact) CurveLib.Editor.Config.Sidebar
---@field BackgroundColor Color

--#endregion Sidebar Config

--#region Toolbar Config

-- Toolbar Config
---@class (exact) CurveLib.Editor.Config.Toolbar
---@field BackgroundColor Color

--#endregion Toolbar Config

--#endregion Class Definitions

--#region Implementations

--#region Graph Config

---@class CurveLib.Editor.Config.Graph
local GRAPH = {
    BackgroundColor = DefaultColors.GraphBackground,

    Borders = {
        Right = {
            Enabled = true,
            Thickness = 3,
            Color = DefaultColors.AxisLine
        },
        Top = {
            Enabled = true,
            Thickness = 3,
            Color = DefaultColors.AxisLine
        }
    },

    Handles = {
        Main = {
            Idle = {
                Color = DefaultColors.Handle,
                ColorChangeRate = 100,
                Radius = 10,
                RadiusChangeRate = 100
            },
            Hovered = {
                Color = DefaultColors.Handle,
                ColorChangeRate = 100,
                Radius = 15,
                RadiusChangeRate = 100
            },
            Dragged = {
                Color = DefaultColors.Handle,
                ColorChangeRate = 100,
                Radius = 17,
                RadiusChangeRate = 100
            }
        },
        Side = {
            Idle = {
                Color = DefaultColors.Handle,
                ColorChangeRate = 100,
                Radius = 7,
                RadiusChangeRate = 100
            },
            Hovered = {
                Color = DefaultColors.Handle,
                ColorChangeRate = 100,
                Radius = 10,
                RadiusChangeRate = 100
            },
            Dragged = {
                Color = DefaultColors.Handle,
                ColorChangeRate = 100,
                Radius = 12,
                RadiusChangeRate = 100
            }
        },
        Line = {
            Color = DefaultColors.HandleLine,
            Thickness = 3
        }
    },

    Curve = {
        Color = DefaultColors.Curve,
        Thickness = 8,
        VertexCount = 100,
        HoverSize = 10,
        Hover = {
            Color = DefaultColors.Point,
            Thickness = 3,
            Length = 10
        }
    },

    Axes = {
        Horizontal = {
            Color = DefaultColors.AxisLine,
            Thickness = 3,
            EndMargin = 30,
            Label = {
                Text = DefaultLabels.Horizontal,
                Color = DefaultColors.AxisLabel,
                Rotation = 0,
                EdgeMargin = 10,
                Font = DefaultFonts.AxisLabel,
            },
            NumberLine = {
                StartingValue = 0,
                EndingValue = 100,
                FormatString = DefaultFormatStrings.TwoDecimals,
                MaxNumberCount = 3,
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
            Thickness = 3,
            EndMargin = 20,
            Label = {
                Text = DefaultLabels.Vertical,
                Color = DefaultColors.AxisLabel,
                Rotation = 0,
                EdgeMargin = 10,
                Font = DefaultFonts.AxisLabel,
            },
            NumberLine = {
                StartingValue = 0,
                EndingValue = 100,
                FormatString = DefaultFormatStrings.TwoDecimals,
                MaxNumberCount = 3,
                LargeTextFont   = DefaultFonts.NumberLineLargeText,
                LargeTextColor  = DefaultColors.NumberLineLargeText,
                SmallTextFont   = DefaultFonts.NumberLineSmallText,
                SmallTextColor  = DefaultColors.NumberLineSmallText,
                AxisMargin  = 10,
                LabelMargin = 10
            }
        }
    },

    ---@class (exact) CurveLib.Editor.Config.Graph.Caches
    ---@field LabelSize { Width: integer, Height: integer }
    ---@field NumberLineTextSize { Large: { Width: integer, Height: integer }, Small: { Width: integer, Height: integer } }
    Caches = {}
}

--#region Cache Functions

function GRAPH:ClearAllCaches()
    self.Caches = {}
end


function GRAPH:ClearNumberLineTextSizeCache()
    self.Caches.NumberLineTextSize = nil
end


function GRAPH:ClearLabelSizeCache()
    self.Caches.LabelSize = nil
end

--#endregion Cache Functions

-- Returns the size of the text used for the Number Line on a given Axis
---@param numberLine CurveLib.Editor.Config.Graph.Axes.Axis.NumberLine
---@return integer largeTextWidth
---@return integer largeTextHeight
---@return integer smallTextWidth
---@return integer smallTextHeight
function GRAPH:GetNumberLineTextSize( numberLine )
    if not self.Caches.NumberLineTextSize then self.Caches.NumberLineTextSize = {} end

    if not self.Caches.NumberLineTextSize[numberLine] then

        surface.SetFont( numberLine.LargeTextFont )
        local largeTextWidth, largeTextHeight = surface.GetTextSize( string.format( numberLine.FormatString, numberLine.StartingValue ) )
        surface.SetFont( numberLine.SmallTextFont )
        local smallTextWidth, smallTextHeight = surface.GetTextSize( string.format( numberLine.FormatString, numberLine.StartingValue ) )

        self.Caches.NumberLineTextSize[numberLine] = {
            Large = { Width = largeTextWidth, Height = largeTextHeight },
            Small = { Width = smallTextWidth, Height = smallTextHeight }
        }
    end

    local largeSize = self.Caches.NumberLineTextSize[numberLine].Large
    local smallSize = self.Caches.NumberLineTextSize[numberLine].Small
    return largeSize.Width, largeSize.Height, smallSize.Width, smallSize.Height
end


-- Returns the size of a given Axis' label text
---@param self CurveLib.Editor.Config.Graph
---@param axis CurveLib.Editor.Config.Graph.Axes.Axis
function GRAPH:GetLabelSize( axis )
    if not self.Caches.LabelSize then self.Caches.LabelSize = {} end
    
    if not self.Caches.LabelSize[axis] then
        local LabelSizeCache = {}
        self.Caches.LabelSize = LabelSizeCache

        surface.SetFont( axis.Label.Font )
        local labelTextWidth, labelTextHeight = surface.GetTextSize( axis.Label.Text )
        local topRight, bottomRight, bottomLeft, topLeft = curveUtils.GetRectangleCornerOffsets( labelTextWidth, labelTextHeight, axis.Label.Rotation )

        local minX = math.min( topRight.x, bottomRight.x, bottomLeft.x, topLeft.x )
        local maxX = math.max( topRight.x, bottomRight.x, bottomLeft.x, topLeft.x )
        local minY = math.min( topRight.y, bottomRight.y, bottomLeft.y, topLeft.y )
        local maxY = math.max( topRight.y, bottomRight.y, bottomLeft.y, topLeft.y )

        LabelSizeCache[axis] = { Width = ( maxX - minX ), Height = ( maxY - minY ) }
    end

    local size = self.Caches.LabelSize[axis]
    return size.Width, size.Height
end

--#endregion Graph Config

--#region Sidebar Config

---@class CurveLib.Editor.Config.Sidebar
local SIDEBAR = {
    BackgroundColor = DefaultColors.SidebarBackground
}

--#endregion Sidebar Config

--#region Toolbar Config

---@class CurveLib.Editor.Config.Toolbar
local TOOLBAR = {
    BackgroundColor = DefaultColors.ToolbarBackground
}

--#endregion Toolbar Config

--#endregion Implementations

--#region Metatables

---@type CurveLib.Editor.Config
local DefaultConfig = {
    GraphConfig = GRAPH,
    SidebarConfig = SIDEBAR,
    ToolbarConfig = TOOLBAR
}


-- The metatable that provides default values to these config tables
---@class (exact) CurveLib.Editor.Config
local ConfigMetatable = {}
ConfigMetatable.__index = DefaultConfig

--#endregion Metatables

-- Creates a new Curve Editor Graph Config table with the default settings
---@return CurveLib.Editor.Config
function CurveEditorGraphConfig()
    local config = {}
    setmetatable( config, ConfigMetatable )
    return config
end

vguihotload.HandleHotload( "CurveLib.Editor.Frame" )