AddCSLuaFile()

---@enum CURVE_END_TYPE
CURVE_END_TYPE = {
    SMOOTH  = 1,
    SHARP   = 2
}

--[[--------------------------------------------------------------------]]--

---@class CurvePoint
---@field Pos Vector
---@field LeftHandlePos Vector?
---@field RightHandlePos Vector?
local curvePoint = {
    Pos             = Vector( 0, 0 ),
    LeftHandlePos   = nil,
    RightHandlePos  = nil
}
curvePoint.__index = curvePoint

--- Creates a new CurvePoint
---@return CurvePoint
function CurvePoint( pos, leftHandlePos, rightHandlePos )
    ---@type CurvePoint
    local instance = {
        Pos = pos,
        LeftHandlePos = leftHandlePos,
        RightHandlePos = rightHandlePos
    }
    setmetatable( instance, curvePoint )

    return instance
end

--[[--------------------------------------------------------------------]]--

---@class Curve
---@field Points table<CurvePoint>
local curve = {
    Points = {}
}
curve.__index = curve

function curve:__call( x )
    print( x )
end

--- Creates a new Curve
---@param curvePoints table<CurvePoint>?
---@return Curve
function Curve( curvePoints )
    ---@type Curve
    local instance = {}

    if curvePoints then 
        instance.Points = curvePoint
    else
        instance.Points = {
            CurvePoint( Vector( 0, 0 ), nil, Vector( 0.25, 0.25 ) ),
            CurvePoint( Vector( 1, 1 ), Vector( 0.75, 0.75 ), nil )
        }
    end

    setmetatable( instance, curve )

    return instance
end

