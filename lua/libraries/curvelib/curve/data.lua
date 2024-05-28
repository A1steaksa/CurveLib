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
    if not time then error( "Cannot evaluate curve at nil time" ) end
    time = math.Clamp( time, 0, 1 )
    
    local points = self.Points

    local pointWidth = 1 / ( #points - 1 )

    local curveSegmentIndex = 1 + math.floor( time / pointWidth )

    local curveSegmentStart = points[ curveSegmentIndex ]
    local curveSegmentEnd = points[ curveSegmentIndex + 1 ]

    -- Not the last index of the table
    if curveSegmentStart then
        -- If this is the end of the curve, return the last point
        if not curveSegmentEnd then
            return curveSegmentStart.MainHandle
        end

        return math.CubicBezier(
            time * ( #points - 1 ) - ( curveSegmentIndex - 1 ),
            curveSegmentStart.MainHandle,
            curveSegmentStart.RightHandle,
            curveSegmentEnd.LeftHandle,
            curveSegmentEnd.MainHandle
        )
    else
        error( "Invalid curve segment index" .. tostring( curveSegmentIndex ) )
    end
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