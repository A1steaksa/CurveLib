AddCSLuaFile()
if SERVER then return end

require( "vguihotload" )
include( "includes/curvelib/curve-drawing.lua" )

include( "includes/curvelib/vgui/curve-point/curve-draggable-base.lua" )
include( "includes/curvelib/vgui/curve-point/curve-handle.lua" )
include( "includes/curvelib/vgui/curve-point/curve-control-point.lua" )

---@class (exact) CurveEditor: DPanel
---@field Settings CurveEditorSettings
---@field Curve Curves.Curve
---@field CurvePoints table<CurveEditor.CurveControlPoint>
local PANEL = {}

-- Sets the Curve that this Editor will display.
---@param curve Curves.Curve
function PANEL:SetCurve( curve )
    self.Curve = curve

    -- Remove the old Curve's Control Points and Handles
    for _, editorCurvePoint in ipairs( self.CurvePoints ) do
        editorCurvePoint:Remove()
    end

    -- Add the new Curve's Control Points
    for _, controlPoint in ipairs( curve.Points ) do
        local controlPos     = ( controlPoint --[[@as Curves.ControlPoint]] ).Pos
        local leftHandlePos  = ( controlPoint --[[@as Curves.ControlPoint]] ).LeftHandlePos
        local rightHandlePos = ( controlPoint --[[@as Curves.ControlPoint]] ).RightHandlePos

        local editorControlPoint = vgui.Create( "CurveEditor.CurveControlPoint", self )
        editorControlPoint:SetBGColor( self.Settings.Points.Color )
        editorControlPoint:SetPos( controlPos.x, controlPos.y )

    end

end

---@return Curves.Curve The Curve that this Editor is displaying.
function PANEL:GetCurve()
    return self.Curve
end

function PANEL:GetGraphMinsMaxs()
    local width, height = self:GetSize()

    local verticalTbl = self.Settings.Axis.Vertical
    local horizontalTbl = self.Settings.Axis.Horizontal

    local minX = verticalTbl.Margins.Left
        + math.floor( verticalTbl.Width / 2 ) -- Line width

    local minY = height - horizontalTbl.Margins.Bottom
        - math.floor( horizontalTbl.Width / 2 ) -- Line width

    local mins = Vector( minX, minY )
    local maxs = Vector( width - horizontalTbl.Margins.Right, verticalTbl.Margins.Top )

    return mins, maxs
end

function PANEL:Paint( width, height )
    local drawing = _G.CurveLib.CurveDrawing

    surface.SetDrawColor( self.Settings.Background.Color )
    surface.DrawRect( 0, 0, width, height )

    drawing.PushPanel( self )
    --drawing.DrawGraph( curve )
    drawing.PopPanel()
end

function PANEL:Init()
    self.Settings = CurveEditorSettings()
    --self:SetCurve( Curve() )

    local controlPoint = vgui.Create( "CurveEditor.CurveDraggableBase", self )
    controlPoint:SetColor( self.Settings.Points.Color )
    controlPoint:SetRadius( self.Settings.Points.Radius )
    controlPoint:SetVertexDistance( self.Settings.Points.VertexDistance )
    controlPoint:SetPos( 256, 256 )

end

vgui.Register( "CurveEditor", PANEL, "Panel" )

vguihotload.HandleHotload( "CurveEditor" )