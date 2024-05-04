---@class Curves.CurveData
---@field Points table<Curves.ControlPointData>
local CurveDataMetatable = {
    Points = {}
}
CurveDataMetatable.__index = CurveDataMetatable

function CurveDataMetatable:__call( x )
    print( x )
end

--- Creates a new Curve
---@param curvePoints table<Curves.ControlPointData>? The Control Points that make up the curve.  The first Control Point must be at X = 0 and the last Control Point must be at x = 100.  They will be set to these positions if they are not.
---@return Curves.CurveData
function Curve( curvePoints )
    ---@type Curves.CurveData
    local instance = {
        Points = {}
    }

    if curvePoints then
        if not #curvePoints >= 2 then
            error( "Curves require at least 2 Control Points" )
        end

        instance.Points = curvePoints

        -- Ensure the graph is fully covered
        instance.Points[1].ControlPointPos.x = 0
        instance.Points[#instance.Points].ControlPointPos.x = 100
    else
        instance.Points = {
            ControlPointData( Vector( 0, 0 ), nil, Vector( 25, 25 ) ),
            ControlPointData( Vector( 100, 100 ), Vector( 75, 75 ), nil )
        }
    end

    setmetatable( instance, CurveDataMetatable )

    return instance
end
