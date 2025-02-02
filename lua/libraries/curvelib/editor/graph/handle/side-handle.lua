require( "vguihotload" )

---@type HandleDraw
local handleDraw = include( "libraries/curvelib/editor/graph/handle/draw.lua" )

---@alias SideHandle CurveLib.Editor.Graph.Handle.SideHandle

---@class CurveLib.Editor.Graph.Handle.SideHandle : CurveLib.Editor.Graph.Handle.Base
---@field MainHandle MainHandle
---@field SiblingHandle SideHandle?
---@field IsRightHandle boolean
local PANEL = {}

function PANEL:Init()
    self:SetSize( 14, 14 )
    self.IsSideHandle = true
end

function PANEL:Paint( width, height )
    if not self:IsEnabled() then return end

    handleDraw.StartPanel( self.GraphPanel.Config, self, 0, 0, width, height )
       handleDraw.SideHandle()
    handleDraw.EndPanel()
end

vgui.Register( "CurveLib.Editor.Graph.Handle.SideHandle", PANEL, "CurveLib.Editor.Graph.Handle.Base" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )