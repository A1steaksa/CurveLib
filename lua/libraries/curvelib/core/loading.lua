if not _G.CurveLib then error("Cannot initialize Curve Loading - CurveLib not found") return end

---@class CurveLib
local CurveLib = _G.CurveLib

-- Saves a Curve to a file
---@param path string The path to save the curve to
---@param curve CurveLib.Curve.Data The curve to save
function CurveLib.SaveCurve( path, curve )
    if not path then
        error( "Cannot save curve with nil path" )
    end

    if not curve then
        error( "Cannot save a nil curve" )
    end

    if not curve.Points then
        error( "Cannot save curve without points" )
    end

    local data = util.TableToJSON( curve.Points, true )

    file.Write( path, data )
end

-- Loads a Curve from a file
---@param path string The path to the curve file
---@return CurveLib.Curve.Data
function CurveLib.LoadCurve( path )
    if not path then
        error( "Cannot load curve with nil path" )
    end

    local data = file.Read( path, "GAME" )
    if not data then
        error( "Could not load curve from path " .. path )
    end

    local rawCurvePoints = util.JSONToTable( data )
    if not rawCurvePoints then
        error( "Curve data missing from file " .. path )
    end

    local curvePoints = {}
    for _, pointData in ipairs( rawCurvePoints ) do
        local point = CurvePoint( pointData.MainPoint, pointData.LeftPoint, pointData.RightPoint )
        curvePoints[#curvePoints + 1] = point
    end

    return CurveData( unpack( curvePoints ) )
end

