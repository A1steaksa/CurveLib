require( "vguihotload" )

---@class CurveLib.Editor.Frame.Panels
---@field MenuBar CurveLib.Editor.MenuBar.Panel?
---@field Sidebar CurveLib.Editor.Sidebar.Panel?
---@field Graph   CurveLib.Editor.Graph.Panel?

---@class CurveLib.Editor.Frame : BFrame
---@field IsEditorFrame boolean
---@field Panels CurveLib.Editor.Frame.Panels
---@field CurrentAddon string? # The currently open addon's name.
---@field CurrentCurve CurveLib.Curve.Data? # The Curve currently being edited.
local FRAME = {
    IsEditorFrame = true,
    Panels = {
        Sidebar = nil,
        Graph = nil
    }
}

local Default = {
    FrameSize = {
        MinWidth    = 750,
        MinHeight   = 500,
        Width       = 1000,
        Height      = 750
    },
    SidebarWidth = 300
}

--- Opens an addon for editing
function FRAME:OpenAddon( name )
    self.CurrentAddon = name
    self.Panels.Sidebar:OnAddonOpened( name )
    self.Panels.Graph:OnAddonOpened( name )
    self.Panels.MenuBar:OnAddonOpened( name )
end

--- Closes an addon
function FRAME:CloseAddon( name )
    self.CurrentAddon = nil
    self.Panels.Sidebar:OnAddonClosed( name )
    self.Panels.Graph:OnAddonClosed( name )
    self.Panels.MenuBar:OnAddonClosed( name )
end

---@param curve CurveLib.Curve.Data # The Curve to open for editing
function FRAME:OpenCurve( curve )
    if not curve or not curve.IsCurve then
        error( "Cannot edit unrecognized Curve: " .. tostring( curve ) )
    end

    self.CurrentCurve = curve

    self.Panels.MenuBar:OnCurveOpened()
    self.Panels.Sidebar:OnCurveOpened()
    self.Panels.Graph:OpenCurve( curve )
end

-- Closes the currently open Curve.
function FRAME:CloseCurve()
    self.Panels.MenuBar:OnCurveClosed()
    self.Panels.Sidebar:OnCurveClosed()
    self.Panels.Graph:CloseCurve()
end

function FRAME:InitConfig()
    self.Config = CurveEditorGraphConfig()
end

function FRAME:Init()
    -- Create and configure our config table
    self:InitConfig()

    local derma = self.Panels

    derma.MenuBar = vgui.Create( "CurveLib.Editor.MenuBar.Panel", self )
    derma.MenuBar:Dock( TOP )
    derma.MenuBar:SetEditorFrame( self )

    derma.Sidebar = vgui.Create( "CurveLib.Editor.Sidebar.Panel", self )
    derma.Sidebar:SetConfig( self.Config.SidebarConfig )
    derma.Sidebar:Dock( RIGHT )
    derma.Sidebar:SetEditorFrame( self )

    derma.Graph = vgui.Create( "CurveLib.Editor.Graph.Panel", self )
    derma.Graph:SetConfig( self.Config.GraphConfig )
    derma.Graph:Dock( FILL )
    derma.Graph:SetEditorFrame( self )

    self:SetSize( Default.FrameSize.Width, Default.FrameSize.Height )
    self:SetMinWidth( Default.FrameSize.MinWidth )
    self:SetMinHeight( Default.FrameSize.MinHeight )
    self:InvalidateLayout( true )

    self:SetSizable( true )
    self:SetVisible( true )
    self:Center()
    self:MakePopup()
end

vgui.Register( "CurveLib.Editor.Frame", FRAME, "BFrame" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )