require( "vguihotload" )
if not _G.CurveLib or not istable( _G.CurveLib ) then
    error( "Curve Lib did not initialize correctly" )
elseif _G.CurveLib.IsDevelopment then
    vguihotload.HandleHotload( "CurveLib.Editor.Frame" )
elseif _G.CurveLib.GraphDraw then return _G.CurveLib.GraphDraw end

---@type CurveLib.Editor.DrawBase
local drawBase

---@type CurveLib.Editor.Utils
local curveUtils = include( "libraries/curvelib/editor/utils.lua" )

---@class CurveLib.Editor.Graph.Draw
---@field GraphStack Stack A stack of Graphs that are being drawn.  This is used to calculate the relative positions of elements.
local DRAW = {
    GraphStack = util.Stack()
}
_G.CurveLib.GraphDraw = DRAW

--#region Graph Stack

-- An entry in the Graph Stack
---@class CurveLib.Editor.Graph.Draw.StackEntry
---@field Config CurveLib.Editor.Config.Graph
---@field Graph CurveLib.Editor.Graph.Panel 
---@field x integer
---@field y integer
---@field Width integer
---@field Height integer

---@return CurveLib.Editor.Graph.Draw.StackEntry
function DRAW.PeekEntry()
    return DRAW.GraphStack:Top()
end

function DRAW.UnpackEntry()
    local entry = DRAW.PeekEntry()
    return entry.Config, entry.Graph, entry.x, entry.y, entry.Width, entry.Height
end

---@param config CurveLib.Editor.Config.Graph The configuration for the Graph
---@param graph CurveLib.Editor.Graph.Panel The Graph being drawn
---@param x integer The x position of the Graph within the panel
---@param y integer The y position of the Graph within the panel
---@param width integer The width of the Graph, in pixels
---@param height integer The height of the Graph, in pixels
function DRAW.StartPanel( config, graph, x, y, width, height )
    drawBase = drawBase or _G.CurveLib.DrawBase

    x, y, width, height = curveUtils.MultiFloor( x, y, width, height )

    DRAW.GraphStack:Push(
        {
            Config = config,
            Graph = graph,
            x = x,
            y = y,
            Width = width,
            Height = height
        }
    )
    drawBase.StartPanel( graph )
end

---@return DPanel, CurveLib.Editor.Graph.Draw.StackEntry
function DRAW.EndPanel()
    local topPanel = drawBase.EndPanel()

    local topEntry = DRAW.PeekEntry()
    DRAW.GraphStack:Pop( 1 )

    return topPanel, topEntry
end

--#endregion Graph Stack

-- Takes a number range and draws it in a line
-- Note: This will always draw at least 2 labels.  One for the start and one for the end.
---@param config CurveLib.Editor.Config.Graph.Axes.Axis.NumberLine
---@param startX integer
---@param startY integer
---@param endX integer
---@param endY integer
---@param alignment CurveLib.Alignment The alignment of the numbers. [Default: Top Left]
function DRAW.NumberLine( config, startX, startY, endX, endY, alignment )
    startX, startY, endX, endY = curveUtils.MultiFloor( startX, startY, endX, endY )

    -- Start and end numbers
    surface.SetFont( config.LargeTextFont )
    surface.SetTextColor( config.LargeTextColor )
    local startingText = string.format( config.FormatString, config.StartingValue )
    local endingText = string.format( config.FormatString, config.EndingValue )
    drawBase.Text( startingText, startX, startY, 0, 1, alignment )
    drawBase.Text( endingText, endX, endY, 0, 1, alignment )

    local startPos  = Vector( startX, startY )
    local endPos    = Vector(   endX,   endY )

    local difference = ( endPos - startPos )
    local direction = difference:GetNormalized()

    local distance = difference:Length2D()

    local numberInterval = distance / ( config.MaxNumberCount + 1 )

    surface.SetFont( config.SmallTextFont )
    surface.SetTextColor( config.SmallTextColor )
    for i = 1, config.MaxNumberCount do
        local pos = startPos + direction * i * numberInterval

        local number = Lerp( i / ( config.MaxNumberCount + 1 ), config.StartingValue, config.EndingValue )
        local formattedNumber = string.format( "%.2f", number )

        drawBase.Text( formattedNumber, pos.x, pos.y, 0, 1, alignment )
    end
end

