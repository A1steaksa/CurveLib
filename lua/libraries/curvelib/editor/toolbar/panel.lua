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

    local newButton = vgui.Create( "BButton", self )
    newButton:SetText( "New" )
    newButton:Dock( LEFT )
    newButton:DockMargin( 0, 0, 8, 0 )
    newButton.DoClick = function()
        local editorFrame = self:GetEditorFrame()
        editorFrame:EditNewCurve()
    end

    local editButton = vgui.Create( "BButton", self )
    editButton:SetText( "Edit Entity" )
    editButton:Dock( LEFT )
    editButton:DockMargin( 0, 0, 8, 0 )
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

    local saveButton = vgui.Create( "BButton", self )
    saveButton:SetText( "Save" )
    saveButton:Dock( LEFT )
    saveButton:DockMargin( 0, 0, 8, 0 )
    saveButton.DoClick = function()
        CurveLib.Popups.SaveFile( function( filePath )
            
            local curve = self:GetEditorFrame().Panels.Graph.CurrentCurve

            if not curve then
                print( "No curve to save" )
                return
            end

            CurveLib.SaveCurve( filePath, curve )
                
        end )
    end

    local loadButton = vgui.Create( "BButton", self )
    loadButton:SetText( "Load" )
    loadButton:Dock( LEFT )
    loadButton:DockMargin( 0, 0, 8, 0 )
    loadButton.DoClick = function()
        CurveLib.Popups.LoadFile( function( filePath )
            
            local loadedCurve = CurveLib.LoadCurve( filePath )

            if loadedCurve then
                self:GetEditorFrame():EditCurve( loadedCurve )
            end

        end )
    end

end

function PANEL:Paint( width, height )
    local drawBasic = _G.CurveLib.DrawBase or drawBasic or include( "libraries/curvelib/editor/draw-base.lua" )

    drawBasic.StartPanel( self )

    drawBasic.Rect( 0, 0, width, height, 0, Alignment.TopLeft, self.Config.BackgroundColor )

    drawBasic.EndPanel()
end

--- Called when a curve is opened.
function PANEL:OnCurveOpened()
    self.File.Save:SetEnabled( true )
    self.File.SaveAs:SetEnabled( true )
    self.File.SaveAll:SetEnabled( true )

    self.File.Export:SetEnabled( true )

    self.File.CloseGraph:SetEnabled( true )
    self.File.CloseAllGraphs:SetEnabled( true )
end

--- Called when a curve is closed.
function PANEL:OnCurveClosed()
    self.File.Save:SetEnabled( false )
    self.File.SaveAs:SetEnabled( false )
    self.File.SaveAll:SetEnabled( false )

    self.File.Export:SetEnabled( false )

    self.File.CloseGraph:SetEnabled( false )
    self.File.CloseAllGraphs:SetEnabled( false )
end

vgui.Register( "CurveLib.Editor.Toolbar.Panel", PANEL, "CurveLib.Editor.PanelBase" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )