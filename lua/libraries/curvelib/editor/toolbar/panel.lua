require( "vguihotload" )

---@type CurveLib.Editor.DrawBase
local drawBasic

---@type CurveLib.Editor.Utils
local curveUtils = include( "libraries/curvelib/editor/utils.lua" )

local Defaults = {
    Size = {
        Height = 100
    }
}

---@class CurveLib.Editor.Toolbar.Panel : CurveLib.Editor.PanelBase
local PANEL = {}

function PANEL:Init()
    self:SetWide( Defaults.Size.Width )
end

function PANEL:Paint( width, height )
    local drawBasic = _G.CurveLib.DrawBase or drawBasic or include( "libraries/curvelib/editor/draw-base.lua" )

    local halfWidth, halfHeight = curveUtils.MultiFloor( width / 2, height / 2 )
    drawBasic.StartPanel( self )

    drawBasic.Rect( halfWidth, halfHeight, width, height, 0, self.Config.BackgroundColor )

    drawBasic.EndPanel()
end

vgui.Register( "CurveLib.Editor.Toolbar.Panel", PANEL, "CurveLib.Editor.PanelBase" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )