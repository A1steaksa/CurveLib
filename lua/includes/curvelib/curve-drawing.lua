AddCSLuaFile()
if SERVER then return end
local utils = include( "includes/curvelib/curve-utils.lua" ) --[[@as CurveUtils]]

--#endregion [Utils]

---@class CurveDraw
local curveDraw = {
    Colors = {
        Background    = Color(  60,  60,  60 ),
        AxisLine      = Color( 200, 200, 200 ),
        AxisGridLine  = Color( 100, 100, 100 ),
        AxisLabelText = Color( 200, 200, 200 )
    },

    Fonts = {
        AxisLabel       = "CurveEditor_AxisLabel",
        NumberLineLarge = "CurveEditor_NumberLine_Large",
        NumberLineSmall = "CurveEditor_NumberLine_Large"
    }
}

function curveDraw.SetupFonts()
    surface.CreateFont( curveDraw.Fonts.AxisLabel, {
        font = "Roboto Regular",
        extended = false,
        size = 28,
        weight = 500,
    } )
    
    surface.CreateFont( curveDraw.Fonts.NumberLineLarge, {
        font = "Roboto Regular",
        extended = false,
        size = 24,
        weight = 500,
    } )
    
    surface.CreateFont( curveDraw.Fonts.NumberLineSmall, {
        font = "Roboto Regular",
        extended = false,
        size = 16,
        weight = 500,
    } )
end

function curveDraw.PushOrigin( x, y )
    local matrix = Matrix()
    matrix:SetTranslation( Vector( x, y ) )

    cam.Start2D()
    cam.PushModelMatrix( matrix )
end

function curveDraw.PopOrigin()
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
function curveDraw.DrawLine( startX, startY, endX, endY, lineWidth, color )
    startX, startY, endX, endY = utils.MultiFloor( startX, startY, endX, endY )

    if not color then 
        color = ( surface.GetDrawColor() or Color( 255, 255, 255, 255 ) )
    end

    local startPos  = Vector( startX, startY )
    local endPos    = Vector( endX, endY )

    local direction = ( endPos - startPos ):GetNormalized()

    local perpendicularDirection = Vector( direction.y, direction.x ):GetNormalized()

    -- In this function curveDraw.we're going to assuming "forward" is the 
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

function curveDraw.DrawText( text, textX, textY, rotation )
    if not rotation then rotation = 0 end

    local textWidth, textHeight = surface.GetTextSize( text )

    local matrix = Matrix()
    matrix:Translate( Vector( textX, textY ) )
    matrix:Rotate( Angle( 0, rotation, 0 ) )
    matrix:Translate( Vector( -math.floor( textWidth / 2 ), -math.floor( textHeight / 2 ) ) )
    
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
function curveDraw.DrawNumberLine( startX, startY, endX, endY, startNumber, endNumber, middleLabelCount )
    startX, startY, endX, endY = utils.MultiFloor( startX, startY, endX, endY )

    surface.SetTextColor( curveDraw.Colors.AxisLabelText )

    surface.SetFont( curveDraw.Fonts.NumberLineLarge )
    curveDraw.DrawText( startNumber, startX, startY )
    curveDraw.DrawText( endNumber, endX, endY )

    local startPos = Vector( startX, startY )
    local endPos = Vector( endX, endY )

    local distance = startPos:Distance2D( endPos )
    local labelInterval = math.floor( distance / middleLabelCount )

    local direction = ( endPos - startPos ):GetNormalized()

    surface.SetFont( curveDraw.Fonts.NumberLineSmall )
    for i = 1, ( middleLabelCount - 1 ) do
        local pos = startPos + direction * ( i * labelInterval )
        
        local number = Lerp( i / middleLabelCount, startNumber, endNumber )
        local formattedNumber = string.format( "%.2f", number )

        curveDraw.DrawText( formattedNumber, pos.x, pos.y )
    end

end

---@param panel CurveEditor
function curveDraw.DrawGrid( panel )
    local width, height = panel:GetSize()
    local mins, maxs = panel:GetGraphMinsMaxs()
end

