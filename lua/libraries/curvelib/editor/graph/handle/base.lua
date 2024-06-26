require( "vguihotload" )

---@class CurveLib.Editor.Graph.Handle.Base : DPanel
---@field x integer
---@field y integer
---@field GraphPanel CurveLib.Editor.Graph.Panel The Graph Panel this Handle is parented to.  Cached here for autocomplete convenience and access speed.
---@field IsBeingDragged boolean? Whether or not the Handle is being dragged
---@field HalfWidth integer
---@field HalfHeight integer
---@field HoverStartTime number
---@field HoverEndTime number
---@field CurrentRadius number The current radius of the Handle, as a float pixel value which will be made into an integer for rendering.
---@field CurrentColor Color The current color of the Handle
---@field IsMainHandle boolean? Whether or not this Handle is the main Handle
---@field IsSideHandle boolean? Whether or not this Handle is a side Handle
local PANEL = {}

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

-- Called when the Handle is dragged.  Don't return anything to prevent the movement.
---@param x integer The Handle's proposed new X coordinate
---@param y integer The Handle's propoxed new Y coordinate
---@return integer? correctedX The actual X coordinate to use
---@return integer? correctedY The actual Y coordinate to use
function PANEL:OnDragged( x, y ) end

function PANEL:Think()
    if self.IsBeingDragged then
        local screenX, screenY = self:GetParent() --[[@as CurveLib.Editor.Graph.Panel]]:LocalToScreen( 0, 0 )

        local mouseX = gui.MouseX() - screenX + self.LocalMouseX
        local mouseY = gui.MouseY() - screenY + self.LocalMouseY

        local correctedX, correctedY = self:OnDragged(mouseX, mouseY )

        if correctedX and correctedY then
            self:SetPos( correctedX, correctedY )
        end
    end
end

function PANEL:OnMousePressed( mouseButton )
    if mouseButton ~= MOUSE_LEFT then return end
    self:MouseCapture( true )
    self.IsBeingDragged = true

    self.GraphPanel:OnDragStarted( self )

    local draggableX, draggableY = self:LocalToScreen( 0, 0 )
    local mouseX, mouseY = gui.MouseX(), gui.MouseY()
    self.LocalMouseX = draggableX - mouseX
    self.LocalMouseY = draggableY - mouseY
end

function PANEL:OnMouseReleased( mouseButton )
    if mouseButton ~= MOUSE_LEFT then return end
    self:MouseCapture( false )

    if self.IsBeingDragged then
        self.IsBeingDragged = nil
        self.GraphPanel:OnDragEnded( self )
    end
end

function PANEL:OnCursorEntered()
    self.HoverStartTime = CurTime()
end

function PANEL:OnCursorExited()
    self.HoverEndTime = CurTime()
end

-- Returns the duration the cursor has been hovering over the Handle.
---@return number Duration The duration, in seconds
function PANEL:GetHoverDuration()
    if not self.HoverStartTime then return 0 end
    return self.HoverEndTime and self.HoverEndTime - self.HoverStartTime or CurTime() - self.HoverStartTime
end

-- Returns the current state of the Handle
---@param handleConfig CurveLib.Editor.Config.Graph.Handles.Handle The Handle's configuration
function PANEL:GetState( handleConfig )
    if self.IsBeingDragged then
        return handleConfig.Dragged
    elseif self:IsHovered() then
        return handleConfig.Hovered
    else
        return handleConfig.Idle
    end
end

-- Updates the current visuals of the Handle based on its current state
---@param handleConfig CurveLib.Editor.Config.Graph.Handles.Handle The Handle's configuration
function PANEL:UpdateVisuals( handleConfig )
    local goalState = self:GetState( handleConfig )

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