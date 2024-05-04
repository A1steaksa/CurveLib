-- The class for Curve Point Handles that control a Curve Segment.
---@class (exact) CurveEditor.EditorControlHandle : CurveEditor.CurveDraggableBase
---@field EditorControlPoint CurveEditor.EditorControlPoint The Editor Control Point that this Handle belongs to.
local PANEL = {}

function PANEL:Init()
    self:SetRadius( 10 )
    self:SetVertexDistance( 1 )
    self:SetIdleColor(    Color( 75,  200, 200, 255 ) )
    self:SetHoveredColor( Color( 100, 100, 250, 255 ) )
    self:SetPressedColor( Color( 255, 255, 255, 255 ) )
    self:SetDraggedColor( Color( 100, 100, 100, 100 ) )
end

-- Sets the Curve Point that this Handle belongs to.
---@param curvePoint CurveEditor.EditorControlPoint
function PANEL:SetEditorControlPoint( curvePoint )
    self.EditorControlPoint = curvePoint
end

function PANEL:OnDragged()
    local parent = self:GetParent() --[[@as CurveEditor]]
    parent:UpdateDraggableData( self.EditorControlPoint )
end

vgui.Register( "CurveEditor.EditorControlHandle", PANEL, "CurveEditor.CurveDraggableBase" )

vguihotload.HandleHotload( "CurveEditor" )