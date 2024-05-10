require( "vguihotload" )

---@type CurveEditor.DrawBasic
local drawBasic = include( "libraries/curvelib/draw-basic.lua" )

local Defaults = {
    Size = {
        Width = 250,
        height = 500
    }
}

---@class CurveEditor.EditorSidebar : DPanel
local PANEL = {}

---@param config CurveEditor.EditorConfig.SidebarConfig
function PANEL:SetConfig( config )
    self.Config = config
end

---@return CurveEditor.EditorFrame
function PANEL:GetEditorFrame()
    return self:GetParent() --[[@as CurveEditor.EditorFrame]]
end

function PANEL:Init()
    self:SetWide( Defaults.Size.Width )
end

function PANEL:Paint( width, height )
    drawBasic.StartPanel( self )

    drawBasic.SimpleRect( 0, 0, width, height, self.Config.BackgroundColor )

    drawBasic.EndPanel()
end

vgui.Register( "CurveEditor.EditorSidebar", PANEL, "DPanel" )

vguihotload.HandleHotload( "CurveLib.EditorFrame" )