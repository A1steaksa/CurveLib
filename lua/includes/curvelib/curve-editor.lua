AddCSLuaFile()
if SERVER then return end

require( "vguihotload" )

local drawing = include( "includes/curvelib/curve-drawing.lua" ) --[[@as CurveDraw]]

---@class CurveEditor: DPanel
local PANEL = {
    Settings = CurveEditorSettings()
}

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
    surface.SetDrawColor( self.Settings.Background.Color )
    surface.DrawRect( 0, 0, width, height )

    local curve = Curve()
    drawing.PushOrigin( self:LocalToScreen( 0, 0 ) )
    drawing.DrawGraph( self, curve )
    drawing.PopOrigin()
end

vgui.Register( "CurveEditor", PANEL, "Panel" )

vguihotload.HandleHotload( "CurveEditor" )