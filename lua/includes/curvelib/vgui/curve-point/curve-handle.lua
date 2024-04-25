-- The class for Curve Point Handles that control a Curve Segment.
---@class (exact) CurveEditor.CurveHandle : CurveEditor.CurveDraggableBase
---@field Point CurveEditor.CurveControlPoint The Curve Point that this Handle belongs to.
local PANEL = {}

-- Sets the Curve Point that this Handle belongs to.
---@param curvePoint CurveEditor.CurveControlPoint
function PANEL:SetPoint( curvePoint )
    self.Point = curvePoint
end

---@return CurveEditor.CurveControlPoint Point The Curve Point that this Handle belongs to.
function PANEL:GetPoint()
    return self.Point
end

function PANEL:Init()

end

vgui.Register( "CurveEditor.CurveHandle", PANEL, "CurveEditor.CurveDraggableBase" )

vguihotload.HandleHotload( "CurveEditor" )