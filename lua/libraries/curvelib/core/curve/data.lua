if not _G.CurveLib then error("Cannot initialize Curve Data - CurveLib not found") return end

---@class CurveLib.Curve.Data
---@field Points CurveLib.Curve.Point[]
---@field IsCurve boolean
---@field lastInput number
---@field lastOutput Vector
local metatable = {}
metatable.IsCurve = true
metatable.__index = metatable

local lerpVector = LerpVector
local math_CubicBezier = math.CubicBezier
local table_insert = table.insert
local math_Clamp = math.Clamp
local math_floor = math.floor

-- Adds a point to the curve
---@param time number The time value of the point. Must be between 0 and 1.
function metatable:AddPoint( time )
    if not time then
        error( "Cannot add point with nil time" )
    end

    time = math_Clamp( time, 0, 1 )

    local points = self.Points

    -- Find the index where the new point should be inserted
    local pointWidth = 1 / ( #points - 1 )
    local pointIndex = 1 + math_floor( time / pointWidth ) + 1

    local previousPoint = points[ pointIndex - 1 ]
    local nextPoint = points[ pointIndex ]

    -- Get the time as a percentage of the segment between the previous and next points
    local previousPointTime = ( pointIndex - 2 ) * pointWidth
    local timeBetweenPoints = time - previousPointTime
    local timePercent = timeBetweenPoints / pointWidth

    -- Adjust the previous and next points' control points to accomodate the new point
    -- Credit to Gabi (@enxaneta) on Codepen for this method of calculating control points
    -- https://codepen.io/enxaneta/post/how-to-add-a-point-to-an-svg-path

    local newPointPos = self:Evaluate( time, true )

    -- The neighboring points' side point lengths get halved
    local previousPointRightPos = lerpVector( timePercent, previousPoint.MainPoint, previousPoint.RightPoint )
    local nextPointLeftPos = lerpVector( 1 - timePercent, nextPoint.MainPoint, nextPoint.LeftPoint )

    -- The new point's side points are halfway between the neighbor side points' new positions and the middle of their previous positions
    local neighborSidePointCenter = lerpVector( timePercent, previousPoint.RightPoint, nextPoint.LeftPoint )
    local newPointLeftPos = lerpVector( timePercent, previousPointRightPos, neighborSidePointCenter )
    local newPointRightPos = lerpVector( timePercent, neighborSidePointCenter, nextPointLeftPos )

    -- Insert the new point into the curve
    table_insert( points, pointIndex, {
        MainPoint = newPointPos,
        LeftPoint = newPointLeftPos,
        RightPoint = newPointRightPos
    } )

    -- Update the neighboring points' control points
    previousPoint.RightPoint = previousPointRightPos
    nextPoint.LeftPoint = nextPointLeftPos
end

-- Evaluate the curve at a given time
-- This function is also aliased to the __call metamethod
-- so that you can call the curve like a function.
---@param time number The time value to evaluate the curve at. Must be between 0 and 1.
---@param shouldSuppressHistory? boolean Whether or not to suppress this evaluation from being stored as the curve's last input/output.
---@return Vector # The position of the curve at the given time. May not be between 0 and 1.
function metatable:Evaluate( time, shouldSuppressHistory )
    if not time then
        error( "Cannot evaluate curve at nil time" )
    end
    time = math_Clamp( time, 0, 1 )

    local points = self.Points

    local pointWidth = 1 / ( #points - 1 )

    local curveSegmentIndex = 1 + math_floor( time / pointWidth )

    local curveSegmentStart = points[ curveSegmentIndex ]
    local curveSegmentEnd = points[ curveSegmentIndex + 1 ]

    if curveSegmentStart then
        -- If this is the end of the curve, return the last point
        if not curveSegmentEnd then
            if not shouldSuppressHistory then
                self.lastInput = time
                self.lastOutput = curveSegmentStart.MainPoint
            end
            return curveSegmentStart.MainPoint
        end

        local result = math_CubicBezier(
            time * ( #points - 1 ) - ( curveSegmentIndex - 1 ),
            curveSegmentStart.MainPoint,
            curveSegmentStart.RightPoint,
            curveSegmentEnd.LeftPoint,
            curveSegmentEnd.MainPoint
        )

        if not shouldSuppressHistory then
            self.lastInput = time
            self.lastOutput = result
        end

        return result
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