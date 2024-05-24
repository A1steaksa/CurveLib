require( "vguihotload" )

---@type CurveLib.Editor.DrawBase
local drawBasic

---@type CurveLib.Editor.Utils
local curveUtils = include( "libraries/curvelib/editor/utils.lua" )

---@class CurveLib.Editor.Graph.Handle.MainHandle : CurveLib.Editor.Graph.Handle.Base
---@field GraphPanel CurveLib.Editor.Graph.Panel -- The Graph Panel this Main Handle is parented to.  Cached here for autocomplete convenience and access speed.
---@field LeftHandle CurveLib.Editor.Graph.Handle.SideHandle -- The Left Handle that this Main Handle is paired with
---@field RightHandle CurveLib.Editor.Graph.Handle.SideHandle -- The Right Handle that this Main Handle is paired with
---@field Index integer The index of the Curve Point that this Main Handle represents
local PANEL = {}

function PANEL:Init()
    self:SetSize( 20, 20 )
end

function PANEL:Paint( width, height )
    drawBasic = _G.CurveLib.DrawBase or drawBasic or include( "libraries/curvelib/editor/draw-base.lua" )

    if not self.GraphPanel then
        self.GraphPanel = self:GetParent() --[[@as CurveLib.Editor.Graph.Panel]]
    end

    local graphX, graphY = self.GraphPanel:LocalToScreen( 0, 0 )

    local interiorX, interiorY, interiorWidth, interiorHeight = self.GraphPanel:GetInteriorRect()

    render.SetScissorRect( graphX + interiorX, graphY + interiorY, graphX + interiorX + interiorWidth, graphY + interiorY + interiorHeight, true )
    drawBasic.StartPanel( self )

    -- Lines to handles
    if self.LeftHandle then
        local leftX, leftY = self.LeftHandle:GetPos()

        -- Drawing positions are relative to our position and need to be corrected
        leftX = leftX - self.x + self.LeftHandle.HalfWidth
        leftY = leftY - self.y + self.LeftHandle.HalfHeight

        drawBasic.Line( self.HalfWidth, self.HalfHeight, leftX, leftY, 2, Color( 0, 0, 0 ) )
    end

    if self.RightHandle then
        local rightX, rightY = self.RightHandle:GetPos()

        -- Drawing positions are relative to our position and need to be corrected
        rightX = rightX - self.x + self.RightHandle.HalfWidth
        rightY = rightY - self.y + self.RightHandle.HalfHeight

        drawBasic.Line( self.HalfWidth, self.HalfHeight, rightX, rightY, 2, Color( 0, 0, 0 ) )
    end

    drawBasic.Rect( self.HalfWidth, self.HalfHeight, width, height, 45, Color( 100, 216, 75 )  )

    drawBasic.EndPanel()
    render.SetScissorRect( 0, 0, 0, 0, false )
end

function PANEL:OnDragged( x, y )
    if not self.GraphPanel then
        self.GraphPanel = self:GetParent() --[[@as CurveLib.Editor.Graph.Panel]]
    end

    local correctedX, correctedY = self.GraphPanel:OnMainHandleDragged( self, x, y )
    
    return correctedX, correctedY
end

vgui.Register( "CurveLib.Editor.Graph.Handle.MainHandle", PANEL, "CurveLib.Editor.Graph.Handle.Base" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )