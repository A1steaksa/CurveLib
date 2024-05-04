require( "vguihotload" )
print( "Editor Frame Ran" )

---@class CurveEditor.EditorFrame.VGUI
---@field Toolbar CurveEditor.EditorToolbar\
---@field Sidebar CurveEditor.EditorSidebar
---@field Graph CurveEditor.EditorGraph

---@class CurveEditor.EditorFrame : DFrame
---@field derma CurveEditor.EditorFrame.VGUI
local FRAME = {
    Initialized = false,
    Derma = {}
}

local Default = {
    FrameSize = {
        MinWidth    = 750,
        MinHeight   = 500,
        Width       = 1000,
        Height      = 750
    },
    SidebarWidth = 150,
    ToolbarHeight = 100
}

function FRAME:Init()
    local derma = self.Derma

    derma.Toolbar = vgui.Create( "CurveEditor.EditorToolbar", self )
    derma.Toolbar:Dock( TOP )

    derma.Sidebar = vgui.Create( "CurveEditor.EditorSidebar", self )
    derma.Sidebar:Dock( RIGHT )

    derma.Graph = vgui.Create( "CurveEditor.EditorGraph",   self )
    derma.Graph:Dock( FILL )

    self:SetSize( Default.FrameSize.Width, Default.FrameSize.Height )
    self:SetMinimumSize( Default.FrameSize.MinWidth, Default.FrameSize.MinHeight )
    

    self:InvalidateLayout( true )
    self:SetSizable( true )
    self:SetVisible( true )
    self:Center()
    self:MakePopup()
end

vgui.Register( "CurveEditor.EditorFrame", FRAME, "DFrame" )

vguihotload.HandleHotload( "CurveLib.EditorFrame" )
---

concommand.Add( "curvelib_openeditor", function()
    vguihotload.Register( "CurveLib.EditorFrame", function()
        return vgui.Create( "CurveEditor.EditorFrame" )
    end )
end )