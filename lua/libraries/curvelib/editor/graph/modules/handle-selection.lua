require( "vguihotload" )
if not PANEL then vguihotload.HandleMultipartPanelHotload( "CurveLib.Editor.Graph.Panel" ) return end

---@class CurveLib.Editor.Graph.Panel
---@field SelectedHandles table<MainHandle, boolean> The currently selected Main Handles
---@field IsBoxSelecting boolean Whether the user is currently performing a box selection
---@field BoxSelectionEndX integer The adjusted X coordinate of the bottom-right corner of the box selection
---@field BoxSelectionEndY integer The adjusted Y coordinate of the bottom-right corner of the box selection
PANEL = PANEL

PANEL.SelectedHandles = {}
PANEL.IsBoxSelecting = false

-- Selects a Main Handle
---@param handle BaseHandle
---@param addToSelection boolean? Whether to add the Handle to the current selection, rather than deselecting all other Handles [Default: false]
function PANEL:SelectHandle( handle, addToSelection )
    if not handle.IsMainHandle then return end

    if not addToSelection then
        self:DeselectAllHandles()
    end

    handle:SetSelected( true )
    self.SelectedHandles[ handle ] = true

    if handle.LeftHandle then
        handle.LeftHandle:SetEnabled( true )
    end

    if handle.RightHandle then
        handle.RightHandle:SetEnabled( true )
    end
end

-- Called when a Main Handle is deselected
---@param handle BaseHandle
function PANEL:DeselectHandle( handle )
    if not handle.IsMainHandle then return end

    self.SelectedHandles[ handle ] = nil
    handle:SetSelected( false )

    if handle.LeftHandle then
        handle.LeftHandle:SetEnabled( false )
    end

    if handle.RightHandle then
        handle.RightHandle:SetEnabled( false )
    end
end

---@return boolean # True if the point is within the bounds of the rectangle, false otherwise
local function IsPointInRect( pointX, pointY, rectStartX, rectStartY, rectWidth, rectHeight )
    return pointX >= rectStartX and pointX <= rectStartX + rectWidth and pointY >= rectStartY and pointY <= rectStartY + rectHeight
end

---@param x number The X coordinate of the top-left corner of the rectangle
---@param y number The Y coordinate of the top-left corner of the rectangle
---@param width number The width of the rectangle
---@param height number The height of the rectangle
---@return table # A table of all Main Handles within the rectangle
function PANEL:GetMainHandlesInRect( x, y, width, height )

    if width < 0 then
        x = x + width
        width = -width
    end

    if height < 0 then
        y = y + height
        height = -height
    end

    local handles = {}

    for _, mainHandle in ipairs( self.MainHandles ) do
        local mainHandleX, mainHandleY = mainHandle:GetCenterPos()
        if IsPointInRect( mainHandleX, mainHandleY, x, y, width, height ) then
            handles[#handles+1] = mainHandle
        end
    end

    return handles
end

function PANEL:StartBoxSelection()
    self.IsBoxSelecting = true
    self:MouseCapture( true ) -- Capture the mouse so that the box selection can continue even if the cursor leaves the panel
end

-- Called each frame while box selection is active
function PANEL:BoxSelectionThink()
    if self.IsBoxSelecting then return end
    if not self:IsMouseDown( MOUSE_LEFT ) then return end

    local mouseX, mouseY = self:CursorPos()
    local distanceFromMouseDown = math.sqrt( math.pow( mouseX - self.LeftMouseDownX, 2 ) + math.pow( mouseY - self.LeftMouseDownY, 2 ) )

    if distanceFromMouseDown < self.Config:GetDragDistanceThreshold() then return end

    self:StartBoxSelection()
end

---@param isCanceled boolean? True if the box selection was canceled prematurely rather than ending naturally. [Default: false] 
function PANEL:EndBoxSelection( isCanceled )
    self.IsBoxSelecting = false
    self:MouseCapture( false )

    if isCanceled then
        self.LeftMouseDownX = nil
        self.LeftMouseDownY = nil
        return
    end

    local handlesInBox = self:GetMainHandlesInRect( self.LeftMouseDownX, self.LeftMouseDownY, self.BoxSelectionEndX - self.LeftMouseDownX, self.BoxSelectionEndY - self.LeftMouseDownY )

    -- Don't do anything if they didn't select any Handles
    if #handlesInBox == 0 then return end

    local ctrl, shift, alt = self:GetModifierKeys()
    if not shift then
        self:DeselectAllHandles()
    end

    for _, handle in ipairs( handlesInBox ) do
        self:SelectHandle( handle, true )
    end
end