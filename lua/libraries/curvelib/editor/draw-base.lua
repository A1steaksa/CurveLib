require( "vguihotload" )
if not _G.CurveLib or not istable( _G.CurveLib ) then
    error( "Curve Lib did not initialize correctly" )
elseif _G.CurveLib.IsDevelopment then
    vguihotload.HandleHotload( "CurveLib.Editor.Frame" )
elseif _G.CurveLib.DrawBase then return _G.CurveLib.DrawBase end

---@type CurveLib.Editor.Utils
local curveUtils = include( "libraries/curvelib/editor/utils.lua" )

---@class CurveLib.Editor.DrawBase
---@field PanelStack Stack
local DRAW = {
    PanelStack = util.Stack()
}

--#region Editor Stack

---@return DPanel
function DRAW.PeekPanel()
    return DRAW.PanelStack:Top().Panel
end

---@param panel DPanel
function DRAW.StartPanel( panel )
    DRAW.PanelStack:Push( panel )

    local matrix = Matrix()
    matrix:Translate( Vector( panel:LocalToScreen( 0, 0 ) ) )
    cam.PushModelMatrix( matrix )
end

---@return DPanel Panel 
function DRAW.EndPanel()
    cam.PopModelMatrix()
    local topElement = DRAW.PeekPanel()
    DRAW.PanelStack:Pop( 1 )
    return topElement
end

--#endregion Editor Stack

--#region Mesh Functions

-- Starts a new dynamic mesh. If an IMesh is passed as the first argument, that will be edited instead.
---@param iMesh IMesh|number Mesh to build. This argument can be removed if you wish to build a "dynamic" mesh. See examples below.
---@param primitiveType number Primitive type, see Enums/MATERIAL.
---@param primitiveCount number? The number of `primitiveType` primitives the Mesh will contain.
function DRAW.StartMesh( iMesh, primitiveType, primitiveCount )
    _G.CurveLib.IsDrawingMesh = true
    mesh.Begin( iMesh, primitiveType, primitiveCount )
end

-- Ends the mesh and renders it.
function DRAW.EndMesh()
    mesh.End()
    _G.CurveLib.IsDrawingMesh = nil
end

--#endregion Mesh Functions

-- Draws a rectangle with a given color
-- Rectangles are bottom-right aligned if no rotation is provided or if the rotation is 0
---@param x integer
---@param y integer
---@param width integer
---@param height integer
---@param rotation number? The angle of the rectangle, in degrees [Default: 0]
---@param color Color? Default: `surface.GetDrawColor` or white if not set.
function DRAW.Rect( x, y, width, height, rotation, color )
    render.SetColorMaterial()

    local r, g, b, a = 255, 255, 255, 255
    if color then
        r, g, b, a = color:Unpack()
    else
        local drawColor = surface.GetDrawColor()
        if drawColor then
            r, g, b, a = drawColor.r, drawColor.g, drawColor.b, drawColor.a
        end
    end

    local topRight, bottomRight, bottomLeft, topLeft = curveUtils.GetRectangleCornerOffsets( width, height, rotation )

    local center = Vector( x, y )

    DRAW.StartMesh( MATERIAL_QUADS, 1 )
        mesh.Color( r, g, b, a )
        mesh.Position( center + topRight )
        mesh.AdvanceVertex()

        mesh.Color( r, g, b, a )
        mesh.Position( center + bottomRight )
        mesh.AdvanceVertex()

        mesh.Color( r, g, b, a )
        mesh.Position( center + bottomLeft )
        mesh.AdvanceVertex()

        mesh.Color( r, g, b, a )
        mesh.Position( center + topLeft )
        mesh.AdvanceVertex()
    DRAW.EndMesh()
end

-- Draws text with rotation and alignment
---@param text any
---@param textX number The text's center position's x coordinate
---@param textY number The text's center position's y coordinate
---@param rotation number? The text's rotation, in degrees. [Default: 0]
---@param scale number|Vector? The text's scale either as a number or as a Vector [Default: 1]
---@param horizontalAlignment TEXT_ALIGN|integer? The text's horizontal alignment [Default: Centered]
---@param verticalAlignment TEXT_ALIGN|integer? The text's vertical alignment. [Default: Centered]
---@param color Color? The text's color.  [Default: Surface.GetDrawColor]
function DRAW.Text( text, textX, textY, rotation, scale, horizontalAlignment, verticalAlignment, color )
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
    
    if color and IsColor( color ) then
        surface.SetTextColor( color )
    end

    cam.PushModelMatrix( newMatrix, false )
        surface.SetTextPos( 0, 0 ) -- The Model Matrix handles positioning the text for us.
        surface.DrawText( text )
    cam.PopModelMatrix()
end

LINE_ALIGN_LEFT = 0
LINE_ALIGN_RIGHT = 1
LINE_ALIGN_CENTER = 2

COLOR_WHITE = Color( 255, 255, 255, 255 )

VECTOR_ZERO = Vector( 0, 0, 0 )

-- Draws a line between two points.
---@param startX integer
---@param startY integer
---@param endX integer
---@param endY integer
---@param lineWidth number
---@param color Color? Default: `surface.GetDrawColor` or white if not set.
---@param alignment integer? Controls which side, facing from the start of the line to the end, the drawn line should be aligned to. One of the `LINE_ALIGN_*` enums.  Default: Centered
function DRAW.Line( startX, startY, endX, endY, lineWidth, color, alignment )
    startX, startY, endX, endY = curveUtils.MultiFloor( startX, startY, endX, endY )

    local r, g, b, a = 255, 255, 255, 255
    if color then
        r, g, b, a = color:Unpack()
    else
        local drawColor = surface.GetDrawColor()
        if drawColor then
            r, g, b, a = drawColor.r, drawColor.g, drawColor.b, drawColor.a
        end
    end

    -- Handle lines narrower than 1 pixel by lowering their alpha
    -- Thanks to Freya Holmér for the idea
    if lineWidth < 1 and lineWidth > 0 then
        a = a * lineWidth
    end

    local startPos  = Vector( startX, startY )
    local endPos    = Vector( endX, endY )

    -- In this function, we're going to assuming "forward" is the 
    -- direction from the start position to the end position.
    -- "Left" and "Right" are relative to that forward direction.
    local direction = ( endPos - startPos ):GetNormalized()
    -- Offset perpendicular (right facing) to the direction of the line
    local offsetDirection = Vector( direction.y, direction.x ):GetNormalized()
    local leftOffsetDirection  = Vector( offsetDirection.x, -offsetDirection.y )
    local rightOffsetDirection = Vector( -offsetDirection.x, offsetDirection.y )

    local leftOffset
    local rightOffset
    if not alignment or alignment == LINE_ALIGN_CENTER then
        local halfWidth = lineWidth / 2.0

        leftOffset  = leftOffsetDirection * math.max( math.floor( halfWidth ), 0 )
        rightOffset = rightOffsetDirection * math.max( math.ceil( halfWidth ), 1 )
    elseif alignment == LINE_ALIGN_LEFT then
        leftOffset = VECTOR_ZERO
        rightOffset = rightOffsetDirection * lineWidth
    elseif alignment == LINE_ALIGN_RIGHT then
        leftOffset = leftOffsetDirection * lineWidth
        rightOffset = VECTOR_ZERO
    else
        error( "Invalid line alignment: " .. alignment )
    end

    render.SetColorMaterial()
    DRAW.StartMesh( MATERIAL_QUADS, 1 )
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
    DRAW.EndMesh()
end

-- Draws a multi-segment line through a given series of points
---@param points table<Vector> A sequential, numerically-indexed table of the points the lines will be drawn between, in order.
---@param lineWidth integer The width of the line, in pixels
---@param color Color?
---@param alignment integer? Controls which side, facing from the start of the line to the end, the drawn line should be aligned to. One of the `LINE_ALIGN_*` enums.  Default: Centered
function DRAW.MultiLine( points, lineWidth, color, alignment )
    if not points or not istable( points ) or #points <= 1 or not isvector( points[1] ) then return end

    local r, g, b, a = 255, 255, 255, 255
    if color then
        r, g, b, a = color:Unpack()
    else
        local drawColor = surface.GetDrawColor()
        if drawColor then
            r, g, b, a = drawColor.r, drawColor.g, drawColor.b, drawColor.a
        end
    end

    local halfWidth = math.floor( lineWidth / 2 )
    local segmentCount = #points - 1

    local lastLineEndOffset

    DRAW.StartMesh( MATERIAL_QUADS, segmentCount )
    for segmentNumber = 1, segmentCount do
        local lineStart = points[ segmentNumber ]
        local lineEnd = points[ segmentNumber + 1 ]
        local nextLineEnd = points[ segmentNumber + 2 ]

        local direction = ( lineEnd - lineStart ):GetNormalized() --[[@as Vector]]
        local perpendicular = Vector( -direction.y, direction.x )

        local lineStartOffset
        if segmentNumber == 1 then
            lineStartOffset = perpendicular * halfWidth
        else
            lineStartOffset = lastLineEndOffset
        end
        
        local lineEndOffset
        if segmentNumber == segmentCount then
            lineEndOffset = perpendicular * halfWidth
        else
            local nextDirection = ( nextLineEnd - lineEnd ):GetNormalized()
            local nextPerpendicular = Vector( -nextDirection.y, nextDirection.x )

            local angle = math.atan2( direction.y, direction.x )
            local nextAngle = math.atan2( nextDirection.y, nextDirection.x )

            local theta = ( nextAngle - angle ) / 2

            local calculatedLineWidth = halfWidth / math.cos( theta )

            local jointDirection = ( ( perpendicular + nextPerpendicular ) / 2 ):GetNormalized()

            lineEndOffset = jointDirection * calculatedLineWidth
        end

        local startLeft = lineStart - lineStartOffset
        local startRight = lineStart + lineStartOffset
        local endLeft = lineEnd - lineEndOffset
        local endRight = lineEnd + lineEndOffset

        mesh.Color( r, g, b, a )
        mesh.Position( startLeft )
        mesh.AdvanceVertex()

        mesh.Color( r, g, b, a )
        mesh.Position( endLeft )
        mesh.AdvanceVertex()

        mesh.Color( r, g, b, a )
        mesh.Position( endRight )
        mesh.AdvanceVertex()

        mesh.Color( r, g, b, a )
        mesh.Position( startRight )
        mesh.AdvanceVertex()

        lastLineEndOffset = lineEndOffset
    end
    DRAW.EndMesh()
end

_G.CurveLib.DrawBase = DRAW
return _G.CurveLib.DrawBase