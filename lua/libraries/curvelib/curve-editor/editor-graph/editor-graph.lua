require( "vguihotload" )
---@type CurveEditor.EditorGraph.DrawGraph
local drawGraph = include( "libraries/curvelib/curve-editor/editor-graph/draw-graph.lua" )

surface.CreateFont( "CurveLib_Graph_Small", {
	font = "Roboto",
	extended = false,
	size = 18,
	weight = 500
} )

surface.CreateFont( "CurveLib_Graph_Large", {
	font = "Roboto",
	extended = false,
	size = 24,
	weight = 700
} )

---@class CurveEditor.EditorGraph : DPanel
local metatable = {
    Defaults = {
        Size = {
            Width = 450,
            height = 450
        }
    }
}

---@class CurveEditor.EditorGraph : DPanel
---@field Config CurveEditor.EditorConfig.GraphConfig
local PANEL = {}
setmetatable( PANEL, metatable )

---@param config CurveEditor.EditorConfig.GraphConfig
function PANEL:SetConfig( config )
    self.Config = config
end

---@return CurveEditor.EditorFrame
function PANEL:GetEditorFrame()
    return self:GetParent() --[[@as CurveEditor.EditorFrame]]
end

function PANEL:Paint( width, height )
    drawGraph = _G.CurveLib.DrawGraph or drawGraph

    drawGraph.StartPanel( self, self.Config )

    drawGraph.Graph( 0, 0, width, height )

    drawGraph.EndPanel()
end

vgui.Register( "CurveEditor.EditorGraph", PANEL, "DPanel" )

vguihotload.HandleHotload( "CurveLib.EditorFrame" )