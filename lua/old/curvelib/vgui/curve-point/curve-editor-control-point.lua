-- The Curve Editor's VGUI class for Control Points
---@class (exact) CurveEditor.EditorControlPoint : CurveEditor.CurveDraggableBase
---@field ControlPointData Curves.ControlPointData
---@field LeftHandle CurveEditor.EditorControlHandle?
---@field RightHandle CurveEditor.EditorControlHandle?
local PANEL = {}

function PANEL:Init()
    self:SetRadius( 10 )
    self:SetVertexDistance( 1 )
    self:SetIdleColor(    Color( 75,  75,  200, 255 ) )
    self:SetHoveredColor( Color( 100, 100, 250, 255 ) )
    self:SetPressedColor( Color( 255, 255, 255, 255 ) )
    self:SetDraggedColor( Color( 100, 100, 100, 100 ) )
end

-- Sets the Control Point Data that this panel represents and controls.
---@param controlPointData Curves.ControlPointData
function PANEL:SetControlPointData( controlPointData )
    self.ControlPointData = controlPointData
end

function PANEL:OnDragged()
    local parent = self:GetParent() --[[@as CurveEditor]]
    parent:UpdateDraggableData( self )
end

vgui.Register( "CurveEditor.EditorControlPoint", PANEL, "CurveEditor.CurveDraggableBase" )

vguihotload.HandleHotload( "CurveEditor" )