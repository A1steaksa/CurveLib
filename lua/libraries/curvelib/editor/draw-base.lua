if not CLIENT then return end

require( "vguihotload" )
if not _G.CurveLib or not istable( _G.CurveLib ) then
    error( "Curve Lib did not initialize correctly" )
elseif _G.CurveLib.IsDevelopment then
    vguihotload.HandleHotload( "CurveLib.Editor.Frame" )
elseif _G.CurveLib.DrawBase then return _G.CurveLib.DrawBase end

---@type CurveLib.Editor.Utils
local curveUtils = include( "libraries/curvelib/editor/utils.lua" )

local COLOR_WHITE = Color( 255, 255, 255, 255 )

local VECTOR_ZERO = Vector( 0, 0, 0 )
local VECTOR_ONE = Vector( 1, 1, 1 )

local iMeshColorMaterial = CreateMaterial( "CurveLib_DrawBase_IMeshColor", "UnlitGeneric", {
    ["$basetexture"] = "color/white",
    ["$vertexcolor"] = 1,
    ["$vertexalpha"] = 1,
    ["$model"] = 1
} )

---@class CurveLib.Editor.DrawBase.Caches
---@field Circles CurveLib.Editor.DrawBase.Caches.Circles

---@class CurveLib.Editor.DrawBase.Caches.Circles
---@field Meshes table<integer, IMesh> The Meshes for each generated circle vertex count

