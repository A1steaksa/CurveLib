require( "vguihotload" )

local Defaults = {
    Size = {
        Width = 250,
        height = 500
    }
}

---@class CurveEditor.EditorSidebar : DPanel
local PANEL = {}

function PANEL:Init()
    self:SetWide( Defaults.Size.Width )
end

vgui.Register( "CurveEditor.EditorSidebar", PANEL, "DPanel" )

vguihotload.HandleHotload( "CurveLib.EditorFrame" )