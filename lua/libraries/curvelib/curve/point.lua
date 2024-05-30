---@class CurveLib.Curve.Point
---@field MainHandle Vector
---@field LeftHandle Vector?
---@field RightHandle Vector?
local metatable = {
    MainHandle   = Vector( 0, 0, 0 ),
    LeftHandle  = nil,
    RightHandle = nil
}
metatable.__index = metatable

-- Creates a new Curve Point with an optional set of handles
---@param mainHandlePos Vector The position of the main handle. Must be in the range [0-1].
---@param leftHandlePos Vector? The position of the left handle. X coordinate be in the range [0-1].
---@param rightHandlePos Vector? The position of the right handle. X coordinate be in the range [0-1].
---@return CurveLib.Curve.Point
function CurvePoint( mainHandlePos, leftHandlePos, rightHandlePos )
    local curvePoint = {}
    setmetatable( curvePoint, metatable )

    curvePoint.MainHandle = mainHandlePos
    if leftHandlePos then curvePoint.LeftHandle = leftHandlePos end
    if rightHandlePos then curvePoint.RightHandle = rightHandlePos end

    return curvePoint
end