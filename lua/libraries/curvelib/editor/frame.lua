require( "vguihotload" )

---@class CurveLib.Editor.Frame.Panels
---@field Toolbar CurveLib.Editor.Toolbar.Panel?
---@field Sidebar CurveLib.Editor.Sidebar.Panel?
---@field Graph   CurveLib.Editor.Graph.Panel?

---@class CurveLib.Editor.Frame : BFrame
---@field IsEditorFrame boolean
---@field Panels CurveLib.Editor.Frame.Panels
---@field Curves table<integer, CurveLib.Curve.Data> # The list of Curves being displayed in the editor.
---@field EditingCurve CurveLib.Curve.Data? # The Curve currently being edited.
local FRAME = {
    IsEditorFrame = true,
    Panels = {
        Toolbar = nil,
        Sidebar = nil,
        Graph = nil
    },
    Curves = {},
    EditingCurve = nil
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

-- Opens a given Curve for editing
---@param curveOrIndex CurveLib.Curve.Data|integer # The Curve to open for editing.  Either the Curve Data table or the index of the Curve in the Editor Frame.
function FRAME:EditCurve( curveOrIndex )
    local curve
    if curveOrIndex.IsCurve then
        curve = curveOrIndex --[[@as CurveLib.Curve.Data]]
    elseif isnumber( curveOrIndex ) then
        curve = self.Curves[ curveOrIndex ]
    else
        error( "Cannot edit unrecognized Curve: " .. curveOrIndex )
    end

    self.Panels.Graph:EditCurve( curve )
end

-- Adds a Curve to the frame.
---@param curveData CurveLib.Curve.Data
---@return integer # The index of the Curve in the frame.
function FRAME:AddCurve( curveData )
    return table.insert( self.Curves, curveData ) --[[@as integer]]
end

-- Removes a curve from the frame.
---@param index integer
function FRAME:RemoveCurve( index )
    table.remove( self.Curves, index )
end

function FRAME:InitConfig()
    self.Config = CurveEditorGraphConfig()
end

function FRAME:Init()

    -- Create and configure our config table
    self:InitConfig()

    local derma = self.Panels

    derma.Toolbar = vgui.Create( "CurveLib.Editor.Toolbar.Panel", self )
    derma.Toolbar:SetConfig( self.Config.ToolbarConfig )
    derma.Toolbar:Dock( TOP )

    derma.Sidebar = vgui.Create( "CurveLib.Editor.Sidebar.Panel", self )
    derma.Sidebar:SetConfig( self.Config.SidebarConfig )
    derma.Sidebar:Dock( RIGHT )

    derma.Graph = vgui.Create( "CurveLib.Editor.Graph.Panel",   self )
    derma.Graph:SetConfig( self.Config.GraphConfig )
    derma.Graph:Dock( FILL )

    self:SetSize( Default.FrameSize.Width, Default.FrameSize.Height )
    self:SetMinWidth( Default.FrameSize.MinWidth )
    self:SetMinHeight(  Default.FrameSize.MinHeight  )
    self:InvalidateLayout( true )

    -- Setup the default curve
    self.Curves = {}

    local defaultCurve = CurveData(
        CurvePoint( Vector( 0, 0 ), nil, Vector( 0.25, 0.25 ) ),
        CurvePoint( Vector( 0.5, 0.5 ), Vector( 0.25, 0.75 ), Vector( 0.75, 0.25 ) ),
        CurvePoint( Vector( 1, 1 ), Vector( 0.75, 0.75 ), nil )
    )
    self:AddCurve( defaultCurve )
    self:EditCurve( defaultCurve )

    self:SetSizable( true )
    self:SetVisible( true )
    self:Center()
    self:MakePopup()
end

vgui.Register( "CurveLib.Editor.Frame", FRAME, "BFrame" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )