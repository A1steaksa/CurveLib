require( "vguihotload" )

---@class CurveLib.Editor.Graph.Handle.Base : DPanel
---@field IsBeingDragged boolean? Whether or not the Handle is being dragged
---@field HalfWidth integer
---@field HalfHeight integer
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

    local draggableX, draggableY = self:LocalToScreen( 0, 0 )
    local mouseX, mouseY = gui.MouseX(), gui.MouseY()
    self.LocalMouseX = draggableX - mouseX
    self.LocalMouseY = draggableY - mouseY
end

function PANEL:OnMouseReleased( mouseButton )
    if mouseButton ~= MOUSE_LEFT then return end
    self:MouseCapture( false )
    self.IsBeingDragged = nil
end

vgui.Register( "CurveLib.Editor.Graph.Handle.Base", PANEL, "DPanel" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )