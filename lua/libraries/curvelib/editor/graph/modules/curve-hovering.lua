require( "vguihotload" )

---@class CurveLib.Editor.Graph.Panel
PANEL = PANEL

if not PANEL then
    vguihotload.HandleMultipartPanelHotload( "CurveLib.Editor.Graph.Panel" )
    return
end

-- Returns whether the mouse is hovering over the active curve
---@return boolean isHovered Whether the mouse is hovering over the active curve
function PANEL:IsCurveHovered()
    if not self.CurrentCurve then return false end
    
    local mouseX, mouseY = self:CursorPos()
    local _, distance = self:GetClosestPointOnCurve( mouseX, mouseY )

    return distance <= self.Config.Curve.HoverSize
end

-- Finds where on the active curve curve is closest to a given point.  Results are cached each frame.
-- **Note:** This function will always return the closest point on the curve, even if it is not within the bounds of the curve.
---@param x integer The X coordinate, in panel-relative coordinates
---@param y integer The Y coordinate, in panel-relative coordinates
---@param checkCount? integer The number of points to check on the curve [Default: 400]
---@return number time The time value of the closest point on the curve
---@return number distance The distance between the point and the closest point on the curve
---@return integer x The X coordinate of the closest point on the curve, in panel-relative coordinates
---@return integer y The Y coordinate of the closest point on the curve, in panel-relative coordinates
function PANEL:GetClosestPointOnCurve( x, y, checkCount )
    local curve = self.CurrentCurve
    local lowestDistanceSquared = math.huge
    local closestTime = 0
    local closestX, closestY = 0, 0

    for i = 1, ( checkCount or 400 ) do
        local time = i / 400

        local point = curve:Evaluate( time, true )

        local pointX, pointY = self:NormalizedToInterior( point.x, point.y )

        local distanceSquared = math.pow( x - pointX, 2 ) + math.pow( y - pointY, 2 )

        if distanceSquared < lowestDistanceSquared then
            lowestDistanceSquared = distanceSquared
            closestTime = time
            closestX = pointX
            closestY = pointY
        end
    end

    return closestTime, math.sqrt( lowestDistanceSquared ), closestX, closestY
end


-- Returns the position of the mouse on the active curve
---@return number time The time value of the closest point on the curve
---@return number distance The distance between the point and the closest point on the curve
---@return integer x The X coordinate of the closest point on the curve, in panel-relative coordinates
---@return integer y The Y coordinate of the closest point on the curve, in panel-relative coordinates
function PANEL:GetCursorPosOnCurveAsTime()
    if not self.Config.Caches.MousePosOnCurve then
        local time, distance, x, y = self:GetClosestPointOnCurve( self:CursorPos() )
        self.Config.Caches.MousePosOnCurve = {
            Time = time,
            Distance = distance,
            X = x,
            Y = y
        }
    end

    local cache = self.Config.Caches.MousePosOnCurve
    return cache.Time, cache.Distance, cache.X, cache.Y
end