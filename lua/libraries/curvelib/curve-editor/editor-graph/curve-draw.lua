require( "vguihotload" )
if not _G.CurveLib or not istable( _G.CurveLib ) then
    error( "Curve Lib did not initialize correctly" )
elseif _G.CurveLib.IsDevelopment then
    vguihotload.HandleHotload( "CurveLib.EditorFrame" )
elseif _G.CurveLib.CurveDraw then return _G.CurveLib.CurveDraw end

---@type CurveUtils
local curveUtils = include( "libraries/curvelib/utils.lua" )

---@class CurveEditor.EditorGraph.CurveDraw
local Draw = {
    PanelStack = util.Stack()
}

--#region Editor Stack

-- Pushes a DPanel onto the stack
---@param panel DPanel
function Draw.PushPanel( panel )
    Draw.PanelStack:Push( panel )

    local matrix = Matrix()
    matrix:Translate( Vector( panel:LocalToScreen( 0, 0 ) ) )
    cam.PushModelMatrix( matrix )
end

-- Pops a DPanel off the stack
---@return DPanel
function Draw.PopPanel()
    cam.PopModelMatrix()
    local topElement = Draw.PanelStack:Top()
    Draw.PanelStack:Pop( 1 )
    return topElement
end

-- Peeks (Returns) the top DPanel of the Panel Stack
---@return DPanel
function Draw.PeekPanel()
    return Draw.PanelStack:Top()
end

--#endregion Editor Stack

-- Draws a rectangle with a given color
---@param startX integer
---@param startY integer
---@param width integer
---@param height integer
---@param color Color
function Draw.SimpleRect( startX, startY, width, height, color )
    render.SetColorMaterial()
    local r, g, b, a = color:Unpack()
    mesh.Begin( MATERIAL_QUADS, 1 )
        mesh.Color( r, g, b, a )
        mesh.Position( Vector( startX, startY ) )
        mesh.AdvanceVertex()

        mesh.Color( r, g, b, a )
        mesh.Position( Vector( startX + width, startY ) )
        mesh.AdvanceVertex()

        mesh.Color( r, g, b, a )
        mesh.Position( Vector( startX + width, startY + height ) )
        mesh.AdvanceVertex()

        mesh.Color( r, g, b, a )
        mesh.Position( Vector( startX, startY + height ) )
        mesh.AdvanceVertex()
    mesh.End()
end

-- Draws a line between two points.
---@param startX integer
---@param startY integer
---@param endX integer
---@param endY integer
---@param lineWidth number
---@param color Color
function Draw.SimpleLine( startX, startY, endX, endY, lineWidth, color )
    startX, startY, endX, endY = curveUtils.MultiFloor( startX, startY, endX, endY )

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
    -- Thanks to Freya Holmér for the idea
    if lineWidth < 1 and lineWidth > 0 then
        local alpha = color.a * lineWidth
        color.a = alpha
    end

    render.SetColorMaterial()
    
    local r, g, b, a = color:Unpack()
    mesh.Begin( MATERIAL_QUADS, 1 )
        mesh.Color( r, g, b, a )
        mesh.Position( startPos + rightOffset )
        mesh.AdvanceVertex()

        mesh.Color( r, g, b, a )
        mesh.Position( startPos + leftOffset )
        mesh.AdvanceVertex()

        mesh.Color( r, g, b, a )
        mesh.Position( endPos   + leftOffset )
        mesh.AdvanceVertex()

        mesh.Color( r, g, b, a )
        mesh.Position( endPos   + rightOffset )
        mesh.AdvanceVertex()
    mesh.End()
end

-- Draws the currently pushed Editor Frame's Editor Graph
---@param width integer The width of the graph
---@param height integer The height of the graph
function Draw.Graph( width, height )
    Draw.SimpleRect( 0, 0, width, height, Color( 75, 100, 135, 255 ) )

    local cos = math.cos( CurTime() )
    local sin = math.sin( CurTime() )

    local center = Vector( math.floor( width / 2 ), math.floor( height / 2 ) )

    local xSize = width / 3
    local ySize = height / 8

    local startPos = center + Vector( cos * xSize, sin * ySize )
    local endPos = center + Vector( cos * -xSize, sin * -ySize )

    Draw.SimpleLine( startPos.x, startPos.y, endPos.x, endPos.y, 5, Color( 255, 255, 0, 255 ) )
end

_G.CurveLib.CurveDraw = Draw
return _G.CurveLib.CurveDraw