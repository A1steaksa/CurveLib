require( "vguihotload" )
if not _G.CurveLib or not istable( _G.CurveLib ) then
    error( "Curve Lib did not initialize correctly" )
elseif _G.CurveLib.IsDevelopment then
    vguihotload.HandleHotload( "CurveLib.EditorFrame" )
elseif _G.CurveLib.DrawBasic then return _G.CurveLib.DrawBasic end

---@type CurveEditor.CurveUtils
local curveUtils = include( "libraries/curvelib/utils.lua" )

---@class CurveEditor.DrawBasic
---@field PanelStack Stack
local Draw = {
    PanelStack = util.Stack()
}

--#region Editor Stack

---@return DPanel
function Draw.PeekPanel()
    return Draw.PanelStack:Top().Panel
end

---@param panel DPanel
function Draw.StartPanel( panel )
    Draw.PanelStack:Push( panel )

    local matrix = Matrix()
    matrix:Translate( Vector( panel:LocalToScreen( 0, 0 ) ) )
    cam.PushModelMatrix( matrix )
end

---@return DPanel Panel 
function Draw.EndPanel()
    cam.PopModelMatrix()
    local topElement = Draw.PeekPanel()
    Draw.PanelStack:Pop( 1 )
    return topElement
end

--#endregion Editor Stack

-- Draws text with rotation and alignment
---@param text any
---@param textX number The text's center position's x coordinate
---@param textY number The text's center position's y coordinate
---@param rotation number? The text's rotation, in degrees. [Default: 0]
---@param scale number|Vector? The text's scale either as a number or as a Vector [Default: 1]
---@param horizontalAlignment TEXT_ALIGN|integer? The text's horizontal alignment [Default: Centered]
---@param verticalAlignment TEXT_ALIGN|integer? The text's vertical alignment. [Default: Centered]
function Draw.Text( text, textX, textY, rotation, scale, horizontalAlignment, verticalAlignment )
    -- Scale must be a Vector for the Matrix scale
    if scale and not isvector( scale ) then
        scale = Vector( scale --[[@as number]], scale --[[@as number]] )
    end

    local textWidth, textHeight = surface.GetTextSize( text )

    local alignment = Vector( -math.floor( textWidth / 2 ), -math.floor( textHeight / 2 ) )

    if horizontalAlignment == TEXT_ALIGN_LEFT then
        alignment.x = -textWidth
    elseif horizontalAlignment == TEXT_ALIGN_RIGHT then
        -- No horizontal offset because text is bottom-right aligned by default
        alignment.x = 0
    end

    if verticalAlignment == TEXT_ALIGN_TOP then
        alignment.y = -textHeight
    elseif verticalAlignment == TEXT_ALIGN_BOTTOM then
        -- No vertical offset because text is bottom-right aligned by default
        alignment.y = 0
    end

    local currentTranslation = cam.GetModelMatrix():GetTranslation()

    local newMatrix = Matrix()
    -- 6. Position the finished text, relative to the current Matrix.
    newMatrix:Translate( Vector( textX, textY ) )
    -- 5. Re-do the current Matrix's translation so we're back where we started.
    newMatrix:Translate( currentTranslation )
    -- 4. Rotate the text.
    if rotation and isnumber( rotation ) then
        newMatrix:Rotate( Angle( 0, rotation, 0 ) )
    end
    -- 3. Scale the text.
    if scale then
        if isnumber( scale ) then
            newMatrix:Scale(
                Vector(
                    scale --[[@as number]],
                    scale --[[@as number]]
                )
            )
        else
            newMatrix:Scale( scale --[[@as Vector]] )
        end
    end
    -- 2. Move based on the text alignment.
    newMatrix:Translate( alignment )
    -- 1. Undo the current Matrix's translation so we're back at 0,0.
    newMatrix:Translate( -currentTranslation )

    cam.PushModelMatrix( newMatrix, false )
        surface.SetTextPos( 0, 0 ) -- The Model Matrix handles positioning the text for us.
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

_G.CurveLib.DrawBasic = Draw
return _G.CurveLib.DrawBasic