AddCSLuaFile()
if SERVER then return end

require( "lua.libraries.vguihotload.vguihotload-meta" )
include( "includes/curvelib/curve-drawing.lua" )

include( "includes/curvelib/vgui/curve-point/curve-draggable-base.lua" )
include( "includes/curvelib/vgui/curve-point/curve-editor-control-handle.lua" )
include( "includes/curvelib/vgui/curve-point/curve-editor-control-point.lua" )

---@class GraphInfo: table
---@field MinimumX integer The lowest X coordinate of the Graph, relative to the top-left corner of the panel
---@field MaximumX integer The highest X coordinate of the Graph, relative to the top-left corner of the panel
---@field MinimumY integer The lowest Y coordinate of the Graph, relative to the top-left corner of the panel
---@field MaximumY integer The highest Y coordinate of the Graph, relative to the top-left corner of the panel
---@field Minimums Vector The lowest X and Y coordinates of the Graph, relative to the top-left corner of the panel
---@field Maximums Vector The highest X and Y coordinates of the Graph, relative to the top-left corner of the panel
---@field Width integer The width of the Graph, in pixels
---@field Height integer The height of the Graph, in pixels
---@field Size Vector The size of the Graph, in pixels, where X = width, Y = height.

---@class (exact) CurveEditor: DPanel
---@field Settings CurveEditorSettings
---@field Curve Curves.CurveData
---@field CurvePoints table<CurveEditor.EditorControlPoint>
---@field GraphInfo GraphInfo
local PANEL = {}

function PANEL:UpdateGraphInfo()
    local panelWidth, panelHeight = self:GetSize()
    local vertical = self.Settings.Axis.Vertical
    local horizontal = self.Settings.Axis.Horizontal

    local minimumX = vertical.Margins.Left
        + math.floor( vertical.Width / 2 ) -- Line width
    local maximumX = panelWidth - horizontal.Margins.Right

    local minimumY = vertical.Margins.Top
    local maximumY = panelHeight - horizontal.Margins.Bottom
        - math.floor( horizontal.Width / 2 ) -- Line width

    local width = maximumX - minimumX
    local height = maximumY - minimumY

    self.GraphInfo = {
        MinimumX = minimumX,
        MaximumX = maximumX,
        MinimumY = minimumY,
        MaximumY = maximumY,
        Minimums = Vector( minimumX, minimumY ),
        Maximums = Vector( maximumX, maximumY ),
        Width = width,
        Height = height,
        Size = Vector( width, height )
    }
end

function PANEL:GetGraphInfo()
    if not self.GraphInfo then
        self:UpdateGraphInfo()
    end

    return self.GraphInfo
end

-- Converts a Graph position in the range [0-100] to screenspace relative to the panel's top-left corner.
---@param x number The X position of the Graph, in the range [0-100]
---@param y number The Y position of the Graph, in the range [0-100]
---@return number, number # The X and Y positions of the Graph, relative to the top-left corner of the panel.
function PANEL:GraphToPanel( x, y )
    local info = self:GetGraphInfo()

    local newX = info.MinimumX + ( info.Width * x ) / 100
    local newY = info.MinimumY + ( info.Height * ( 100 - y ) ) / 100
    return newX, newY
end

-- Converts a screenspace position, relative to the panel's top-left corner, to a Graph position in the range [0-100]
---@param x number The X position of the Graph, relative to the top-left corner of the panel.
---@param y number The Y position of the Graph, relative to the top-left corner of the panel.
function PANEL:PanelToGraph( x, y )
    local info = self:GetGraphInfo()


    local newX = ( ( ( x + self.Settings.Handles.Radius ) - info.MinimumX ) / info.Width ) * 100
    local newY = 100 - ( ( ( y + self.Settings.Handles.Radius ) - info.MinimumY ) / info.Height ) * 100

    --local newX = ( x - info.MinimumX ) * 100 / info.Width
    --local newY = 100 - ( y - info.MinimumY ) * 100 / info.Height
    return newX, newY
end

-- Moves all Draggables to their correct positions, based on their Control Point Data
function PANEL:UpdateDraggablePositions()
    for _, editorCurvePoint in ipairs( self.CurvePoints ) do
        editorCurvePoint = ( editorCurvePoint --[[@as CurveEditor.EditorControlPoint]] )

        -- Don't re-position Control Points we're currently dragging
        --if editorCurvePoint.InteractionData.IsBeingDragged then continue end

        local pointPos = editorCurvePoint.ControlPointData.ControlPointPos

        -- Control Point
        do
            local newX,newY = self:GraphToPanel( pointPos.x, pointPos.y )
            editorCurvePoint:SetPos( newX - self.Settings.Points.Radius, newY - self.Settings.Points.Radius )
        end

        -- Left Handle
        if editorCurvePoint.LeftHandle and editorCurvePoint.LeftHandle:IsValid() then
            local handlePos = editorCurvePoint.ControlPointData.LeftHandlePos
            if handlePos then
                local newX,newY = self:GraphToPanel( handlePos.x, handlePos.y )
                editorCurvePoint.LeftHandle:SetPos( newX - self.Settings.Handles.Radius, newY - self.Settings.Handles.Radius )
            end
        end

        -- Right Handle
        if editorCurvePoint.RightHandle and editorCurvePoint.RightHandle:IsValid() then
            local handlePos = editorCurvePoint.ControlPointData.RightHandlePos
            if handlePos then
                local newX,newY = self:GraphToPanel( handlePos.x, handlePos.y )
                editorCurvePoint.RightHandle:SetPos( newX - self.Settings.Handles.Radius, newY - self.Settings.Handles.Radius )
            end
        end
    end
