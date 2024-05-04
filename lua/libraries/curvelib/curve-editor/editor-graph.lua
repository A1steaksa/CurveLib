require( "vguihotload" )

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

function PANEL:Init()

end

vgui.Register( "CurveEditor.EditorGraph", PANEL, "DPanel" )

vguihotload.HandleHotload( "CurveLib.EditorFrame" )