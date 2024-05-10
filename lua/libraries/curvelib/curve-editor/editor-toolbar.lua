require( "vguihotload" )

---@type CurveEditor.DrawBasic
local drawBasic = include( "libraries/curvelib/draw-basic.lua" )

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

---@param config CurveEditor.EditorConfig.ToolbarConfig
function PANEL:SetConfig( config )
    self.Config = config
end

---@return CurveEditor.EditorFrame
function PANEL:GetEditorFrame()
    return self:GetParent() --[[@as CurveEditor.EditorFrame]]
end

function PANEL:Paint( width, height )
    drawBasic.StartPanel( self )

    drawBasic.SimpleRect( 0, 0, width, height, self.Config.BackgroundColor )

    drawBasic.EndPanel()
end

vgui.Register( "CurveEditor.EditorToolbar", PANEL, "DPanel" )

vguihotload.HandleHotload( "CurveLib.EditorFrame" )