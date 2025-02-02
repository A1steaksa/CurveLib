require( "vguihotload" )

---@type HandleDraw
local handleDraw = include( "libraries/curvelib/editor/graph/handle/draw.lua" )

---@alias MainHandle CurveLib.Editor.Graph.Handle.MainHandle

---@class CurveLib.Editor.Graph.Handle.MainHandle : CurveLib.Editor.Graph.Handle.Base
---@field LeftHandle CurveLib.Editor.Graph.Handle.SideHandle The Left Handle that this Main Handle is paired with
---@field RightHandle CurveLib.Editor.Graph.Handle.SideHandle The Right Handle that this Main Handle is paired with
---@field Index integer The index of the Curve Point that this Main Handle represents
local PANEL = {}

function PANEL:Init()
    self:SetSize( 20, 20 )
    self.IsMainHandle = true

    self.MainHandle = self
end

function PANEL:Paint( width, height )
    if not self.GraphPanel then
        self.GraphPanel = self:GetParent() --[[@as CurveLib.Editor.Graph.Panel]]
    end

    handleDraw.StartPanel( self.GraphPanel.Config, self, 0, 0, width, height )
        if self:IsSelected() then
            handleDraw.MainHandleLines()
        end

        handleDraw.MainHandle()
    handleDraw.EndPanel()
end

vgui.Register( "CurveLib.Editor.Graph.Handle.MainHandle", PANEL, "CurveLib.Editor.Graph.Handle.Base" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )