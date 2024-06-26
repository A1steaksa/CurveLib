require( "vguihotload" )

---@type CurveLib.Editor.DrawBase
local drawBasic

---@type CurveLib.Editor.Utils
local curveUtils = include( "libraries/curvelib/editor/utils.lua" )

local Defaults = {
    Size = {
        Width = 250
    }
}

---@class CurveLib.Editor.Sidebar.Panel : CurveLib.Editor.PanelBase
local PANEL = {}

function PANEL:Init()
    local panel = self

    self:SetWide( Defaults.Size.Width )

    local settingsPanel = vgui.Create( "DPanel", self )
    settingsPanel:Dock( TOP )
    settingsPanel:SetTall( 200 )

    local mirrorRotationCheckbox = vgui.Create( "DCheckBoxLabel", settingsPanel )
    mirrorRotationCheckbox:SetText( "Mirror Handle Rotation" )
    mirrorRotationCheckbox:Dock( TOP )
    function mirrorRotationCheckbox:OnChange( value )
        panel:GetGraph().State.IsRotationMirrored = value
    end

    local mirrorDistanceCheckbox = vgui.Create( "DCheckBoxLabel", settingsPanel )
    mirrorDistanceCheckbox:SetText( "Mirror Handle Distance" )
    mirrorDistanceCheckbox:Dock( TOP )
    function mirrorDistanceCheckbox:OnChange( value )
        panel:GetGraph().State.IsDistanceMirrored = value
    end
end

function PANEL:Paint( width, height )
    local drawBasic = _G.CurveLib.DrawBase or drawBasic or include( "libraries/curvelib/editor/draw-base.lua" )

    drawBasic.StartPanel( self )

    drawBasic.Rect( 0, 0, width, height, 0, Alignment.TopLeft, self.Config.BackgroundColor )

    drawBasic.EndPanel()
end

vgui.Register( "CurveLib.Editor.Sidebar.Panel", PANEL, "CurveLib.Editor.PanelBase" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )