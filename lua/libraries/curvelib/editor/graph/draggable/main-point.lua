require( "vguihotload" )

---@type CurveLib.Editor.DrawBase
local drawBasic

---@type CurveLib.Editor.Utils
local curveUtils = include( "libraries/curvelib/editor/utils.lua" )

---@class CurveLib.Editor.Graph.Draggable.MainPoint : CurveLib.Editor.Graph.Draggable.Base
---@field Point CurveLib.Curve.Point
local PANEL = {}

function PANEL:Init()
    self:SetSize( 20, 20 )
end

function PANEL:Paint( width, height )
    drawBasic = _G.CurveLib.DrawBase or drawBasic or include( "libraries/curvelib/editor/draw-base.lua" )

    local halfWidth, halfHeight = curveUtils.MultiFloor( width / 2, height / 2 )

    local parent = self:GetParent() --[[@as CurveLib.Editor.Graph.Panel]]

    local graphX, graphY = parent:LocalToScreen( 0, 0 )

    local interiorX, interiorY, interiorWidth, interiorHeight = parent:GetInteriorRect()

    render.SetScissorRect( graphX + interiorX, graphY + interiorY, graphX + interiorX + interiorWidth, graphY + interiorY + interiorHeight, true )
    drawBasic.StartPanel( self )
    drawBasic.Rect( halfWidth, halfHeight, width, height, 45, Color( 100, 216, 75 )  )
    drawBasic.EndPanel()
    render.SetScissorRect( 0, 0, 0, 0, false )
end

function PANEL:OnDragged( x, y )
    local correctedX, correctedY = (self:GetParent() --[[@as CurveLib.Editor.Graph.Panel]]):OnMainPointDragged( self, x, y )
    return correctedX, correctedY
end

-- Set the point that this Main Point represents
---@param point CurveLib.Curve.Point
function PANEL:SetPoint( point )
    self.Point = point
end

vgui.Register( "CurveLib.Editor.Graph.Draggable.MainPoint", PANEL, "CurveLib.Editor.Graph.Draggable.Base" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )