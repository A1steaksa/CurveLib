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

    local editButton = vgui.Create( "DButton", self )
    editButton:SetText( "Edit" )
    editButton:Dock( LEFT )
    editButton:DockMargin( 0, 0, 5, 0 )
    editButton.DoClick = function()
        local traceEntity = LocalPlayer():GetEyeTrace().Entity
        
        if traceEntity then
                local lookedAtCurve = traceEntity.Curve

            if lookedAtCurve then
                self:GetEditorFrame():EditCurve( lookedAtCurve )
            else
                print( "No curve found" )
            end
        else
            print( "No entity found" )
        end
    end

end

function PANEL:Paint( width, height )
    local drawBasic = _G.CurveLib.DrawBase or drawBasic or include( "libraries/curvelib/editor/draw-base.lua" )

    drawBasic.StartPanel( self )

    drawBasic.Rect( 0, 0, width, height, 0, Alignment.TopLeft, self.Config.BackgroundColor )

    drawBasic.EndPanel()
end

vgui.Register( "CurveLib.Editor.Toolbar.Panel", PANEL, "CurveLib.Editor.PanelBase" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )