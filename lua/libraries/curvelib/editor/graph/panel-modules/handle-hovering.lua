require( "vguihotload" )

---@class CurveLib.Editor.Graph.Panel
---@field HoveredHandle BaseHandle? The Handle currently being hovered over
local PANEL = IN_PROGRESS_GRAPH_PANEL
if not PANEL then error( "Failed to load HandleHovering module of CurveLib.Editor.Graph.Panel" ) return end

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