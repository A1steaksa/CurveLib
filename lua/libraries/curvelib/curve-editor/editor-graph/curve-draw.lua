require( "vguihotload" )
if not _G.CurveLib or not istable( _G.CurveLib ) then
    error( "Curve Lib did not initialize correctly" )
elseif _G.CurveLib.IsDevelopment then
    vguihotload.HandleHotload( "CurveLib.EditorFrame" )
elseif _G.CurveLib.CurveDraw then return _G.CurveLib.CurveDraw end

---@type CurveUtils
local curveUtils = include( "libraries/curvelib/utils.lua" )

---@class CurveEditor.EditorGraph.CurveDraw
---@field PanelStack Stack
local Draw = {
    PanelStack = util.Stack()
}

--#region Config

-- Config
---@class (exact) CurveEditor.EditorGraph.Config : table
---@field Fonts CurveEditor.EditorGraph.Config.Fonts

-- Fonts
---@class (exact) CurveEditor.EditorGraph.Config.Fonts : table
---@field NumberLineLarge string
---@field NumberLineSmall string

---@type CurveEditor.EditorGraph.Config
Draw.DefaultConfig = {
    Fonts = {
        NumberLineLarge = "HudHintTextLarge",
        NumberLineSmall = "HudHintTextSmall"
    }
}

Draw.ConfigMetatable = {}
Draw.ConfigMetatable.__index = Draw.DefaultConfig

-- Creates a new Curve Editor Graph Config table with the default settings
function CurveEditorGraphConfig()
    local config = {}
    setmetatable( config, Draw.ConfigMetatable )
    return config
end
--#endregionConfig

--#region Editor Stack

---@param panel DPanel
---@param config CurveEditor.EditorGraph.Config
function Draw.StartPanel( panel, config )
    Draw.PanelStack:Push( { Panel = panel, Config = config } )

    local matrix = Matrix()
    matrix:Translate( Vector( panel:LocalToScreen( 0, 0 ) ) )
    cam.PushModelMatrix( matrix )
end

---@return { Panel: DPanel, Config: CurveEditor.EditorGraph.Config }
function Draw.EndPanel()
    cam.PopModelMatrix()
    local topElement = Draw.PanelStack:Top()
    Draw.PanelStack:Pop( 1 )
    return topElement
end

---@return DPanel
function Draw.PeekPanel()
    return Draw.PanelStack:Top().Panel
end

---@return CurveEditor.EditorGraph.Config
function Draw.PeekConfig()
    return Draw.PanelStack:Top().Config
end
--#endregion Editor Stack

--#region Basic Drawing Functions

-- Draws text with rotation and alignment
---@param text any
---@param textX number The text's center position's x coordinate
---@param textY number The text's center position's y coordinate
---@param rotation number? The text's rotation, in degrees. [Default: 0]
---@param horizontalAlignment TEXT_ALIGN|integer? The text's horizontal alignment [Default: Centered]
---@param verticalAlignment TEXT_ALIGN|integer? The text's vertical alignment. [Default: Centered]
function Draw.Text( text, textX, textY, rotation, horizontalAlignment, verticalAlignment )
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

    local oldMatrix = cam.GetModelMatrix()

    local newMatrix = Matrix()
    newMatrix:Translate( Vector( textX, textY ) )            -- 5. Position the now-rotated text.
    newMatrix:Translate( oldMatrix:GetTranslation() )        -- 4. Re-do the current matrix's translation so we're back where we started
    newMatrix:Rotate( Angle( 0, rotation, 0 ) )              -- 3. Rotate around 0,0
    newMatrix:Translate( -oldMatrix:GetTranslation() )       -- 2. Undo the current matrix's translation so we can rotate around 0,0
    newMatrix:Translate( -Vector( xAlignment, yAlignment ) ) -- 1. Move based on the text alignment

    cam.PushModelMatrix( newMatrix, false )
        surface.SetTextPos( 0, 0 ) -- The Model Matrix handles positioning the text for us
        surface.DrawText( text )
    cam.PopModelMatrix()
end

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
--#endregion Basic Drawing Functions

--#region Compound Drawing Functions

-- Draws the currently pushed Editor Frame's Editor Graph
---@param x integer The x position of the graph
---@param y integer The y position of the graph
---@param width integer The width of the graph
---@param height integer The height of the graph
function Draw.Graph( x, y, width, height )
    local config = Draw.PeekConfig()

    Draw.SimpleRect( x, y, width, height, Color( 75, 100, 135, 255 ) )

    local cos = math.cos( CurTime() )
    local sin = math.sin( CurTime() )

    local center = Vector( x, y ) + Vector( math.floor( width / 2 ), math.floor( height / 2 ) )

    local xSize = width / 3
    local ySize = height / 8

    local startPos = center + Vector( cos * xSize, sin * ySize )
    local endPos = center + Vector( cos * -xSize, sin * -ySize )

    Draw.SimpleLine( startPos.x, startPos.y, endPos.x, endPos.y, 5, Color( 255, 255, 0, 255 ) )

    surface.SetFont( config.Fonts.NumberLineLarge )
    Draw.Text( "Big Text!", endPos.x, endPos.y, 0, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

    surface.SetFont( config.Fonts.NumberLineSmall )
    Draw.Text( "Small Text!", startPos.x, startPos.y, 0, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
end
--#endregion Compound Drawing Functions

_G.CurveLib.CurveDraw = Draw
return _G.CurveLib.CurveDraw