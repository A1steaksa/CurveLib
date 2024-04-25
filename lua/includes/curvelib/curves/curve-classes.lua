AddCSLuaFile()

---@enum CURVE_END_TYPE
CURVE_END_TYPE = {
    SMOOTH  = 1,
    SHARP   = 2
}

--[[--------------------------------------------------------------------]]--

---@class Curves.ControlPoint
---@field Pos Vector
---@field LeftHandlePos Vector?
---@field RightHandlePos Vector?
local CurvePointMetatable = {
    Pos             = Vector( 0, 0 ),
    LeftHandlePos   = nil,
    RightHandlePos  = nil
}
CurvePointMetatable.__index = CurvePointMetatable

--- Creates a new CurvePoint
---@return Curves.ControlPoint
function CurvePoint( pos, leftHandlePos, rightHandlePos )
    ---@type Curves.ControlPoint
    local instance = {
        Pos = pos,
        LeftHandlePos = leftHandlePos,
        RightHandlePos = rightHandlePos
    }
    setmetatable( instance, CurvePointMetatable )

    return instance
end

--[[--------------------------------------------------------------------]]--

---@class Curves.Curve
---@field Points table<Curves.ControlPoint>
local CurveMetatable = {
    Points = {}
}
CurveMetatable.__index = CurveMetatable

function CurveMetatable:__call( x )
    print( x )
end

--- Creates a new Curve
---@param curvePoints table<Curves.ControlPoint>?
---@return Curves.Curve
function Curve( curvePoints )
    ---@type Curves.Curve
    local instance = {
        Points = {}
    }

    if curvePoints then
        instance.Points = curvePoints
    else
        instance.Points = {
            CurvePoint( Vector( 0, 0 ), nil, Vector( 0.25, 0.25 ) ),
            CurvePoint( Vector( 1, 1 ), Vector( 0.75, 0.75 ), nil )
        }
    end

    setmetatable( instance, CurveMetatable )

    return instance
end

