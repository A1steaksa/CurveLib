require( "vguihotload" )

---@class CurveEditor.EditorToolbar : DPanel
local metatable = {
    Defaults = {
        Size = {
            Width = 500,
            height = 100
        }
    }
}

---@class CurveEditor.EditorToolbar : DPanel
local PANEL = {}
setmetatable( PANEL, metatable )

function PANEL:Init()

end

vgui.Register( "CurveEditor.EditorToolbar", PANEL, "DPanel" )

vguihotload.HandleHotload( "CurveLib.EditorFrame" )