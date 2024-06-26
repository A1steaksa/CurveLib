---@class CurveLib.Curve.Point
---@field MainPoint Vector
---@field LeftPoint Vector?
---@field RightPoint Vector?
local metatable = {
    MainPoint   = Vector( 0, 0, 0 ),
    LeftPoint  = nil,
    RightPoint = nil
}
metatable.__index = metatable

-- Creates a new Curve Point with an optional set of handles
---@param mainPointPos Vector The position of the main point. Must be in the range [0-1].
---@param leftPointPos Vector? The position of the left point. X coordinate be in the range [0-1].
---@param rightPointPos Vector? The position of the right point. X coordinate be in the range [0-1].
---@return CurveLib.Curve.Point
function CurvePoint( mainPointPos, leftPointPos, rightPointPos )
    local curvePoint = {}
    setmetatable( curvePoint, metatable )

    curvePoint.MainPoint = mainPointPos
    if leftPointPos then curvePoint.LeftPoint = leftPointPos end
    if rightPointPos then curvePoint.RightPoint = rightPointPos end

    return curvePoint
end