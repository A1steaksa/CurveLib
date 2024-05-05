require( "vguihotload" )
print( "Editor Frame Ran" )

---@class CurveEditor.EditorFrame.VGUI
---@field Toolbar CurveEditor.EditorToolbar?
---@field Sidebar CurveEditor.EditorSidebar?
---@field Graph CurveEditor.EditorGraph?

---@class CurveEditor.EditorFrame : DFrame
---@field Derma CurveEditor.EditorFrame.VGUI
---@field Curves table<integer, Curves.CurveData> # The list of Curves being displayed in the editor.
local FRAME = {
    Derma = {
        Toolbar = nil,
        Sidebar = nil,
        Graph = nil
    },
    Curves = {}
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


-- Returns the curve at the given index.
---@param index integer
function FRAME:GetCurve( index )
    return self.Curves[ index ]
end

-- Adds a Curve to the frame.
---@param curveData Curves.CurveData
---@return integer # The index of the Curve in the frame.
function FRAME:AddCurve( curveData )
    return table.insert( self.Curves, curveData ) --[[@as integer]]
end

-- Removes a curve from the frame.
---@param index integer
function FRAME:RemoveCurve( index )
    table.remove( self.Curves, index )
end

function FRAME:Init()

    -- Setup the default curve
    self:AddCurve( CurveData(
        CurvePoint( Vector( 0, 0 ), nil, Vector( 0.25, 0.25 ) ),
        CurvePoint( Vector( 1, 1 ), nil, Vector( 0.75, 0.75 ) )
    ) )

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