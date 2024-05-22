print( "Curve Point Loaded" )

---@class CurveLib.Curve.Point
---@field MainPoint Vector
---@field LeftHandle Vector?
---@field RightHandle Vector?
local metatable = {
    MainPoint   = Vector( 0, 0, 0 ),
    LeftHandle  = nil,
    RightHandle = nil
}
metatable.__index = metatable

function metatable:HasLeftHandle()
    return self.LeftHandle and isvector( self.LeftHandle )
end

function metatable:HasRightHandle()
    return self.RightHandle and isvector( self.RightHandle )
end

-- Creates a new Curve Point with an optional set of handles
---@param mainPointPos Vector The position of the main point. Must be in the range [0-1].
---@param leftHandlePos Vector? The position of the left handle. X coordinate be in the range [0-1].
---@param rightHandlePos Vector? The position of the right handle. X coordinate be in the range [0-1].
---@return CurveLib.Curve.Point
function CurvePoint( mainPointPos, leftHandlePos, rightHandlePos )
    local curvePoint = {}
    setmetatable( curvePoint, metatable )

    curvePoint.MainPoint = mainPointPos
    if leftHandlePos then curvePoint.LeftHandle = leftHandlePos end
    if rightHandlePos then curvePoint.RightHandle = rightHandlePos end

    return curvePoint
end