require( "vguihotload" )

---@class CurveLib.Editor.Graph.Panel
local PANEL = IN_PROGRESS_GRAPH_PANEL
if not PANEL then error( "Failed to load Config module of CurveLib.Editor.Graph.Panel" ) return end

local fonts = {
    NumberLineSmall = "CurveLib_Graph_Small",
    NumberLineLarge = "CurveLib_Graph_Large",
    Label           = "CurveLib_Graph_Label",
}

-- Small numbers on the number line
surface.CreateFont( fonts.NumberLineSmall, {
	font = "Roboto Regular",
	extended = true,
	size = 18,
	weight = 400,
    antialias = true
} )

-- Large numbers on the number line
surface.CreateFont( fonts.NumberLineLarge, {
	font = "Roboto Regular",
	extended = true,
	size = 20,
	weight = 400,
    antialias = true
} )

-- Labels on the axes
surface.CreateFont( fonts.Label, {
	font = "Roboto Regular",
	extended = true,
	size = 30,
	weight = 400,
    antialias = true
} )

local colors = {
	Text = Color( 22, 66, 91 ),
	Borders = Color( 22, 66, 91 ),
	Axes = Color( 22, 66, 91 )
}

---@param config GraphConfig
function PANEL:SetConfig( config )
    self.Config = config

    config.BackgroundColor = Color( 217, 220, 214 )

    do -- Main Handles
        local handle = config.Handles.Main

        local handleColor = Color( 129, 195, 215, 255 )
        local handleRadius = 10

        local idle = handle.Idle
        idle.Color = handleColor
        idle.ColorChangeRate = 500
        idle.Radius = handleRadius
        idle.RadiusChangeRate = 50

        local hovered = handle.Hovered
        hovered.Color = handleColor
        hovered.ColorChangeRate = 500
        hovered.Radius = handleRadius
        hovered.RadiusChangeRate = 50

        local dragged = handle.Dragged
        dragged.Color = handleColor
        dragged.ColorChangeRate = 500
        dragged.Radius = handleRadius
        dragged.RadiusChangeRate = 50
    end

    do -- Side Handles
        local handle = config.Handles.Side

        local handleColor = Color( 6, 196, 239, 255 )
        local handleRadius = 10

        local idle = handle.Idle
        idle.Color = handleColor
        idle.ColorChangeRate = 500
        idle.Radius = handleRadius
        idle.RadiusChangeRate = 100

        local hovered = handle.Hovered
        hovered.Color = handleColor
        hovered.ColorChangeRate = 500
        hovered.Radius = handleRadius
        hovered.RadiusChangeRate = 100

        local dragged = handle.Dragged
        dragged.Color = handleColor
        dragged.ColorChangeRate = 1000
        dragged.Radius = handleRadius
        dragged.RadiusChangeRate = 100
    end

    do -- Handle Lines
        local line = config.Handles.Line
        line.Color = Color( 35, 80, 91 )
        line.Thickness = 5
    end

    do -- Curve
        local curve = self.Config.Curve
        curve.Color = Color( 47, 102, 144 )
        curve.Thickness = 7
        curve.HoverSize = 10
        curve.VertexCount = 80
    end

    do -- Right Border
        local border = self.Config.Borders.Right
        border.Enabled = true
        border.Color = colors.Borders
        border.Thickness = 0.75
    end

    do -- Top Border
        local border = self.Config.Borders.Top
        border.Enabled = true
        border.Color = colors.Borders
        border.Thickness = 0.75
    end

    do -- Horizontal Axis
        local axis = self.Config.Axes.Horizontal
        axis.EndMargin = 25
        axis.Thickness = 1

        axis.Label.Text = "X"
        axis.Label.Rotation = 0
        axis.Label.Font = fonts.Label
        axis.Label.Color = colors.Axes
        axis.Label.EdgeMargin = 3

        axis.NumberLine.LabelMargin    = 5
        axis.NumberLine.MaxNumberCount = 3
        axis.NumberLine.StartingValue  = 0
        axis.NumberLine.EndingValue    = 1
        axis.NumberLine.LargeTextFont  = fonts.NumberLineLarge
        axis.NumberLine.LargeTextColor = colors.Text
        axis.NumberLine.SmallTextFont  = fonts.NumberLineSmall
        axis.NumberLine.SmallTextColor = colors.Text
    end

    do -- Vertical Axis
        local axis = self.Config.Axes.Vertical
        axis.EndMargin = 25
        axis.Thickness = 1

        axis.Label.Text = "Y"
        axis.Label.Rotation = 0
        axis.Label.Font = fonts.Label
        axis.Label.Color = colors.Axes
        axis.Label.EdgeMargin = 10

        axis.NumberLine.LabelMargin    = 5
        axis.NumberLine.MaxNumberCount = 3
        axis.NumberLine.StartingValue  = 0
        axis.NumberLine.EndingValue    = 1
        axis.NumberLine.LargeTextFont  = fonts.NumberLineLarge
        axis.NumberLine.LargeTextColor = colors.Text
        axis.NumberLine.SmallTextFont  = fonts.NumberLineSmall
        axis.NumberLine.SmallTextColor = colors.Text
    end
end