---@class CurveLib.Editor.DrawBase
---@field PanelStack Stack
---@field Caches CurveLib.Editor.DrawBase.Caches
local DRAW = {
    PanelStack = util.Stack(),
    Caches = {
        Circles = {
            Meshes = {}
        }
    }
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

-- Draws a rectangle with a given color and rotation.
---@param x integer
---@param y integer
---@param width integer
---@param height integer
---@param rotation number? The angle of the rectangle, in degrees [Default: 0]
---@param alignment CurveLib.Alignment? The alignment of the rectangle [Default: Top left]
---@param color Color? Default: `surface.GetDrawColor` or white if not set.
function DRAW.Rect( x, y, width, height, rotation, alignment, color )
    local r, g, b, a = 255, 255, 255, 255
    if color then
        r, g, b, a = color:Unpack()
    else
        local drawColor = surface.GetDrawColor()
        if drawColor then
            r, g, b, a = drawColor.r, drawColor.g, drawColor.b, drawColor.a
        end
    end

    local x, y, width, height, halfWidth, halfHeight = curveUtils.MultiFloor( x, y, width, height, width / 2, height / 2 )
    local topRight, bottomRight, bottomLeft, topLeft = curveUtils.GetRectangleCornerOffsets( width, height, 0 )
    local alignOffsetX, alignOffsetY = curveUtils.GetAlignmentOffset( width, height, alignment or Alignment.TopLeft, true )

    local newMatrix = Matrix()

    -- 3. Move to our draw position
    newMatrix:Translate( Vector( x, y ) )

    -- 2. Apply rotation around 0,0
    newMatrix:Rotate( Angle( 0, rotation, 0 ) )

    -- 1. Offset alignment while we're at 0,0
    newMatrix:Translate( Vector( alignOffsetX + halfWidth, alignOffsetY + halfHeight ) )

    render.SetColorMaterial()
    cam.PushModelMatrix( newMatrix, true )
        DRAW.StartMesh( MATERIAL_QUADS, 1 )
            mesh.Color( r, g, b, a )
            mesh.Position( topRight )
            mesh.AdvanceVertex()

            mesh.Color( r, g, b, a )
            mesh.Position( bottomRight )
            mesh.AdvanceVertex()

            mesh.Color( r, g, b, a )
            mesh.Position( bottomLeft )
            mesh.AdvanceVertex()

            mesh.Color( r, g, b, a )
            mesh.Position( topLeft )
            mesh.AdvanceVertex()
        DRAW.EndMesh()
    cam.PopModelMatrix()
end

-- Draws a circle
---@param x integer
---@param y integer
---@param diameter integer|Vector The diameter of the circle, in pixels. Can be a Vector to specify an ellipse.
---@param rotation number? The angle of the circle, in degrees. Default: 0
---@param vertexCount? integer The number of vertices the circle will have. The higher the number, the smoother the circle. Default: Calculated based on diameter.
---@param alignment CurveLib.Alignment? The circle's alignment [Default: Top left]
---@param color Color? Default: `surface.GetDrawColor` or white if not set.
function DRAW.Circle( x, y, diameter, rotation, vertexCount, alignment, color )
    if not isnumber( x ) or not isnumber( y ) or ( not isnumber( diameter ) and not isvector( diameter ) ) or ( vertexCount and not isnumber( vertexCount ) ) then
        error( "Invalid arguments to DRAW.Circle" )
        return
    end

    local r, g, b, a = 255, 255, 255, 255
    if color then
        r, g, b, a = color:Unpack()
    else
        local drawColor = surface.GetDrawColor()
        if drawColor then
            r, g, b, a = drawColor.r, drawColor.g, drawColor.b, drawColor.a
        end
    end

    local width, height
    local size
    if isvector( diameter ) then
        width, height = diameter.x, diameter.y
        size = diameter --[[@as Vector]]
    elseif isnumber( diameter ) then
        width, height = diameter --[[@as number]],
            diameter --[[@as number]]
        size = Vector(
            diameter --[[@as number]],
            diameter --[[@as number]]
        )
    else
        error( "Invalid diameter argument to DRAW.Circle" )
        return
    end

    local alignOffsetX, alignOffsetY = curveUtils.GetAlignmentOffset( width, height, alignment or Alignment.TopLeft, false )

    if not vertexCount or vertexCount < 10 then

        local maxRadius = math.max( width, height ) / 4

        -- Dividing by 10 gives us a good balance between performance and quality, but can be adjusted.
        local calculatedVertexCount = math.floor( maxRadius / 4 )

        -- 10 has been chosen as the minimum vertex count to prevent the circle from looking like a simple polygon.
        vertexCount = math.max( 10, calculatedVertexCount )
    end

    local circleMesh = DRAW.Caches.Circles.Meshes[ vertexCount ]
    if not circleMesh then
        circleMesh = Mesh( iMeshColorMaterial )
        DRAW.Caches.Circles.Meshes[ vertexCount ] = circleMesh

        local radsPerVertex = math.rad( 360 / vertexCount )

        DRAW.StartMesh( circleMesh, MATERIAL_POLYGON, vertexCount )
            for vertexNumber = 1, vertexCount do
                local angle = radsPerVertex * vertexNumber
                local vertex = Vector( math.cos( angle ), math.sin( angle ) )

                mesh.TexCoord( 0, vertex.x, vertex.y )
                mesh.Color( 255, 255, 255, 255 )
                mesh.Position( vertex )
                mesh.AdvanceVertex()
            end
        DRAW.EndMesh()
    end

    local newMatrix = Matrix()

    -- 5. Move to the draw position
    newMatrix:Translate( Vector( x, y ) )

    -- 4. Rotation
    if rotation then
        newMatrix:Rotate( Angle( 0, rotation, 0 ) )
    end

    -- 3. Offset alignment
    newMatrix:Translate( Vector( alignOffsetX * 2, alignOffsetY * 2 ) )

    -- 2. Offset the circle to be top-left aligned so the alignment offsets work correctly.
    newMatrix:Translate( size )

    -- 1. Scale
    newMatrix:Scale( size )

    -- Hacky color amd alpha via Material properties because IMeshes don't appear to receive color or blend settings from the render library.
    iMeshColorMaterial:SetVector( "$color", Vector( r / 255, g / 255, b / 255 ) )
    iMeshColorMaterial:SetFloat( "$alpha", a / 255 )
    render.SetMaterial( iMeshColorMaterial )

    cam.PushModelMatrix( newMatrix, true )
        circleMesh:Draw()
    cam.PopModelMatrix()
end

-- Draws text with rotation and alignment
---@param text string
---@param x integer
---@param y integer
---@param rotation number? The text's rotation, in degrees. [Default: 0]
---@param scale number|Vector? The text's scale either as a number or as a Vector [Default: 1]
---@param alignment CurveLib.Alignment? The text's alignment [Default: Top left]
---@param color Color? The text's color.  [Default: Surface.GetDrawColor]
function DRAW.Text( text, x, y, rotation, scale, alignment, color )
    -- Scale must be a Vector for the Matrix scale
    if scale and not isvector( scale ) then
        scale = Vector( scale --[[@as number]], scale --[[@as number]] )
    end

    if color and IsColor( color ) then
        surface.SetTextColor( color )
    end

    local existingTranslation = cam.GetModelMatrix():GetTranslation()

    local scaleVector = VECTOR_ONE
    if scale then
        if isnumber( scale ) then
            scaleVector = Vector( scale --[[@as number]], scale --[[@as number]] )
        elseif isvector( scale ) then
            scaleVector = scale--[[@as Vector]]
        end
    end

    local newMatrix = Matrix()

    -- 6. Move to our draw position
    newMatrix:Translate( Vector( curveUtils.MultiFloor( x, y ) ) )

    -- 5. Move back to the panel we're drawing on
    newMatrix:Translate( existingTranslation )

    -- 4. Apply rotation around 0,0
    if rotation and isnumber( rotation ) then
        newMatrix:Rotate( Angle( 0, rotation, 0 ) )
    end

    -- 3. Offset alignment
    local textWidth, textHeight = surface.GetTextSize( text )
    textWidth = textWidth * scaleVector.x
    textHeight = textHeight * scaleVector.y
    local alignOffsetX, alignOffsetY = curveUtils.MultiFloor( curveUtils.GetAlignmentOffset( textWidth, textHeight, alignment or Alignment.TopLeft ) )
    newMatrix:Translate( Vector( alignOffsetX, alignOffsetY ) )

    -- 2. Scale the text.
    newMatrix:Scale( scaleVector )

    -- 1. Move to 0,0 
    newMatrix:Translate( -existingTranslation )

    cam.PushModelMatrix( newMatrix, false )

    surface.SetTextPos( 0, 0 ) -- The Model Matrix handles positioning the text for us.
    surface.DrawText( text )

    cam.PopModelMatrix()
end

-- Draws a line between two points.
---@param startX integer
---@param startY integer
---@param endX integer
---@param endY integer
---@param lineWidth number
---@param alignment CurveLib.Alignment.Horizontal? Controls which side, facing from the start of the line to the end, the drawn line should be aligned to. Default: Centered
---@param color Color? Default: `surface.GetDrawColor` or white if not set.
function DRAW.Line( startX, startY, endX, endY, lineWidth, alignment, color )
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
        lineWidth = 1
    end

    local startPos  = Vector( startX, startY )
    local endPos    = Vector( endX, endY )

    -- In this function, we're going to assuming "forward" is the 
    -- direction from the start position to the end position.
    -- "Left" and "Right" are relative to that forward direction.
    local direction = ( endPos - startPos ):GetNormalized()
    -- Offset perpendicular (right facing) to the direction of the line
    local offsetDirection = Vector( direction.y, direction.x )--:GetNormalized()
    local leftOffsetDirection  = Vector( offsetDirection.x, -offsetDirection.y )
    local rightOffsetDirection = Vector( -offsetDirection.x, offsetDirection.y )

    local leftOffset
    local rightOffset
    if alignment == HorizontalAlignment.Left then
        leftOffset = VECTOR_ZERO
        rightOffset = rightOffsetDirection * lineWidth
    elseif alignment == HorizontalAlignment.Right then
        leftOffset = leftOffsetDirection * lineWidth
        rightOffset = VECTOR_ZERO
    else
        local halfWidth = lineWidth / 2.0

        leftOffset  = leftOffsetDirection * math.max( math.floor( halfWidth ), 0 )
        rightOffset = rightOffsetDirection * math.max( math.ceil( halfWidth ), 1 )
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
---@param alignment CurveLib.Alignment.Horizontal? Controls which side, facing from the start of the line to the end, the drawn line should be aligned to. One of the `LINE_ALIGN_*` enums.  Default: Centered
function DRAW.MultiLine( points, lineWidth, color, alignment )
    if not points or not istable( points ) or #points <= 1 or not isvector( points[1] ) then
        error( "Invalid arguments to DRAW.MultiLine" )
        return
    end

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

    render.SetColorMaterial()
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
            
            local angle = math.atan2( direction.y, direction.x )
            local nextAngle = math.atan2( nextDirection.y, nextDirection.x )

            local theta = ( nextAngle - angle ) / 2

            -- BUG: As cos( theta ) approaches 0, the line width approaches infinity.
            local calculatedHalfWidth = math.abs( halfWidth / math.cos( theta ) )

            -- This limits the line width to fix the above issue.
            calculatedHalfWidth = math.min( calculatedHalfWidth, lineWidth )

            local nextPerpendicular = Vector( -nextDirection.y, nextDirection.x )

            local jointDirection = ( ( perpendicular + nextPerpendicular ) / 2 ):GetNormalized()

            lineEndOffset = jointDirection * calculatedHalfWidth
        end

        local startLeft = lineStart - lineStartOffset
        local startRight = lineStart + lineStartOffset
        local endLeft = lineEnd - lineEndOffset
        local endRight = lineEnd + lineEndOffset

        if alignment and alignment ~= HorizontalAlignment.Center then
            local leftOffset, rightOffset
            if alignment == HorizontalAlignment.Left then
                leftOffset = VECTOR_ZERO
                rightOffset = perpendicular * lineWidth
            elseif alignment == HorizontalAlignment.Right then
                leftOffset = perpendicular * -lineWidth
                rightOffset = VECTOR_ZERO
            end

            startLeft = startLeft + leftOffset
            startRight = startRight + rightOffset
            endLeft = endLeft + leftOffset
            endRight = endRight + rightOffset
        end

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