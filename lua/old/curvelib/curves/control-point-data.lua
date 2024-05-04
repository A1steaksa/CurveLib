AddCSLuaFile()

---@class Curves.ControlPointData
---@field ControlPointPos Vector
---@field LeftHandlePos Vector?
---@field RightHandlePos Vector?
local CurvePointDataMetatable = {
    ControlPointPos = Vector( 0, 0 ),
    LeftHandlePos   = nil,
    RightHandlePos  = nil
}
CurvePointDataMetatable.__index = CurvePointDataMetatable

--- Creates a new CurvePoint
---@param controlPointPos Vector The position of the Control Point, as a percentage in the range [0-100] 
---@param leftHandlePos Vector? The position of the Left Handle, as a percentage in the range [0-100]
---@param rightHandlePos Vector? The position of the Right Handle, as a percentage in the range [0-100]
---@return Curves.ControlPointData
function ControlPointData( controlPointPos, leftHandlePos, rightHandlePos )
    -- Ensure control points don't go off the X axis, as that's the one that we rely on to be correct.
    controlPointPos.x = math.Clamp( controlPointPos.x, 0, 100 )

    ---@type Curves.ControlPointData
    local instance = {
        ControlPointPos = controlPointPos,
        LeftHandlePos = leftHandlePos,
        RightHandlePos = rightHandlePos
    }
    setmetatable( instance, CurvePointDataMetatable )

    return instance
end