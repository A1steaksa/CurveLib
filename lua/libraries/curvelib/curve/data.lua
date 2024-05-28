---@class CurveLib.Curve.Data
---@field Points table<CurveLib.Curve.Point>
local metatable = {}
metatable.IsCurve = true
metatable.__index = metatable

-- Evaluate the curve at a given time
-- This function is also aliased to the __call metamethod
-- so that you can call the curve like a function.
---@param time number The time value to evaluate the curve at. Must be between 0 and 1.
---@return Vector # The position of the curve at the given time. May not be between 0 and 1.
function metatable:Evaluate( time )
    if not time then return 0 end
    time = math.Clamp( time, 0, 1 )
    
    local points = self.Points

    local pointWidth = 1 / #points

    local curveSegmentIndex = math.floor( time / pointWidth )

    local curveSegmentStart = points[ curveSegmentIndex ]
    local curveSegmentEnd = points[ curveSegmentIndex + 1 ]

    -- Not the last index of the table
    if curveSegmentStart and curveSegmentEnd then
        return math.CubicBezier(
            -- Making time relative to this segment
            time - curveSegmentStart.MainHandle.x,
            curveSegmentStart.MainHandle,
            curveSegmentStart.RightHandle,
            curveSegmentEnd.MainHandle,
            curveSegmentEnd.LeftHandle
        )
    end

    --error( "Failed to evaluate Curve at time " .. time )
    return Vector( 0, 0 )
end
metatable.__call = metatable.Evaluate

-- Creates a new Curve with an optional set of points
---@vararg CurveLib.Curve.Point? # The points to add to the curve.
function CurveData( ... )
    local curveData = { Points = {} }
    setmetatable( curveData, metatable )

    for i = 1, select( "#", ... ) do
        curveData.Points[ #curveData.Points + 1 ] = select( i, ... )
    end

    return curveData
end