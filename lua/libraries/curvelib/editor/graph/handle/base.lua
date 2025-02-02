require( "vguihotload" )

---@alias BaseHandle CurveLib.Editor.Graph.Handle.Base

---@class CurveLib.Editor.Graph.Handle.Base : DPanel
---@field x integer
---@field y integer
---@field GraphPanel GraphPanel The Graph Panel this Handle is parented to.  Cached here for autocomplete convenience and access speed.
---@field IsBeingDragged boolean? Whether or not the Handle is being dragged
---@field LocalDragX integer? The X coordinate of the mouse relative to the Handle when the drag started
---@field LocalDragY integer? The Y coordinate of the mouse relative to the Handle when the drag started
---@field IsLeftMouseDown boolean? Whether or not the left mouse button is currently held down over this Handle 
---@field IsRightMouseDown boolean? Whether or not the right mouse button is currently down over this Handle
---@field LeftMouseDownX integer? The X coordinate of the mouse when the left mouse button was pressed
---@field LeftMouseDownY integer? The Y coordinate of the mouse when the left mouse button was pressed
---@field RightMouseDownX integer? The X coordinate of the mouse when the right mouse button was pressed
---@field RightMouseDownY integer? The Y coordinate of the mouse when the right mouse button was pressed
---@field HalfWidth integer
---@field HalfHeight integer
---@field HoverStartTime number
---@field HoverEndTime number
---@field CurrentRadius number The current radius of the Handle, as a float pixel value which will be made into an integer for rendering.
---@field CurrentColor Color The current color of the Handle
---@field IsMainHandle boolean? Whether or not this Handle is the main Handle
---@field IsSideHandle boolean? Whether or not this Handle is a side Handle
---@field MainHandle MainHandle
---@field LeftHandle SideHandle?
---@field RightHandle SideHandle?
local PANEL = {}

function PANEL:Init()
    self.GraphPanel = self:GetParent() --[[@as GraphPanel]]
    self:SetSelectable( true )
    self:SetPaintedManually( true )
end

---@param handleConfig HandleConfig The Handle's configuration
function PANEL:SetConfig( handleConfig )
    self.Config = handleConfig
end

---@return HandleConfig # The Handle's configuration
function PANEL:GetConfig()
    return self.Config
end

function PANEL:OnSizeChanged( width, height )
    self.HalfWidth = math.floor( width / 2 )
    self.HalfHeight = math.floor( height / 2 )
end

-- Like SetPos, but relative to the center of the Panel.
---@param x integer
---@param y integer
function PANEL:SetCenterPos( x, y )
    self:SetX( x - self.HalfWidth )
    self:SetY( y - self.HalfHeight )
end

-- Like GetPos, but returns the center of the Panel.
---@return integer x
---@return integer y
function PANEL:GetCenterPos()
    return self.x + self.HalfWidth, self.y + self.HalfHeight
end

-- Called when the Handle is dragged.  Modify the x and y parameters to constrain the dragged location.
-- Don't return to prevent dragging movement entirely.
---@param x integer The Handle's proposed new X coordinate
---@param y integer The Handle's propoxed new Y coordinate
---@return integer? correctedX The actual X coordinate to use
---@return integer? correctedY The actual Y coordinate to use
function PANEL:OnDragged( x, y )
    if self.IsMainHandle then
        return self.GraphPanel:OnMainHandleDragged( self --[[@as MainHandle]], x, y )
    else
        return self.GraphPanel:OnSideHandleDragged( self --[[@as SideHandle]], x, y )
    end
end

