if not _G.CurveLib or not istable( _G.CurveLib ) then
    error( "Curve Lib did not initialize correctly" ) 
elseif _G.CurveLib.GraphDraw and not _G.CurveLib.IsDevelopment then
    return _G.CurveLib.GraphDraw
end

---@type CurveLib.Editor.DrawBase
local drawBase

---@type CurveLib.Editor.Utils
local curveUtils = include( "libraries/curvelib/editor/utils.lua" )

---@class CurveLib.Editor.Graph.Draw
---@field GraphStack Stack A stack of Graphs that are being drawn.  This is used to calculate the relative positions of elements.
local DRAW = {
    GraphStack = util.Stack()
}

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
    drawBase = _G.CurveLib.DrawBase or drawBase or include( "libraries/curvelib/editor/draw-base.lua" )

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

local function DrawAlignmentTest( text, x, y, width, height, rotation, scale, alignment )

    local textColor = Color( 255, 255, 255 )
    local backgroundRectColor = Color( 100, 100, 100 )

    -- Background Rectangle
    drawBase.Rect( x, y, width, height, rotation, alignment, backgroundRectColor )

    -- Text 
    drawBase.Text( text, x, y, rotation, scale, alignment, textColor )
end

function DRAW.AlignemntDebug()

    local text = "Hello, World!"
    local centerX, centerY = 500, 500
    local padding = 150

    local textScale = 3 --math.Remap( math.sin( CurTime() * 2 ), -1, 1, 1, 3.5 )

    local textWidth, textHeight = surface.GetTextSize( text )
    textWidth = textWidth * textScale
    textHeight = textHeight * textScale

    local testWidth, testHeight = 200, 150

    local rotation = 45 --( CurTime() * 30 ) % 360

    surface.SetFont( "DermaDefault" )

    do -- Top Left
        local x = centerX - testWidth - padding
        local y = centerY - testHeight - padding

        DrawAlignmentTest( text, x, y, textWidth, textHeight, rotation, textScale, Alignment.TopLeft )
    end

    do -- Top Center
        local x = centerX
        local y = centerY - testHeight - padding

        DrawAlignmentTest( text, x, y, textWidth, textHeight, rotation, textScale, Alignment.TopCenter )
    end

    
    do -- Top Right
        local x = centerX + testWidth + padding
        local y = centerY - testHeight - padding

        DrawAlignmentTest( text, x, y, textWidth, textHeight, rotation, textScale, Alignment.TopRight )
    end

    do -- Center Left
        local x = centerX - testWidth - padding
        local y = centerY

        DrawAlignmentTest( text, x, y, textWidth, textHeight, rotation, textScale, Alignment.CenterLeft )
    end

    do -- Center
        local x = centerX
        local y = centerY

        DrawAlignmentTest( text, x, y, textWidth, textHeight, rotation, textScale, Alignment.Center )
    end

    do -- Center Right
        local x = centerX + testWidth + padding
        local y = centerY

        DrawAlignmentTest( text, x, y, textWidth, textHeight, rotation, textScale, Alignment.CenterRight )
    end

    do -- Bottom Left
        local x = centerX - testWidth - padding
        local y = centerY + testHeight + padding

        DrawAlignmentTest( text, x, y, textWidth, textHeight, rotation, textScale, Alignment.BottomLeft )
    end

    do -- Bottom Center
        local x = centerX
        local y = centerY + testHeight + padding

        DrawAlignmentTest( text, x, y, textWidth, textHeight, rotation, textScale, Alignment.BottomCenter )
    end

    do -- Bottom Right
        local x = centerX + testWidth + padding
        local y = centerY + testHeight + padding

        DrawAlignmentTest( text, x, y, textWidth, textHeight, rotation, textScale, Alignment.BottomRight )
    end

    -- Draw a red center line through every text's vertical and horizontal center
    surface.SetDrawColor( 255, 0, 0 )

    -- Top Row
    drawBase.Line( centerX - testWidth - padding, centerY - testHeight - padding, centerX + testWidth + padding, centerY - testHeight - padding, 1 )

    -- Center Row
    drawBase.Line( centerX - testWidth - padding, centerY, centerX + testWidth + padding, centerY, 1 )

    -- Bottom Row
    drawBase.Line( centerX - testWidth - padding, centerY + testHeight + padding, centerX + testWidth + padding, centerY + testHeight + padding, 1 )

    -- Left Column
    drawBase.Line( centerX - testWidth- padding, centerY - testHeight - padding, centerX - testWidth - padding, centerY + testHeight + padding, 1 )

    -- Center Column
    drawBase.Line( centerX, centerY - testHeight - padding, centerX, centerY + testHeight + padding, 1 )

    -- Right Column
    drawBase.Line( centerX + testWidth + padding, centerY - testHeight - padding, centerX + testWidth + padding, centerY + testHeight + padding, 1 )

