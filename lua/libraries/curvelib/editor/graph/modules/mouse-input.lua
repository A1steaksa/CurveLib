require( "vguihotload" )

---@class CurveLib.Editor.Graph.Panel
---@field HeldMouseButtons table<MOUSE|integer, boolean> The mouse buttons currently being held down
---@field LeftMouseDownX integer? The X coordinate of the cursor when the left mouse button was pressed
---@field LeftMouseDownY integer? The Y coordinate of the cursor when the left mouse button was pressed
---@field RightMouseDownX integer? The X coordinate of the cursor when the right mouse button was pressed
---@field RightMouseDownY integer? The Y coordinate of the cursor when the right mouse button was pressed
PANEL = PANEL

if not PANEL then error( "Failed to load MouseInput module of CurveLib.Editor.Graph.Panel" ) return end

PANEL.HeldMouseButtons = {}

---@param mouseButton MOUSE|integer
---@return boolean # `true` if the mouse button is currently held down, `false` otherwise
function PANEL:IsMouseDown( mouseButton )
    return ( self.HeldMouseButtons[ mouseButton ] and self.LeftMouseDownX ~= nil and self.LeftMouseDownY ~= nil )
end

-- Called when the graph is clicked
---@param mouseButton MOUSE
function PANEL:OnMousePressed( mouseButton )
    if mouseButton == MOUSE_LEFT then
        self.LeftMouseDownX, self.LeftMouseDownY = self:CursorPos()
    elseif mouseButton == MOUSE_RIGHT then
        self.RightMouseDownX, self.RightMouseDownY = self:CursorPos()
    end

    self.HeldMouseButtons[ mouseButton ] = true
end

-- Called when the mouse is released
---@param mouseButton MOUSE
function PANEL:OnMouseReleased( mouseButton )
    local isLeftMouseDown = self:IsMouseDown( MOUSE_LEFT )
    if isLeftMouseDown then
        local leftMouseUpX, leftMouseUpY = self:CursorPos()
        local dragDistance = math.sqrt( math.pow( leftMouseUpX - self.LeftMouseDownX, 2 ) + math.pow( leftMouseUpY - self.LeftMouseDownY, 2 ) )
        local wasClick = dragDistance < self.Config:GetDragDistanceThreshold()

        if wasClick then
            -- Add a new point to the curve
            if self:IsCurveHovered() then
                local time = self:GetCursorPosOnCurveAsTime()
                local pointIndex = self.CurrentCurve:AddPoint( time )

                self:UpdateHandles()

                local ctrl, shift, alt = self:GetModifierKeys()

                self:SelectHandle( self.MainHandles[ pointIndex ], shift )
            else
                -- Clicking on the background deselects all Handles
                self:DeselectAllHandles()
            end
        end

        if self.IsBoxSelecting then
            self:EndBoxSelection()
        end
    end

    self.HeldMouseButtons[ mouseButton ] = nil
    if mouseButton == MOUSE_LEFT then
        self.LeftMouseDownX = nil
        self.LeftMouseDownY = nil
    elseif mouseButton == MOUSE_RIGHT then
        self.RightMouseDownX = nil
        self.RightMouseDownY = nil
    end
end