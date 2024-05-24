---@class CurveLib.Curve.Data
---@field Points table<CurveLib.Curve.Point>
local metatable = {}
metatable.IsCurve = true
metatable.__index = metatable

-- Evaluate the curve at a given time
-- This function is also aliased to the __call metamethod
-- so that you can call the curve like a function.
---@param time number The time value to evaluate the curve at. Must be between 0 and 1.
---@return number # The y value of the curve at the given time. May not be between 0 and 1.
function metatable:Evaluate( time )
    if not time or time <= 0 then return 0 end
    if time >= 1 then return 1 end
    
    local points = self.Points
    for index, curveSegmentStart in ipairs( points ) do
        local curveSegmentEnd = points[ index + 1 ]
        
        -- Not the last index of the table
        if curveSegmentEnd then
            -- If this is the right Curve Segment for the given time value
            if curveSegmentEnd.MainHandle.x < time then
                return math.CubicBezier(
                    -- Making time relative to this segment
                    time - curveSegmentStart.MainHandle.x,
                    curveSegmentStart.MainHandle,
                    curveSegmentStart.RightHandle,
                    curveSegmentEnd.MainHandle,
                    curveSegmentEnd.LeftHandle
                ).y
            end
        end
    end

    error( "Failed to evaluate Curve " .. self .. " at time " .. time )
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