end

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
    local config, graph, x, y, width, height = DRAW.UnpackEntry()
    local interiorX, interiorY, interiorWidth, interiorHeight = graph:GetInteriorRect()

    for i = 1, #curve.Points do
        local point = curve.Points[i] --[[@as CurveLib.Curve.Point]]
        local mainPoint = point.MainHandle

        local mainX, mainY = graph:NormalToInterior( mainPoint.x, mainPoint.y )
    end
end

-- Draws the exterior of the Graph, which includes the Axes, Labels, and Number Lines
function DRAW.GraphExterior()
    local config, graph, x, y, width, height = DRAW.UnpackEntry()
    local halfWidth, halfHeight = curveUtils.MultiFloor( width / 2, height / 2 )
    local horizontal = config.Axes.Horizontal
    local vertical = config.Axes.Vertical

    local _, horizontalLabelHeight = config:GetLabelSize( horizontal )
    local _, horizontalNumberLineHeight = config:GetNumberLineTextSize( horizontal.NumberLine )

    local verticalLabelWidth, _ = config:GetLabelSize( vertical )
    local verticalNumberLineWidth, _ = config:GetNumberLineTextSize( vertical.NumberLine )

    local interiorX, interiorY, interiorWidth, interiorHeight = graph:GetInteriorRect()
    interiorX = x + interiorX
    interiorY = y + interiorY

    local horizontalAxisEndX = interiorX + interiorWidth
    local horizontalNumberLineY = interiorY + interiorHeight + horizontal.Width + horizontal.NumberLine.AxisMargin
    
    local horizontalLabelY = horizontalNumberLineY + horizontalNumberLineHeight + math.floor( horizontalLabelHeight / 2 ) + horizontal.NumberLine.LabelMargin
    local horizontalLabelX = interiorX + math.floor( ( horizontalAxisEndX - interiorX ) / 2 )

    local verticalNumberLineX = interiorX - vertical.Width - vertical.NumberLine.AxisMargin
    
    local verticalLabelX = verticalNumberLineX - verticalNumberLineWidth - math.floor( verticalLabelWidth / 2 ) - vertical.NumberLine.LabelMargin
    local verticalLabelY = interiorY + math.floor( interiorHeight / 2 )

    -- Background
    drawBase.Rect( x + halfWidth, y + halfHeight, width, height, 0, Alignment.TopLeft,config.BackgroundColor )

    -- Horizontal Axis Line
    -- Note: The start X is offset to cover the corner between the Axes
    drawBase.Line(
        interiorX - vertical.Width, interiorY + interiorHeight,
        horizontalAxisEndX, interiorY + interiorHeight,
        horizontal.Width,
        HorizontalAlignment.Left,
        horizontal.Color
    )

    -- Horizontal Number Line
    DRAW.NumberLine(
        horizontal.NumberLine,
        interiorX, horizontalNumberLineY,
        horizontalAxisEndX, horizontalNumberLineY,
        Alignment.BottomCenter
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

    -- Vertical Axis Line
    drawBase.Line(
        interiorX, interiorY + interiorHeight,
        interiorX, interiorY,
        vertical.Width,
        HorizontalAlignment.Right,
        vertical.Color
    )

    -- Vertical Number Line
    DRAW.NumberLine(
        vertical.NumberLine,
        verticalNumberLineX, interiorY + interiorHeight,
        verticalNumberLineX, interiorY,
        Alignment.CenterLeft
    )

    -- Vertical Label
    surface.SetFont( vertical.Label.Font )
    surface.SetTextColor( vertical.Label.Color )
    drawBase.Text(
        vertical.Label.Text,
        verticalLabelX, verticalLabelY,
        vertical.Label.Rotation, 1,
        Alignment.Center
    )
end

_G.CurveLib.GraphDraw = DRAW
return _G.CurveLib.GraphDraw