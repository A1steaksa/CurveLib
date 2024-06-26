require( "vguihotload" )

---@type CurveLib.Editor.Graph.Handle.Draw
local handleDraw

---@class CurveLib.Editor.Graph.Handle.SideHandle : CurveLib.Editor.Graph.Handle.Base
---@field MainHandle CurveLib.Editor.Graph.Handle.MainHandle
---@field SiblingHandle CurveLib.Editor.Graph.Handle.SideHandle?
---@field IsRightHandle boolean
local PANEL = {}

function PANEL:Init()
    self:SetSize( 14, 14 )
    self.IsSideHandle = true
end

function PANEL:Paint( width, height )
    handleDraw = _G.CurveLib.HandleDraw or handleDraw or include( "libraries/curvelib/editor/graph/handle/draw.lua" )

    if not self.GraphPanel then
        self.GraphPanel = self:GetParent() --[[@as CurveLib.Editor.Graph.Panel]]
    end

    handleDraw.StartPanel( self.GraphPanel.Config, self, 0, 0, width, height )

    handleDraw.SideHandle()

    handleDraw.EndPanel()
end

vgui.Register( "CurveLib.Editor.Graph.Handle.SideHandle", PANEL, "CurveLib.Editor.Graph.Handle.Base" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )