require( "vguihotload" )

---@type CurveLib.Editor.Graph.Handle.Draw
local handleDraw

---@class CurveLib.Editor.Graph.Handle.MainHandle : CurveLib.Editor.Graph.Handle.Base
---@field LeftHandle CurveLib.Editor.Graph.Handle.SideHandle -- The Left Handle that this Main Handle is paired with
---@field RightHandle CurveLib.Editor.Graph.Handle.SideHandle -- The Right Handle that this Main Handle is paired with
---@field Index integer The index of the Curve Point that this Main Handle represents
local PANEL = {}

function PANEL:Init()
    self:SetSize( 20, 20 )
end

function PANEL:Paint( width, height )
    handleDraw = _G.CurveLib.HandleDraw or handleDraw or include( "libraries/curvelib/editor/graph/handle/draw.lua" )

    if not self.GraphPanel then
        self.GraphPanel = self:GetParent() --[[@as CurveLib.Editor.Graph.Panel]]
    end

    handleDraw.StartPanel( self.GraphPanel.Config, self, 0, 0, width, height )

    handleDraw.MainHandleLines()

    handleDraw.MainHandle()

    handleDraw.EndPanel()
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