---@param panel CurveEditor
function curveDraw.DrawAxis( panel )
    local width, height = panel:GetSize()
    local mins, maxs = panel:GetGraphMinsMaxs()

    --[[ Vertical Axis ]]--
    -- Axis line
    render.SetColorMaterial()
    curveDraw.DrawLine( mins.x, mins.y, mins.x, maxs.y, panel.Settings.Axis.Vertical.Width, curveDraw.Colors.AxisLine )

    -- Numbers
    local verticalLabelCount = math.ceil( height / panel.Settings.Axis.Vertical.NumberLine.SpaceBetween )
    curveDraw.DrawNumberLine(
        mins.x - panel.Settings.Axis.Vertical.NumberLine.Margins.LargeText,
        mins.y,
        mins.x - panel.Settings.Axis.Vertical.NumberLine.Margins.LargeText,
        maxs.y,
        0, 1,
        verticalLabelCount
    )

    -- Label
    surface.SetFont( "CurveEditor_AxisLabel" )
    local verticalCenter = mins.y + math.floor( ( maxs.y - mins.y ) / 2 )
    curveDraw.DrawText(
        panel.Settings.Axis.Vertical.Label.Text,
        mins.x - panel.Settings.Axis.Vertical.NumberLine.Margins.LargeText - panel.Settings.Axis.Vertical.Label.RightMargin,
        verticalCenter,
        panel.Settings.Axis.Vertical.Label.Rotation
    )

    --[[ Horizontal Axis ]]--
    -- Axis line
    -- One of the two axis lines needs to extend backwards a little bit to cover the gap between them
    local originCoverOffset = math.ceil( panel.Settings.Axis.Vertical.Width / 2 )
    render.SetColorMaterial()
    curveDraw.DrawLine( mins.x - originCoverOffset, mins.y, maxs.x, mins.y, panel.Settings.Axis.Horizontal.Width, curveDraw.Colors.AxisLine )

    -- Numbers
    local horizontalLabelCount = math.ceil( width / panel.Settings.Axis.Horizontal.NumberLine.SpaceBetween )
    curveDraw.DrawNumberLine(
        mins.x,
        mins.y + panel.Settings.Axis.Horizontal.NumberLine.Margins.LargeText,
        maxs.x,
        mins.y + panel.Settings.Axis.Horizontal.NumberLine.Margins.LargeText,
        0, 1,
        horizontalLabelCount
    )

    -- Label
    surface.SetFont( "CurveEditor_AxisLabel" )
    local horizontalCenter = mins.x + math.floor( ( maxs.x - mins.x ) / 2 )
    curveDraw.DrawText( 
        panel.Settings.Axis.Horizontal.Label.Text,
        horizontalCenter,
        mins.y + panel.Settings.Axis.Horizontal.NumberLine.Margins.LargeText + panel.Settings.Axis.Horizontal.Label.TopMargin,
        panel.Settings.Axis.Horizontal.Label.Rotation
    )
end

-- Converts a point in graph coordinates to screenspace coordinates
---@param panel CurveEditor
---@param x number
---@param y number
---@return Vector
function curveDraw.GraphToScreen( panel, x, y )
    local screenFramePos = Vector( panel:LocalToScreen( 0, 0 ) )
    local graphMins, graphMaxs = panel:GetGraphMinsMaxs()
    local graphSize = graphMaxs - graphMins
    local screenOrigin = screenFramePos + graphMins
    return screenOrigin + Vector( x * graphSize.x, y * graphSize.y )
end

-- Converts a point in screenspace coordinates to graph coordinates
---@param panel CurveEditor
---@param x number
---@param y number
---@return Vector
function curveDraw.ScreenToGraph( panel, x, y )

end

---@param panel CurveEditor
---@param curvePoint CurvePoint
function curveDraw.DrawCurvePoint( panel, curvePoint )
    local graphMins, graphMaxs = panel:GetGraphMinsMaxs()
    local graphSize = graphMaxs - graphMins

    -- The point
    local pointPos = graphMins + curvePoint.Pos * graphSize
    surface.DrawRect( pointPos.x, pointPos.y, 20, 20 )

    -- Left Handle
    if curvePoint.LeftHandlePos then
        local pointLeftHandlePos = graphMins + curvePoint.LeftHandlePos * graphSize
        surface.DrawRect( pointLeftHandlePos.x, pointLeftHandlePos.y, 10, 10 )
    end

    -- Right Handle
    if curvePoint.RightHandlePos then
        local pointRightHandlePos = graphMins + curvePoint.RightHandlePos * graphSize
        surface.DrawRect( pointRightHandlePos.x, pointRightHandlePos.y, 10, 10 )
    end
end

---@param panel CurveEditor
---@param curve Curve
function curveDraw.DrawCurve( panel, curve )

    

    surface.SetDrawColor( Color( 255, 100, 75 ) )
    for k, curvePoint  in ipairs( curve.Points ) do
        curvePoint = curvePoint --[[@as CurvePoint]]

        
    end
end

---@param panel CurveEditor
---@param curve Curve
function curveDraw.DrawGraph( panel, curve )
    curveDraw.DrawAxis( panel )
    curveDraw.DrawGrid( panel )
    curveDraw.DrawCurve( panel, curve )
end

curveDraw.SetupFonts()

return curveDraw