-- Draws a Curve
---@param curve CurveLib.Curve.Data
function DRAW.Curve( curve )
    if not curve then return end

    local config, graph = DRAW.UnpackEntry()
    local interiorX, interiorY, interiorWidth, interiorHeight = graph:GetInteriorRect()

    local lineVertices = {}
    local vertexCount = config.Curve.VertexCount
    for vertexNumber = 0, vertexCount do
        local percentage = ( vertexNumber / vertexCount )

        local evaluation = curve( percentage, true )

        local x = interiorX + evaluation.x * interiorWidth
        local y = interiorY + interiorHeight - ( evaluation.y * interiorHeight )

        lineVertices[ #lineVertices + 1 ] = Vector( x, y )
    end

    drawBase.MultiLine( lineVertices, config.Curve.Thickness, config.Curve.Color, HorizontalAlignment.Center )
end

-- Draws the most recently evaluated point of a Curve
---@param curve CurveLib.Curve.Data
function DRAW.RecentEvaluation( curve )
    if ( not curve ) then return end
    if ( not curve.lastInput or not curve.lastOutput )then return end

    local config, graph = DRAW.UnpackEntry()
    local interiorX, interiorY, interiorWidth, interiorHeight = graph:GetInteriorRect()

    local x = interiorX + curve.lastOutput.x * interiorWidth
    local y = interiorY + interiorHeight - ( curve.lastOutput.y * interiorHeight )

    drawBase.Line( interiorX, y, interiorX + interiorWidth, y, 1, HorizontalAlignment.Center, Color( 255, 0, 0, 255 ) )
    drawBase.Rect( x, y, 10, 10, 0, Alignment.Center, Color( 255, 0, 0, 255 ) )
    drawBase.Rect( interiorX, y, 10, 10, 0, Alignment.Center, Color( 255, 0, 0, 255 ) )
end

-- Draws the exterior of the Graph, which includes the Axes, Labels, and Number Lines but not the curve itself
function DRAW.GraphExterior()
    local config, graph, x, y, width, height = DRAW.UnpackEntry()
    local horizontal = config.Axes.Horizontal
    local horizontalNumberLine = horizontal.NumberLine
    local vertical = config.Axes.Vertical
    local verticalNumberLine = vertical.NumberLine
    local rightBorder = config.Borders.Right
    local topBorder = config.Borders.Top

    -- The thickness of the Axes, in pixels.  Calculated here because lines with a thickness lower than 1 are drawn as semi-transparent single width lines.
    -- For positioning, line thickness is always at least 1 pixel.
    local verticalAxisPixelThickness = math.max( vertical.Thickness, 1 )

    local _, horizontalLabelHeight = config:GetLabelSize( horizontal )
    local _, horizontalNumberLineHeight = config:GetNumberLineTextSize( horizontalNumberLine )

    local verticalLabelWidth, _ = config:GetLabelSize( vertical )
    local verticalNumberLineWidth, _ = config:GetNumberLineTextSize( verticalNumberLine )

    local interiorX, interiorY, interiorWidth, interiorHeight = graph:GetInteriorRect()
    interiorX = x + interiorX
    interiorY = y + interiorY

    local horizontalAxisEndX = interiorX + interiorWidth
    local horizontalNumberLineY = interiorY + interiorHeight + math.max( horizontal.Thickness, 1 ) + horizontalNumberLine.AxisMargin

    local horizontalLabelY = horizontalNumberLineY + horizontalNumberLineHeight + math.floor( horizontalLabelHeight / 2 ) + horizontalNumberLine.LabelMargin
    local horizontalLabelX = interiorX + math.floor( ( horizontalAxisEndX - interiorX ) / 2 )

    local verticalNumberLineX = interiorX - verticalAxisPixelThickness - verticalNumberLine.AxisMargin

    local verticalLabelX = verticalNumberLineX - verticalNumberLineWidth - math.floor( verticalLabelWidth / 2 ) - verticalNumberLine.LabelMargin
    local verticalLabelY = interiorY + math.floor( interiorHeight / 2 )

    -- Background
    drawBase.Rect( x, y, width, height, 0, Alignment.TopLeft,config.BackgroundColor )

    do -- Horizontal Axis Line
        local rightBorderOffset = rightBorder.Enabled and math.max( rightBorder.Thickness, 1 ) or 0

        -- Note: The start X is offset to cover the corner between the Axes
        drawBase.Line(
            interiorX - verticalAxisPixelThickness, interiorY + interiorHeight,
            horizontalAxisEndX + rightBorderOffset, interiorY + interiorHeight,
            horizontal.Thickness,
            HorizontalAlignment.Left,
            horizontal.Color
        )
    end

    -- Horizontal Number Line
    DRAW.NumberLine(
        horizontal.NumberLine,
        interiorX, horizontalNumberLineY,
        horizontalAxisEndX, horizontalNumberLineY,
        Alignment.TopCenter
    )

    -- Horizontal Label
    surface.SetFont( horizontal.Label.Font )
    surface.SetTextColor( horizontal.Label.Color )
    drawBase.Text(
        horizontal.Label.Text,
        horizontalLabelX, horizontalLabelY,
        horizontal.Label.Rotation, 1,
        Alignment.Center
    )

    do -- Vertical Axis Line
        local topBorderOffset = topBorder.Enabled and math.max( topBorder.Thickness, 1 ) or 0

        drawBase.Line(
            interiorX, interiorY + interiorHeight,
            interiorX, interiorY - topBorderOffset,
            vertical.Thickness,
            HorizontalAlignment.Right,
            vertical.Color
        )
    end

    -- Vertical Number Line
    DRAW.NumberLine(
        vertical.NumberLine,
        verticalNumberLineX, interiorY + interiorHeight,
        verticalNumberLineX, interiorY,
        Alignment.CenterRight
    )

    -- Vertical Label
    surface.SetFont( vertical.Label.Font )
    drawBase.Text(
        vertical.Label.Text,
        verticalLabelX, verticalLabelY,
        vertical.Label.Rotation, 1,
        Alignment.Center,
        vertical.Label.Color
    )

    -- Right Border
    if rightBorder.Enabled then
        drawBase.Line(
            interiorX + interiorWidth, interiorY + interiorHeight,
            interiorX + interiorWidth, interiorY,
            rightBorder.Thickness,
            HorizontalAlignment.Left,
            rightBorder.Color
        )
    end

    -- Top Border
    if topBorder.Enabled then
        local rightBorderOffset = rightBorder.Enabled and math.max( rightBorder.Thickness, 1 ) or 0

        drawBase.Line(
            interiorX, interiorY,
            interiorX + interiorWidth + rightBorderOffset, interiorY,
            topBorder.Thickness,
            HorizontalAlignment.Right,
            topBorder.Color
        )
    end
end

function DRAW.CurveHovering()
    local config, graph = DRAW.UnpackEntry()

    local _, _, x, y = graph:GetMousePosOnCurve()

    drawBase.Rect( x, y, 10, 10, 0, Alignment.Center, Color( 255, 0, 0, 255 ) )
end

return _G.CurveLib.GraphDraw