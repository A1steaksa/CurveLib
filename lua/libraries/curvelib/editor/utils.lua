require( "vguihotload" )
if not _G.CurveLib or not istable( _G.CurveLib ) then
    error( "Curve Lib did not initialize correctly" )
elseif _G.CurveLib.Utils and not _G.CurveLib.IsDevelopment then
    return _G.CurveLib.Utils
end

--#region Alignment Enums

---@enum CurveLib.Alignment.Horizontal
HorizontalAlignment = {
    Left   = 4,
    Center = 5,
    Right  = 6
}

---@enum CurveLib.Alignment.Vertical
VerticalAlignment = {
    Top    = 8,
    Center = 5,
    Bottom = 2
}

---@enum CurveLib.Alignment
Alignment = {
    TopLeft      = 7,
    TopCenter    = 8,
    TopRight     = 9,

    CenterLeft   = 4,
    Center       = 5,
    CenterRight  = 6,

    BottomLeft   = 1,
    BottomCenter = 2,
    BottomRight  = 3
}

--#endregion Alignment Enums

---@class CurveLib.Editor.Utils
local utils = {}

-- Created here to avoid creating the table every time MultiFloor is called
local multifloor_buffer = {}

-- Rounds a variable set of numbers to their nearest integer and multi-returns them.
-- Thanks to SneakySquid for the optimizations.
---@vararg number
function utils.MultiFloor( ... )
    local arg_count = select( "#", ... )

    for i = 1, arg_count do
        multifloor_buffer[i] = math.floor( select( i, ... ) )
    end

    return unpack( multifloor_buffer, 1, arg_count )
end

-- Returns the offset, in pixels, to align a rectangle of the given width and height to the given alignment, relative to the top-left of the rectangle.
---@param width integer
---@param height integer
---@param alignment CurveLib.Alignment
---@param floorValues boolean? Whether to floor the values or not [Default: false]
---@return integer offsetX, integer offsetY
function utils.GetAlignmentOffset( width, height, alignment , floorValues )
    local x, y = 0, 0

    if alignment == Alignment.TopCenter or alignment == Alignment.Center or alignment == Alignment.BottomCenter then
        if floorValues then
            x = utils.MultiFloor( -width / 2 )
        else
            x = -width / 2
        end
    elseif alignment == Alignment.TopRight or alignment == Alignment.CenterRight or alignment == Alignment.BottomRight then
        x = -width
    end

    if alignment == Alignment.CenterLeft or alignment == Alignment.Center or alignment == Alignment.CenterRight then
        if floorValues then
            y = utils.MultiFloor( -height / 2 )
        else
            y = -height / 2
        end
    elseif alignment == Alignment.BottomLeft or alignment == Alignment.BottomCenter or alignment == Alignment.BottomRight then
        y = -height
    end

    return x, y
end

-- Defined here to avoid instantiating them each time GetRectangleCornerOffsets is called
local up = Vector( 0, 0 )
local right = Vector( 0, 0 )

-- Returns the offsets, in pixels, for each of a rectangle's corners relative to its center given a rotation. 
---@param width integer The rectangle's width, in pixels
---@param height integer The rectangle's height, in pixels
---@param rotation number? The rectangle's rotation, in degrees [Default: 0]
---@return Vector topRight, Vector bottomRight, Vector bottomLeft, Vector topLeft
function utils.GetRectangleCornerOffsets( width, height, rotation )
    local leftHalfWidth     = math.floor( width / 2 )
    local rightHalfWidth    = math.ceil( width / 2 )
    local topHalfHeight     = math.floor( height / 2 )
    local bottomHalfHeight  = math.ceil( height / 2 )

    if not rotation or rotation == 0 then
        return
            Vector(  rightHalfWidth, -topHalfHeight ),    -- Top Right
            Vector(  rightHalfWidth,  bottomHalfHeight ), -- Bottom Right
            Vector( -leftHalfWidth,   bottomHalfHeight ), -- Bottom Left
            Vector( -leftHalfWidth,  -topHalfHeight )     -- Top Left
    else
        local rotationRad = math.rad( rotation )
        local sin = math.sin( rotationRad )
        local cos = math.cos( rotationRad )

        up.x = sin
        up.y = -cos

        right.x = cos
        right.y = sin

        return
            up *  topHalfHeight     + right *  rightHalfWidth,  -- Top Right
            up * -bottomHalfHeight  + right *  rightHalfWidth,  -- Bottom Right
            up * -bottomHalfHeight  + right * -leftHalfWidth,   -- Bottom Left
            up *  topHalfHeight     + right * -leftHalfWidth    -- Top Left
    end
end

_G.CurveLib.Utils = utils

return _G.CurveLib.Utils