function PANEL:Think()
    if self.IsLeftMouseDown and not self.IsBeingDragged then
        local cursorMoveX = ( self.LeftMouseDownX - gui.MouseX() ) ^ 2
        local cursorMoveY = ( self.LeftMouseDownY - gui.MouseY() ) ^ 2
        local cursorMoveDistance = math.sqrt( cursorMoveX + cursorMoveY )

        if ( cursorMoveDistance >= self.GraphPanel.Config:GetDragDistanceThreshold() ) then
            self.IsBeingDragged = true

            -- Calculate where the cursor was on the handle when the drag started
            self.LocalDragX, self.LocalDragY = self:ScreenToLocal( self.LeftMouseDownX, self.LeftMouseDownY )

            self.GraphPanel:OnHandleDragStarted( self )
        end
    end

    if self.IsBeingDragged then
        local graphCursorX, graphCursorY = self:GetParent():ScreenToLocal( gui.MouseX(), gui.MouseY() )
        local proposedX, proposedY = graphCursorX - self.LocalDragX, graphCursorY - self.LocalDragY

        local correctedX, correctedY = self:OnDragged( proposedX, proposedY )

        if correctedX or correctedY then
            self:SetPos( correctedX or proposedX, correctedY or proposedY )
        end
    end
end

function PANEL:OnMousePressed( mouseButton )
    self:MouseCapture( true )

    if mouseButton == MOUSE_LEFT then
        self.IsLeftMouseDown = true
        self.LeftMouseDownX = gui.MouseX()
        self.LeftMouseDownY =  gui.MouseY()
    elseif mouseButton == MOUSE_RIGHT then
        self.IsRightMouseDown = true
        self.RightMouseDownX = gui.MouseX()
        self.RightMouseDownY = gui.MouseY()
    end
end

function PANEL:OnMouseReleased( mouseButton )
    self:MouseCapture( false )

    if mouseButton == MOUSE_LEFT then
        self.IsLeftMouseDown = nil
        self.LeftMouseDownX = nil
        self.LeftMouseDownY = nil
    elseif mouseButton == MOUSE_RIGHT then
        self.IsRightMouseDown = nil
        self.RightMouseDownX = nil
        self.RightMouseDownY = nil
    end

    if self.IsBeingDragged then
        self.IsBeingDragged = nil
        self.GraphPanel:OnHandleDragEnded( self )
    else
        if mouseButton == MOUSE_LEFT then
            self.GraphPanel:SelectHandle( self )
        end
    end
end

function PANEL:OnCursorEntered()
    self.GraphPanel:OnHandleHoverStarted( self )

    self.HoverStartTime = CurTime()
end

function PANEL:OnCursorExited()
    self.GraphPanel:OnHandleHoverEnded( self )

    self.HoverEndTime = CurTime()
end

-- Returns the duration the cursor has been hovering over the Handle.
---@return number Duration The duration, in seconds
function PANEL:GetHoverDuration()
    if not self.HoverStartTime then return 0 end
    return self.HoverEndTime and self.HoverEndTime - self.HoverStartTime or CurTime() - self.HoverStartTime
end

-- Returns the current state of the Handle
function PANEL:GetState()
    if self.IsBeingDragged then
        return self.Config.Dragged
    elseif self:IsHovered() then
        return self.Config.Hovered
    else
        return self.Config.Idle
    end
end

-- Updates the current visuals of the Handle based on its current state
function PANEL:UpdateVisuals()
    local goalState = self:GetState()

    if not self.CurrentRadius or not self.CurrentColor then
        local goalColor = goalState.Color
        self.CurrentColor = Color( goalColor.r, goalColor.g, goalColor.b, goalColor.a )
        self.CurrentRadius = goalState.Radius
    end

    local goalColor = goalState.Color
    self.CurrentColor.r = math.Approach( self.CurrentColor.r, goalColor.r, FrameTime() * goalState.ColorChangeRate )
    self.CurrentColor.g = math.Approach( self.CurrentColor.g, goalColor.g, FrameTime() * goalState.ColorChangeRate )
    self.CurrentColor.b = math.Approach( self.CurrentColor.b, goalColor.b, FrameTime() * goalState.ColorChangeRate )
    self.CurrentColor.a = math.Approach( self.CurrentColor.a, goalColor.a, FrameTime() * goalState.ColorChangeRate )

    self.CurrentRadius = math.Approach( self.CurrentRadius, goalState.Radius, FrameTime() * goalState.RadiusChangeRate )
end

vgui.Register( "CurveLib.Editor.Graph.Handle.Base", PANEL, "DPanel" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )