require( "vguihotload" )
---@type CurveEditor.EditorGraph.CurveDraw
local curveDraw = include( "libraries/curvelib/curve-editor/editor-graph/curve-draw.lua" )

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
local PANEL = {}
setmetatable( PANEL, metatable )

-- Returns the editor frame that this graph is a part of.
---@return CurveEditor.EditorFrame
function PANEL:GetEditor()
    return self:GetParent() --[[@as CurveEditor.EditorFrame]]
end

function PANEL:Init()
    self.Config = CurveEditorGraphConfig()
    self.Config.Fonts.NumberLineLarge = "CurveLib_Graph_Large"
    self.Config.Fonts.NumberLineSmall = "CurveLib_Graph_Small"
end

function PANEL:Paint( width, height )
    curveDraw = _G.CurveLib.CurveDraw or curveDraw

    curveDraw.StartPanel( self, self.Config )

    curveDraw.Graph( 0, 0, width, height )

    curveDraw.EndPanel()
end

vgui.Register( "CurveEditor.EditorGraph", PANEL, "DPanel" )

vguihotload.HandleHotload( "CurveLib.EditorFrame" )