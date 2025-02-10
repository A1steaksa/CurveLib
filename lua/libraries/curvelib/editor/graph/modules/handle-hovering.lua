require( "vguihotload" )

---@class CurveLib.Editor.Graph.Panel
---@field HoveredHandle BaseHandle? The Handle currently being hovered over
PANEL = PANEL

if not PANEL then
    vguihotload.HandleMultipartPanelHotload( "CurveLib.Editor.Graph.Panel" )
    return
end

-- Called externally when a Handle is hovered
---@param handle BaseHandle
function PANEL:OnHandleHoverStarted( handle )
    self.HoveredHandle = handle
end

-- Called externally when a Handle no longer hovered
---@param handle BaseHandle
function PANEL:OnHandleHoverEnded( handle )
    self.HoveredHandle = nil
end