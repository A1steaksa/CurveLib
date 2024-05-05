require( "vguihotload" )
---@type CurveEditor.EditorGraph.CurveDraw
local curveDraw = include( "libraries/curvelib/curve-editor/editor-graph/curve-draw.lua" )

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

end

function PANEL:Paint( width, height )
    curveDraw = _G.CurveLib.CurveDraw or curveDraw

    curveDraw.PushPanel( self )

    curveDraw.Graph( width, height )
    
    curveDraw.PopPanel()
end

vgui.Register( "CurveEditor.EditorGraph", PANEL, "DPanel" )

vguihotload.HandleHotload( "CurveLib.EditorFrame" )