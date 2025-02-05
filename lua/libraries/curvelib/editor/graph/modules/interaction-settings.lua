require( "vguihotload" )

---@class CurveLib.Editor.Graph.Panel
---@field _IsRotationMirrored boolean Whether Side Handles should mirror each other's angle around the Main Handle when one is moved
---@field _IsDistanceMirrored boolean Whether Side Handles should mirror each other's distance from the Main Handle when one is moved
PANEL = PANEL

if not PANEL then error( "Failed to load InteractionSettings module of CurveLib.Editor.Graph.Panel" ) return end

PANEL._IsRotationMirrored = false
PANEL._IsDistanceMirrored = false

---@param value boolean Whether Side Handles should mirror each other's angle around the Main Handle when one is moved
function PANEL:SetMirrorHandleRotation( value )
    self._IsRotationMirrored = value

    self:GetSidebar().MirrorRotationCheckbox:SetChecked( value )
end

---@param value boolean Whether Side Handles should mirror each other's distance from the Main Handle when one is moved
function PANEL:SetMirrorHandleDistance( value )
    self._IsDistanceMirrored = value

    self:GetSidebar().MirrorDistanceCheckbox:SetChecked( value )
end

---@return boolean # Whether Side Handles should mirror each other's angle around the Main Handle when one is moved
function PANEL:IsHandleRotationMirrored()
    return self._IsRotationMirrored
end

---@return boolean # Whether Side Handles should mirror each other's distance from the Main Handle when one is moved
function PANEL:IsHandleDistanceMirrored()
    return self._IsDistanceMirrored
end
