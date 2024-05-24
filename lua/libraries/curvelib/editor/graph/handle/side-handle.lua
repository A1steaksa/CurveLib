require( "vguihotload" )

---@type CurveLib.Editor.DrawBase
local drawBasic

---@type CurveLib.Editor.Utils
local curveUtils = include( "libraries/curvelib/editor/utils.lua" )

---@class CurveLib.Editor.Graph.Handle.SideHandle : CurveLib.Editor.Graph.Handle.Base
---@field GraphPanel CurveLib.Editor.Graph.Panel -- The Graph Panel this Main Handle is parented to.  Cached here for autocomplete convenience and access speed.
---@field MainHandle CurveLib.Editor.Graph.Handle.MainHandle
---@field IsRightHandle boolean
local PANEL = {}

function PANEL:Init()
    self:SetSize( 20, 20 )
end

function PANEL:Paint( width, height )
    drawBasic = _G.CurveLib.DrawBase or drawBasic or include( "libraries/curvelib/editor/draw-base.lua" )

    if not self.GraphPanel then
        self.GraphPanel = self:GetParent() --[[@as CurveLib.Editor.Graph.Panel]]
    end

    local halfWidth, halfHeight = curveUtils.MultiFloor( width / 2, height / 2 )

    local parent = self:GetParent() --[[@as CurveLib.Editor.Graph.Panel]]

    local graphX, graphY = parent:LocalToScreen( 0, 0 )

    local interiorX, interiorY, interiorWidth, interiorHeight = parent:GetInteriorRect()

    render.SetScissorRect( graphX + interiorX, graphY + interiorY, graphX + interiorX + interiorWidth, graphY + interiorY + interiorHeight, true )
    drawBasic.StartPanel( self )
    drawBasic.Rect( halfWidth, halfHeight, width, height, 45, Color( 85, 75, 210 )  )
    drawBasic.EndPanel()
    render.SetScissorRect( 0, 0, 0, 0, false )
end

function PANEL:OnDragged( x, y )
    if not self.GraphPanel then
        self.GraphPanel = self:GetParent() --[[@as CurveLib.Editor.Graph.Panel]]
    end

    local correctedX, correctedY = self.GraphPanel:OnSideHandleDragged( self, x, y )

    return correctedX, correctedY
end

vgui.Register( "CurveLib.Editor.Graph.Handle.SideHandle", PANEL, "CurveLib.Editor.Graph.Handle.Base" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )