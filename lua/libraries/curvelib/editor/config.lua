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
    SidebarBackground   = Color( 175, 175, 175 )
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

--#region Graph Settings

-- The settings for the Graph
---@class (exact) CurveLib.Editor.Config.Graph
---@field BackgroundColor Color
---@field DragDistanceThreshold integer The distance, in pixels, that the cursor must move while the mouse button is pressed over a Handle before it is considered "dragged".
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
---@field SelectedOutlineThickness integer The thickness, in pixels, of the outline that appears around a Handle when it is selected.
---@field SelectedOutlineColor Color The color of the outline that appears around a Handle when it is selected.
---@field Main CurveLib.Editor.Config.Graph.Handles.Handle
---@field Side CurveLib.Editor.Config.Graph.Handles.Handle
---@field Line CurveLib.Editor.Config.Graph.HandleLine

---@alias HandleConfig CurveLib.Editor.Config.Graph.Handles.Handle

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

--#endregion Class Definitions

--#region Default Class Implementations

--#region Default Graph Config

---@alias GraphConfig CurveLib.Editor.Config.Graph

---@class CurveLib.Editor.Config.Graph
local GRAPH = {
    BackgroundColor = DefaultColors.GraphBackground,
    DragDistanceThreshold = 3,

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
        SelectedOutlineThickness = 3,
        SelectedOutlineColor = Color( 255, 255, 255 ),
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
        HoverSize = 8,
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

--#region Graph Config Functions

-- Returns the background color of the Graph
---@return Color
function GRAPH:GetBackgroundColor()
    return self.BackgroundColor
end

-- Sets the background color of the Graph
---@param color Color
function GRAPH:SetBackgroundColor( color )
    self.BackgroundColor = color
end

--#region Border Functions

-- Returns whether the right border of the Graph is enabled
---@return boolean
function GRAPH:GetRightBorderEnabled()
    return self.Borders.Right.Enabled
end

-- Sets whether the right border of the Graph is enabled
---@param enabled boolean
function GRAPH:SetRightBorderEnabled( enabled )
    self.Borders.Right.Enabled = enabled
end

-- Returns the thickness of the right border of the Graph
---@return integer
function GRAPH:GetRightBorderThickness()
    return self.Borders.Right.Thickness
end

-- Sets the thickness of the right border of the Graph
---@param thickness integer
function GRAPH:SetRightBorderThickness( thickness )
    self.Borders.Right.Thickness = thickness
end

-- Returns the color of the right border of the Graph
---@return Color
function GRAPH:GetRightBorderColor()
    return self.Borders.Right.Color
end

-- Sets the color of the right border of the Graph
---@param color Color
function GRAPH:SetRightBorderColor( color )
    self.Borders.Right.Color = color
end

-- Returns whether the top border of the Graph is enabled
---@return boolean
function GRAPH:GetTopBorderEnabled()
    return self.Borders.Top.Enabled
end

-- Sets whether the top border of the Graph is enabled
---@param enabled boolean
function GRAPH:SetTopBorderEnabled( enabled )
    self.Borders.Top.Enabled = enabled
end

-- Returns the thickness of the top border of the Graph
---@return integer
function GRAPH:GetTopBorderThickness()
    return self.Borders.Top.Thickness
end

-- Sets the thickness of the top border of the Graph
---@param thickness integer
function GRAPH:SetTopBorderThickness( thickness )
    self.Borders.Top.Thickness = thickness
end

-- Returns the color of the top border of the Graph
---@return Color
function GRAPH:GetTopBorderColor()
    return self.Borders.Top.Color
end

-- Sets the color of the top border of the Graph
---@param color Color
function GRAPH:SetTopBorderColor( color )
    self.Borders.Top.Color = color
end

--#endregion Border Functions

--#region Handle Functions

-- Returns the distance, in pixels, that the cursor must move while the mouse button is pressed before it is considered "dragged".
---@return integer
function GRAPH:GetDragDistanceThreshold()
    return self.DragDistanceThreshold
end

-- Sets the distance, in pixels, that the cursor must move while the mouse button is pressed before it is considered "dragged".
---@param distance integer
function GRAPH:SetDragDistanceThreshold( distance )
    self.DragDistanceThreshold = distance
end

-- Returns the thickness, in pixels, of the outline that appears around a Handle when it is selected.
---@return integer
function GRAPH:GetSelectedOutlineThickness()
    return self.Handles.SelectedOutlineThickness
end

-- Sets the thickness, in pixels, of the outline that appears around a Handle when it is selected.
---@param thickness integer
function GRAPH:SetSelectedOutlineThickness( thickness )
    self.Handles.SelectedOutlineThickness = thickness
end

-- Returns the color of the outline that appears around a Handle when it is selected.
---@return Color
function GRAPH:GetSelectedOutlineColor()
    return self.Handles.SelectedOutlineColor
end

-- Sets the color of the outline that appears around a Handle when it is selected.
---@param color Color
function GRAPH:SetSelectedOutlineColor( color )
    self.Handles.SelectedOutlineColor = color
end

--#region Main Handle Functions

--#region Main Handle Idle Functions

-- Returns the color of the Main Handle when it is in the Idle state.
---@return Color
function GRAPH:GetMainHandleIdleColor()
    return self.Handles.Main.Idle.Color
end

-- Sets the color of the Main Handle when it is in the Idle state.
---@param color Color
function GRAPH:SetMainHandleIdleColor( color )
    self.Handles.Main.Idle.Color = color
end

-- Returns the rate at which their Main Handle changes color when transitioning to the Idle state.
---@return number
function GRAPH:GetMainHandleIdleColorChangeRate()
    return self.Handles.Main.Idle.ColorChangeRate
end

-- Sets the rate at which the Main Handle's color changes when transitioning to the Idle state.
---@param rate number
function GRAPH:SetMainHandleIdleColorChangeRate( rate )
    self.Handles.Main.Idle.ColorChangeRate = rate
end

-- Returns the radius of the Main Handle when it is in the Idle state.
---@return integer
function GRAPH:GetMainHandleIdleRadius()
    return self.Handles.Main.Idle.Radius
end

-- Sets the radius of the Main Handle when it is in the Idle state.
---@param radius integer
function GRAPH:SetMainHandleIdleRadius( radius )
    self.Handles.Main.Idle.Radius = radius
end

-- Returns the rate at which the Main Handle's radius changes when transitioning to the Idle state.
---@return number
function GRAPH:GetMainHandleIdleRadiusChangeRate()
    return self.Handles.Main.Idle.RadiusChangeRate
end

-- Sets the rate at which the Main Handle's radius changes when transitioning to the Idle state.
---@param rate number
function GRAPH:SetMainHandleIdleRadiusChangeRate( rate )
    self.Handles.Main.Idle.RadiusChangeRate = rate
end

--#endregion Main Handle Idle Functions

--#region Main Handle Hovered Functions

-- Returns the color of the Main Handle when it is in the Hovered state.
---@return Color
function GRAPH:GetMainHandleHoveredColor()
    return self.Handles.Main.Hovered.Color
end

-- Sets the color of the Main Handle when it is in the Hovered state.
---@param color Color
function GRAPH:SetMainHandleHoveredColor( color )
    self.Handles.Main.Hovered.Color = color
end

-- Returns the rate at which the Main Handle's color changes when transitioning to the Hovered state.
---@return number
function GRAPH:GetMainHandleHoveredColorChangeRate()
    return self.Handles.Main.Hovered.ColorChangeRate
end

-- Sets the rate at which the Main Handle's color changes when transitioning to the Hovered state.
---@param rate number
function GRAPH:SetMainHandleHoveredColorChangeRate( rate )
    self.Handles.Main.Hovered.ColorChangeRate = rate
end

-- Returns the radius of the Main Handle when it is in the Hovered state.
---@return integer
function GRAPH:GetMainHandleHoveredRadius()
    return self.Handles.Main.Hovered.Radius
end

-- Sets the radius of the Main Handle when it is in the Hovered state.
---@param radius integer
function GRAPH:SetMainHandleHoveredRadius( radius )
    self.Handles.Main.Hovered.Radius = radius
end

-- Returns the rate at which the Main Handle's radius changes when transitioning to the Hovered state.
---@return number
function GRAPH:GetMainHandleHoveredRadiusChangeRate()
    return self.Handles.Main.Hovered.RadiusChangeRate
end

-- Sets the rate at which the Main Handle's radius changes when transitioning to the Hovered state.
---@param rate number
function GRAPH:SetMainHandleHoveredRadiusChangeRate( rate )
    self.Handles.Main.Hovered.RadiusChangeRate = rate
end

--#endregion Main Handle Hovered Functions

--#region Main Handle Dragged Functions

-- Returns the color of the Main Handle when it is in the Dragged state.
---@return Color
function GRAPH:GetMainHandleDraggedColor()
    return self.Handles.Main.Dragged.Color
end

-- Sets the color of the Main Handle when it is in the Dragged state.
---@param color Color
function GRAPH:SetMainHandleDraggedColor( color )
    self.Handles.Main.Dragged.Color = color
end

-- Returns the rate at which the Main Handle's color changes when transitioning to the Dragged state.
---@return number
function GRAPH:GetMainHandleDraggedColorChangeRate()
    return self.Handles.Main.Dragged.ColorChangeRate
end

-- Sets the rate at which the Main Handle's color changes when transitioning to the Dragged state.
---@param rate number
function GRAPH:SetMainHandleDraggedColorChangeRate( rate )
    self.Handles.Main.Dragged.ColorChangeRate = rate
end

-- Returns the radius of the Main Handle when it is in the Dragged state.
---@return integer
function GRAPH:GetMainHandleDraggedRadius()
    return self.Handles.Main.Dragged.Radius
end

-- Sets the radius of the Main Handle when it is in the Dragged state.
---@param radius integer
function GRAPH:SetMainHandleDraggedRadius( radius )
    self.Handles.Main.Dragged.Radius = radius
end

-- Returns the rate at which the Main Handle's radius changes when transitioning to the Dragged state.
---@return number
function GRAPH:GetMainHandleDraggedRadiusChangeRate()
    return self.Handles.Main.Dragged.RadiusChangeRate
end

-- Sets the rate at which the Main Handle's radius changes when transitioning to the Dragged state.
---@param rate number
function GRAPH:SetMainHandleDraggedRadiusChangeRate( rate )
    self.Handles.Main.Dragged.RadiusChangeRate = rate
end

--#endregion Main Handle Dragged Functions

--#endregion Main Handle Functions

--#region Side Handle Functions

--#region Side Handle Idle Functions

-- Returns the color of the Side Handle when it is in the Idle state.
---@return Color
function GRAPH:GetSideHandleIdleColor()
    return self.Handles.Side.Idle.Color
end

-- Sets the color of the Side Handle when it is in the Idle state.
---@param color Color
function GRAPH:SetSideHandleIdleColor( color )
    self.Handles.Side.Idle.Color = color
end

-- Returns the rate at which the Side Handle's color changes when transitioning to the Idle state.
---@return number
function GRAPH:GetSideHandleIdleColorChangeRate()
    return self.Handles.Side.Idle.ColorChangeRate
end

-- Sets the rate at which the Side Handle's color changes when transitioning to the Idle state.
---@param rate number
function GRAPH:SetSideHandleIdleColorChangeRate( rate )
    self.Handles.Side.Idle.ColorChangeRate = rate
end

-- Returns the radius of the Side Handle when it is in the Idle state.
---@return integer
function GRAPH:GetSideHandleIdleRadius()
    return self.Handles.Side.Idle.Radius
end

-- Sets the radius of the Side Handle when it is in the Idle state.
---@param radius integer
function GRAPH:SetSideHandleIdleRadius( radius )
    self.Handles.Side.Idle.Radius = radius
end

-- Returns the rate at which the Side Handle's radius changes when transitioning to the Idle state.
---@return number
function GRAPH:GetSideHandleIdleRadiusChangeRate()
    return self.Handles.Side.Idle.RadiusChangeRate
end

-- Sets the rate at which the Side Handle's radius changes when transitioning to the Idle state.
---@param rate number
function GRAPH:SetSideHandleIdleRadiusChangeRate( rate )
    self.Handles.Side.Idle.RadiusChangeRate = rate
end

--#endregion Side Handle Idle Functions

--#region Side Handle Hovered Functions

-- Returns the color of the Side Handle when it is in the Hovered state.
---@return Color
function GRAPH:GetSideHandleHoveredColor()
    return self.Handles.Side.Hovered.Color
end

-- Sets the color of the Side Handle when it is in the Hovered state.
---@param color Color
function GRAPH:SetSideHandleHoveredColor( color )
    self.Handles.Side.Hovered.Color = color
end

-- Returns the rate at which the Side Handle's color changes when transitioning to the Hovered state.
---@return number
function GRAPH:GetSideHandleHoveredColorChangeRate()
    return self.Handles.Side.Hovered.ColorChangeRate
end

-- Sets the rate at which the Side Handle's color changes when transitioning to the Hovered state.
---@param rate number
function GRAPH:SetSideHandleHoveredColorChangeRate( rate )
    self.Handles.Side.Hovered.ColorChangeRate = rate
end

-- Returns the radius of the Side Handle when it is in the Hovered state.
---@return integer
function GRAPH:GetSideHandleHoveredRadius()
    return self.Handles.Side.Hovered.Radius
end

-- Sets the radius of the Side Handle when it is in the Hovered state.
---@param radius integer
function GRAPH:SetSideHandleHoveredRadius( radius )
    self.Handles.Side.Hovered.Radius = radius
end

-- Returns the rate at which the Side Handle's radius changes when transitioning to the Hovered state.
---@return number
function GRAPH:GetSideHandleHoveredRadiusChangeRate()
    return self.Handles.Side.Hovered.RadiusChangeRate
end

-- Sets the rate at which the Side Handle's radius changes when transitioning to the Hovered state.
---@param rate number
function GRAPH:SetSideHandleHoveredRadiusChangeRate( rate )
    self.Handles.Side.Hovered.RadiusChangeRate = rate
end

--#endregion Side Handle Hovered Functions

--#region Side Handle Dragged Functions

-- Returns the color of the Side Handle when it is in the Dragged state.
---@return Color
function GRAPH:GetSideHandleDraggedColor()
    return self.Handles.Side.Dragged.Color
end

-- Sets the color of the Side Handle when it is in the Dragged state.
---@param color Color
function GRAPH:SetSideHandleDraggedColor( color )
    self.Handles.Side.Dragged.Color = color
end

-- Returns the rate at which the Side Handle's color changes when transitioning to the Dragged state.
---@return number
function GRAPH:GetSideHandleDraggedColorChangeRate()
    return self.Handles.Side.Dragged.ColorChangeRate
end

-- Sets the rate at which the Side Handle's color changes when transitioning to the Dragged state.
---@param rate number
function GRAPH:SetSideHandleDraggedColorChangeRate( rate )
    self.Handles.Side.Dragged.ColorChangeRate = rate
end

-- Returns the radius of the Side Handle when it is in the Dragged state.
---@return integer
function GRAPH:GetSideHandleDraggedRadius()
    return self.Handles.Side.Dragged.Radius
end

-- Sets the radius of the Side Handle when it is in the Dragged state.
---@param radius integer
function GRAPH:SetSideHandleDraggedRadius( radius )
    self.Handles.Side.Dragged.Radius = radius
end

-- Returns the rate at which the Side Handle's radius changes when transitioning to the Dragged state.
---@return number
function GRAPH:GetSideHandleDraggedRadiusChangeRate()
    return self.Handles.Side.Dragged.RadiusChangeRate
end

-- Sets the rate at which the Side Handle's radius changes when transitioning to the Dragged state.
---@param rate number
function GRAPH:SetSideHandleDraggedRadiusChangeRate( rate )
    self.Handles.Side.Dragged.RadiusChangeRate = rate
end

--#endregion Side Handle Dragged Functions

--#endregion Side Handle Functions

--#region Handle Line Functions

-- Returns the color of the line between Main and Side Handles
---@return Color
function GRAPH:GetHandleLineColor()
    return self.Handles.Line.Color
end

-- Sets the color of the line between Main and Side Handles
---@param color Color
function GRAPH:SetHandleLineColor( color )
    self.Handles.Line.Color = color
end

-- Returns the thickness of the line between Main and Side Handles
---@return integer
function GRAPH:GetHandleLineThickness()
    return self.Handles.Line.Thickness
end

-- Sets the thickness of the line between Main and Side Handles
---@param thickness integer
function GRAPH:SetHandleLineThickness( thickness )
    self.Handles.Line.Thickness = thickness
end


--#endregion Handle Line Functions

--#endregion Handle Functions

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

--#endregion Graph Config Functions

--#endregion Default Graph Config

--#region Default Sidebar Config

---@class CurveLib.Editor.Config.Sidebar
local SIDEBAR = {
    BackgroundColor = DefaultColors.SidebarBackground
}

--#endregion Default Sidebar Config

--#endregion Default Class Implementations

--#region Metatables

---@type CurveLib.Editor.Config
local DefaultConfig = {
    GraphConfig = GRAPH,
    SidebarConfig = SIDEBAR
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