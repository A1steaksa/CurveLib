print( "Curve Data Loaded" )

---@class Curve.CurveData : table
---@field Points table<Curve.CurvePoint>
local metatable = {
    Points = {}
}
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
            if curveSegmentEnd.MainPoint.x < time then
                return math.CubicBezier(
                    -- Making time relative to this segment
                    time - curveSegmentStart.MainPoint.x,
                    curveSegmentStart.MainPoint,
                    curveSegmentStart.RightHandle,
                    curveSegmentEnd.MainPoint,
                    curveSegmentEnd.LeftHandle
                ).y
            end
        end
    end

    error( "Failed to evaluate Curve " .. self .. " at time " .. time )
end
metatable.__call = metatable.Evaluate

function CurveData()
    local curveData = {}
    setmetatable( curveData, metatable )
    return curveData
end