end

-- Updates a Control Point's Data based on its current position on the panel.
---@param changedControlPoint CurveEditor.EditorControlPoint|CurveEditor.EditorControlHandle
function PANEL:UpdateDraggableData( changedControlPoint )
    local info = self:GetGraphInfo()

    if changedControlPoint == self.CurvePoints[1] then
        changedControlPoint:SetX( info.MinimumX - changedControlPoint.VisualSettings.Circle:GetRadius() )
    elseif changedControlPoint == self.CurvePoints[ #self.CurvePoints] then
        changedControlPoint:SetX( info.MaximumX - changedControlPoint.VisualSettings.Circle:GetRadius() )
    end

    -- Control Point
    local controlPointX, controlPointY = self:PanelToGraph( changedControlPoint:GetPos() )
    changedControlPoint.ControlPointData.ControlPointPos = Vector( controlPointX, controlPointY )

    -- Left Handle
    if changedControlPoint.LeftHandle then
        local leftHandleX, leftHandleY = self:PanelToGraph( changedControlPoint.LeftHandle:GetPos() )
        changedControlPoint.ControlPointData.LeftHandlePos = Vector( leftHandleX, leftHandleY )
    end

    -- Right Handle
    if changedControlPoint.RightHandle then
        local rightHandleX, rightHandleY = self:PanelToGraph( changedControlPoint.RightHandle:GetPos() )
        changedControlPoint.ControlPointData.RightHandlePos = Vector( rightHandleX, rightHandleY )
    end
end

-- Sets the Curve that this Editor will display.
---@param curve Curves.CurveData
function PANEL:SetCurve( curve )
    self.Curve = curve

    -- Remove the old Curve's Control Points and Handles
    for _, editorCurvePoint in ipairs( self.CurvePoints ) do
        editorCurvePoint:Remove()
    end

    -- Add the new Curve's Control Points
    for _, controlPoint in ipairs( curve.Points ) do

        -- Control Point
        local editorControlPoint = vgui.Create( "CurveEditor.EditorControlPoint", self )
        editorControlPoint:SetVisible( true )
        editorControlPoint:SetControlPointData( controlPoint )
        self.CurvePoints[#self.CurvePoints + 1] = editorControlPoint

        -- Left Handle
        if controlPoint.LeftHandlePos then
            local leftHandle = vgui.Create( "CurveEditor.EditorControlHandle", self )
            leftHandle:SetEditorControlPoint( editorControlPoint )
            leftHandle:SetRadius( self.Settings.Handles.Radius )
            leftHandle:SetVertexDistance( self.Settings.Handles.VertexDistance )
            leftHandle:SetVisible( true )
            editorControlPoint.LeftHandle = leftHandle
        end

        -- Right Handle
        if controlPoint.RightHandlePos then
            local rightHandle = vgui.Create( "CurveEditor.EditorControlHandle", self )
            rightHandle:SetEditorControlPoint( editorControlPoint )
            rightHandle:SetRadius( self.Settings.Handles.Radius )
            rightHandle:SetVertexDistance( self.Settings.Handles.VertexDistance )
            rightHandle:SetVisible( true )
            editorControlPoint.RightHandle = rightHandle
        end
    end

    self:UpdateDraggablePositions()
end

function PANEL:OnSizeChanged( width, height )
    self:UpdateGraphInfo()
    self:UpdateDraggablePositions()
end

function PANEL:Paint( width, height )
    local drawing = _G.CurveLib.CurveDrawing

    surface.SetDrawColor( self.Settings.Background.Color )
    surface.DrawRect( 0, 0, width, height )

    drawing.PushPanel( self )
    if self.Curve then
        drawing.DrawGraph( self.Curve )
    end
    drawing.PopPanel()
end

function PANEL:Init()
    self.Settings = CurveEditorSettings()
    self.CurvePoints = {}
    self:SetCurve( Curve() )
end

vgui.Register( "CurveEditor", PANEL, "Panel" )

vguihotload.HandleHotload( "CurveEditor" )