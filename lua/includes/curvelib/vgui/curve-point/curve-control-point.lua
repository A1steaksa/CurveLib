--- The class for Curve Points that control the beginning and end positions of Curve Segments
---@class (exact) CurveEditor.CurveControlPoint : CurveEditor.CurveDraggableBase
---@field LeftHandle CurveEditor.CurveHandle?
---@field RightHandle CurveEditor.CurveHandle?
local PANEL = {}

function PANEL:Init()
    self.LeftHandle = vgui.Create( "CurveEditor.CurveHandle", self )
    self.LeftHandle:SetPoint( self )
    self.RightHandle = vgui.Create( "CurveEditor.CurveHandle", self )
    self.RightHandle:SetPoint( self )
end

vgui.Register( "CurveEditor.CurveControlPoint", PANEL, "CurveEditor.CurveDraggableBase" )

vguihotload.HandleHotload( "CurveEditor" )