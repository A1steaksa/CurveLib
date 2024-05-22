require( "vguihotload" )

---@class CurveLib.Editor.Graph.Draggable.Base : DPanel
---@field Dragging boolean? Whether or not the Draggable is being dragged
local PANEL = {}

-- Like SetPos, but relative to the center of the Panel.
---@param x integer
---@param y integer
function PANEL:SetCenterPos( x, y )
    self:SetX( x - math.floor( self:GetWide() / 2 ) )
    self:SetY( y - math.floor( self:GetTall() / 2 ) )
end

-- Called when the Draggable is dragged.  Don't return anything to prevent the movement.
---@param x integer The Draggable's proposed new X coordinate
---@param y integer The Draggable's propoxed new Y coordinate
---@return integer? correctedX The actual X coordinate to use
---@return integer? correctedY The actual Y coordinate to use
function PANEL:OnDragged( x, y ) end

function PANEL:Think()
    if self.Dragging then
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
    self.Dragging = true

    local draggableX, draggableY = self:LocalToScreen( 0, 0 )
    local mouseX, mouseY = gui.MouseX(), gui.MouseY()
    self.LocalMouseX = draggableX - mouseX
    self.LocalMouseY = draggableY - mouseY
end

function PANEL:OnMouseReleased( mouseButton )
    if mouseButton ~= MOUSE_LEFT then return end
    self:MouseCapture( false )
    self.Dragging = nil
end

vgui.Register( "CurveLib.Editor.Graph.Draggable.Base", PANEL, "DPanel" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )