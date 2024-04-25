AddCSLuaFile()
if SERVER then return end
require( "vguihotload" )
local utils = include( "includes/curvelib/curve-utils.lua" ) --[[@as CurveUtils]]

---@class CurveDraw

_G.CurveLib.CurveDrawing = {
    PanelStack = util.Stack()
}
local drawing = _G.CurveLib.CurveDrawing

-- Loads a panel and its settings onto the stack
---@param panel CurveEditor
function drawing.PushPanel( panel )
    if not panel then return false end

    drawing.PanelStack:Push( panel )

    local matrix = Matrix()
    matrix:SetTranslation( Vector( panel:LocalToScreen( 0, 0 ) ) )

    cam.Start2D()
    cam.PushModelMatrix( matrix )
end

function drawing.PopPanel()
    drawing.PanelStack:Pop()

    cam.PopModelMatrix()
    cam.End2D()
end

-- Draws a line by drawing a quad
---@param startX number
---@param startY number
---@param endX number
---@param endY number
---@param lineWidth number
---@param color Color?
function drawing.DrawLine( startX, startY, endX, endY, lineWidth, color )
    startX, startY, endX, endY = utils.MultiFloor( startX, startY, endX, endY )

    if not color then 
        color = ( surface.GetDrawColor() or Color( 255, 255, 255, 255 ) )
    end

    local startPos  = Vector( startX, startY )
    local endPos    = Vector( endX, endY )

    local direction = ( endPos - startPos ):GetNormalized()

    local perpendicularDirection = Vector( direction.y, direction.x ):GetNormalized()

    -- In this function, we're going to assuming "forward" is the 
    -- direction from the start position to the end position.
    -- "Left" and "Right" are relative to that forward direction.

    -- Flooring the left and ceiling the right ensures a pixel isn't lost in the division
    local leftOffsetAmount = math.max( math.floor( lineWidth / 2.0 ), 0 )
    local rightOffsetAmount = math.max( math.ceil( lineWidth / 2.0 ), 1 )

    local leftOffset  = Vector( perpendicularDirection.x, -perpendicularDirection.y ) * leftOffsetAmount
    local rightOffset = Vector( -perpendicularDirection.x, perpendicularDirection.y ) * rightOffsetAmount

    -- Handle lines narrower than 1 pixel by lowering their alpha
    if lineWidth < 1 and lineWidth > 0 then
        local alpha = color.a * lineWidth
        color.a = alpha
    end

    render.SetColorMaterial()
    render.DrawQuad(
        endPos   + leftOffset,
        endPos   + rightOffset,
        startPos + rightOffset,
        startPos + leftOffset,
        color
    )
end


-- Draws text with rotation and alignment
---@param text any
---@param textX number The text's center position's x coordinate
---@param textY number The text's center position's y coordinate
---@param rotation number? The text's rotation, in degrees. [Default: 0]
---@param horizontalAlignment TEXT_ALIGN|integer? The text's horizontal alignment [Default: Centered]
---@param verticalAlignment TEXT_ALIGN|integer? The text's vertical alignment. [Default: Centered]
function drawing.DrawText( text, textX, textY, rotation, horizontalAlignment, verticalAlignment )
    if not rotation then rotation = 0 end

    local textWidth, textHeight = surface.GetTextSize( text )

    local xAlignment = math.floor( textWidth / 2 )
    local yAlignment = math.floor( textHeight / 2 )

    if horizontalAlignment == TEXT_ALIGN_LEFT then
        xAlignment = textWidth
    elseif horizontalAlignment == TEXT_ALIGN_RIGHT then
        -- No offset because of text's top-left origin
        xAlignment = 0
    end

    if verticalAlignment == TEXT_ALIGN_TOP then
        yAlignment = textHeight
    elseif verticalAlignment == TEXT_ALIGN_BOTTOM then
        -- No offset because of text's top-left origin
        yAlignment = 0
    end

    local matrix = Matrix()
    matrix:Translate( Vector( textX, textY ) )
    matrix:Rotate( Angle( 0, rotation, 0 ) )
    matrix:Translate( -Vector( xAlignment, yAlignment ) )

    cam.PushModelMatrix( matrix, true )

    surface.SetTextPos( 0, 0 )
    surface.DrawText( text )

    cam.PopModelMatrix()
end

-- Takes a number range and draws it in a line
-- Note: This will always draw at least 2 labels.  One for the start and one for the end.
---@param startX number
---@param startY number
---@param endX number
---@param endY number
---@param startNumber number
---@param endNumber number
---@param middleLabelCount integer
---@param horizontalAlignment TEXT_ALIGN|integer? The horizontal alignment of the numbers. [Default: Centered]
---@param verticalAlignment TEXT_ALIGN|integer? The vertical alignment of the numbers. [Default: Centered]
---@param textColor Color The color the text will be drawn in.
---@param smallNumberFont string The font to use for the small numbers.
---@param largeNumberFont string The font to use for the large numbers.
function drawing.DrawNumberLine( startX, startY, endX, endY, startNumber, endNumber, middleLabelCount, horizontalAlignment, verticalAlignment, textColor, smallNumberFont, largeNumberFont )
    startX, startY, endX, endY = utils.MultiFloor( startX, startY, endX, endY )

    surface.SetTextColor( textColor )

    -- Start and end numbers
    surface.SetFont( largeNumberFont )
    drawing.DrawText( startNumber, startX, startY, 0, horizontalAlignment, verticalAlignment )
    drawing.DrawText( endNumber, endX, endY, 0, horizontalAlignment, verticalAlignment )

    local startPos = Vector( startX, startY )
    local endPos = Vector( endX, endY )

    local distance = startPos:Distance2D( endPos )
    local labelInterval = math.floor( distance / middleLabelCount )

    local direction = ( endPos - startPos ):GetNormalized()

    surface.SetFont( smallNumberFont )
    for i = 1, ( middleLabelCount - 1 ) do
        local pos = startPos + direction * ( i * labelInterval )
        
        local number = Lerp( i / middleLabelCount, startNumber, endNumber )
        local formattedNumber = string.format( "%.2f", number )

        drawing.DrawText( formattedNumber, pos.x, pos.y, 0, horizontalAlignment, verticalAlignment )
    end

end

function drawing.DrawGrid()
    local panel = drawing.PanelStack:Top() --[[@as CurveEditor]]

    local width, height = panel:GetSize()
    local mins, maxs = panel:GetGraphMinsMaxs()
end

function drawing.DrawAxis()
    local panel = drawing.PanelStack:Top() --[[@as CurveEditor]]
    local width, height = panel:GetSize()
    local mins, maxs = panel:GetGraphMinsMaxs()
    local vertical = panel.Settings.Axis.Vertical
    local horizontal = panel.Settings.Axis.Horizontal

    --[[ Vertical Axis ]]--
    -- Axis line
    render.SetColorMaterial()
    drawing.DrawLine( mins.x, mins.y, mins.x, maxs.y, vertical.Width, vertical.Color )

    -- Numbers
    local verticalLabelCount = math.ceil( height / vertical.NumberLine.SpaceBetween )
    drawing.DrawNumberLine(
        mins.x - vertical.NumberLine.Margin,
        mins.y,
        mins.x - vertical.NumberLine.Margin,
        maxs.y,
        0, 1,
        verticalLabelCount,
        TEXT_ALIGN_LEFT,
        TEXT_ALIGN_CENTER,
        vertical.NumberLine.TextColor,
        vertical.NumberLine.Fonts.SmallNumnbers,
        vertical.NumberLine.Fonts.LargeNumbers
    )

    -- Label
    surface.SetFont( vertical.Label.Font )
    local verticalCenter = mins.y + math.floor( ( maxs.y - mins.y ) / 2 )
    drawing.DrawText(
        vertical.Label.Text,
        mins.x - vertical.NumberLine.Margin - vertical.Label.RightMargin,
        verticalCenter,
        vertical.Label.Rotation,
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_TOP
    )

    --[[ Horizontal Axis ]]--
    -- Axis line
    -- One of the two axis lines needs to extend backwards a little bit to cover the gap between them
    local originCoverOffset = math.ceil( vertical.Width / 2 )
    render.SetColorMaterial()
    drawing.DrawLine( mins.x - originCoverOffset, mins.y, maxs.x, mins.y, horizontal.Width, vertical.Color )

    -- Numbers
    local horizontalLabelCount = math.ceil( width / horizontal.NumberLine.SpaceBetween )
    drawing.DrawNumberLine(
        mins.x,
        mins.y + horizontal.NumberLine.Margin,
        maxs.x,
        mins.y + horizontal.NumberLine.Margin,
        0, 1,
        horizontalLabelCount,
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_BOTTOM,
        horizontal.NumberLine.TextColor,
        horizontal.NumberLine.Fonts.SmallNumnbers,
        horizontal.NumberLine.Fonts.LargeNumbers
    )

    -- Label
    surface.SetFont( horizontal.Label.Font )
    local horizontalCenter = mins.x + math.floor( ( maxs.x - mins.x ) / 2 )
    drawing.DrawText(
        horizontal.Label.Text,
        horizontalCenter,
        mins.y + horizontal.NumberLine.Margin + horizontal.Label.TopMargin,
        horizontal.Label.Rotation,
        TEXT_ALIGN_CENTER,
        TEXT_ALIGN_BOTTOM
    )
end

-- Converts a point in graph coordinates to screenspace coordinates
---@param x number
---@param y number
---@return Vector
function drawing.GraphToScreen( x, y )
    local panel = drawing.PanelStack:Top() --[[@as CurveEditor]]
    local graphMins, graphMaxs = panel:GetGraphMinsMaxs()
    local graphSize = graphMaxs - graphMins
    return graphMins + Vector( x * graphSize.x, y * graphSize.y )
end

-- Converts a point in screenspace coordinates to graph coordinates
---@param x number
---@param y number
---@return Vector
function drawing.ScreenToGraph( x, y )
    local panel = drawing.PanelStack:Top() --[[@as CurveEditor]]

end

---@param curvePoint Curves.ControlPoint
function drawing.DrawCurvePoint( curvePoint )
    local panel = drawing.PanelStack:Top() --[[@as CurveEditor]]
    local graphMins, graphMaxs = panel:GetGraphMinsMaxs()
    local graphSize = graphMaxs - graphMins

    local pointPos = graphMins + curvePoint.Pos * graphSize

    -- Left handle and line
    if curvePoint.LeftHandlePos then
        local pointLeftHandlePos = graphMins + curvePoint.LeftHandlePos * graphSize

        drawing.DrawLine( pointPos.x, pointPos.y, pointLeftHandlePos.x, pointLeftHandlePos.y, panel.Settings.Handles.Line.Width, panel.Settings.Handles.Line.Color )

        surface.DrawRect( pointLeftHandlePos.x - panel.Settings.Handles.Radius, pointLeftHandlePos.y - panel.Settings.Handles.Radius, panel.Settings.Handles.Radius * 2, panel.Settings.Handles.Radius * 2 )
    end

    -- Right handle and line
    if curvePoint.RightHandlePos then
        local pointRightHandlePos = graphMins + curvePoint.RightHandlePos * graphSize

        drawing.DrawLine( pointPos.x, pointPos.y, pointRightHandlePos.x, pointRightHandlePos.y, panel.Settings.Handles.Line.Width, panel.Settings.Handles.Line.Color )

        surface.DrawRect( pointRightHandlePos.x - panel.Settings.Handles.Radius, pointRightHandlePos.y - panel.Settings.Handles.Radius, panel.Settings.Handles.Radius * 2, panel.Settings.Handles.Radius * 2 )
    end

    -- The point
    surface.DrawRect( pointPos.x - panel.Settings.Points.Radius, pointPos.y - panel.Settings.Points.Radius, panel.Settings.Points.Radius * 2, panel.Settings.Points.Radius * 2 )
end

---@param startCurvePoint Curves.ControlPoint
---@param endCurvePoint Curves.ControlPoint
---@param lineCount integer How many lines to use to draw this curve segment
---@param lineWidth integer
---@param color Color
function drawing.DrawCurveSegment( startCurvePoint, endCurvePoint, lineCount, lineWidth, color )
    color = color or Color( 255, 255, 255, 255 )
    
    local startPos = drawing.GraphToScreen( startCurvePoint.Pos.x, startCurvePoint.Pos.y )
    local startHandlePos = drawing.GraphToScreen( startCurvePoint.RightHandlePos.x, startCurvePoint.RightHandlePos.y )
    local endHandlePos = drawing.GraphToScreen( endCurvePoint.LeftHandlePos.x, endCurvePoint.LeftHandlePos.y )
    local endPos = drawing.GraphToScreen( endCurvePoint.Pos.x, endCurvePoint.Pos.y )
    
    local lineStart = startPos
    for lineNumber = 1, lineCount do
        local progress = lineNumber / lineCount
        local lineEnd = math.CubicBezier( progress, startPos, startHandlePos, endHandlePos, endPos )
        drawing.DrawLine( lineStart.x, lineStart.y, lineEnd.x, lineEnd.y, lineWidth, color )

        lineStart = lineEnd
    end
end

---@param curve Curves.Curve
---@param segmentCount integer
---@param color Color
function drawing.DrawCurve( curve, segmentCount, lineWidth, color )
    local currentPoint = curve.Points[1]

    for i = 2, #curve.Points do
        local nextPoint = curve.Points[i]
        drawing.DrawCurveSegment( currentPoint, nextPoint, segmentCount, lineWidth, color )
        currentPoint = nextPoint
    end
end

---@param curve Curves.Curve
function drawing.DrawCurveHandles( curve )
    local panel = drawing.PanelStack:Top() --[[@as CurveEditor]]
    surface.SetDrawColor( Color( 255, 100, 75 ) )
    for _, curvePoint  in ipairs( curve.Points ) do
        curvePoint = curvePoint --[[@as CurvePoint]]
        drawing.DrawCurvePoint( curvePoint )
    end
end

---@param curve Curves.Curve
function drawing.DrawGraph( curve )
    local panel = drawing.PanelStack:Top() --[[@as CurveEditor]]

    drawing.DrawAxis()
    drawing.DrawGrid()
    drawing.DrawCurve( curve, 100, panel.Settings.Curve.Width, panel.Settings.Curve.Color )
    drawing.DrawCurveHandles( curve )
end

vguihotload.HandleHotload( "CurveEditor" )

_G.CurveLib.CurveDrawing = drawing
return _G.CurveLib.CurveDrawing