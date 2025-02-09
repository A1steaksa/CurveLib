require( "vguihotload" )

Log.ShouldSuppress( false )

Log.StartSection( "Loading CurveLib.Editor.Graph.Panel..." )

---@type CurveLib.Editor.Graph.Draw
local drawGraph = include( "libraries/curvelib/editor/graph/draw.lua" )

---@alias GraphPanel CurveLib.Editor.Graph.Panel

---@class CurveLib.Editor.Graph.Panel : CurveLib.Editor.PanelBase
---@field Caches table A table of cached values to improve performance
---@field Config GraphConfig The active configuration for this Graph

---@global
PANEL = {}

PANEL.Caches = {}
PANEL.Config = nil

--- Load the panel's modules
Log.StartSection( "Loading CurveLib.Editor.Graph.Panel's modules..." )
include( "libraries/curvelib/editor/graph/modules/config.lua" )
include( "libraries/curvelib/editor/graph/modules/coordinates-positioning.lua" )
include( "libraries/curvelib/editor/graph/modules/curve-hovering.lua" )
include( "libraries/curvelib/editor/graph/modules/curve-management.lua" )
include( "libraries/curvelib/editor/graph/modules/handle-dragging.lua" )
include( "libraries/curvelib/editor/graph/modules/handle-hovering.lua" )
include( "libraries/curvelib/editor/graph/modules/handle-management.lua" )
include( "libraries/curvelib/editor/graph/modules/handle-selection.lua" )
include( "libraries/curvelib/editor/graph/modules/interaction-settings.lua" )
include( "libraries/curvelib/editor/graph/modules/keyboard-input.lua" )
include( "libraries/curvelib/editor/graph/modules/mouse-input.lua" )
Log.EndSection()

function PANEL:Init()
    self:RequestFocus()
    self:SetKeyboardInputEnabled( true )
    self:SetMouseInputEnabled( true )

    hook.Add( "OnPauseMenuShow", self, self.HandleEscPressed )
end

function PANEL:PostConnectionInit()
    self:SetMirrorHandleDistance( true )
    self:SetMirrorHandleRotation( true )
end

function PANEL:Think()
    if self.HeldMouseButtons and self.HeldMouseButtons[ MOUSE_LEFT ] then
        -- If we don't know where the mouse was pressed, something has gone wrong
        if not self.LeftMouseDownX or not self.LeftMouseDownY then return end

        if self.IsDraggingHandles then return end

        if not self.IsBoxSelecting then
            local mouseX, mouseY = self:CursorPos()
            local distanceFromMouseDown = math.sqrt( math.pow( mouseX - self.LeftMouseDownX, 2 ) + math.pow( mouseY - self.LeftMouseDownY, 2 ) )

            if distanceFromMouseDown >= self.Config:GetDragDistanceThreshold() then
                self:StartBoxSelection()
            end
        end
    end

    if self.IsBoxSelecting then
        self:BoxSelectionThink()
    end
end

function PANEL:Paint( width, height )
    drawGraph = _G.CurveLib.GraphDraw or drawGraph

    local config = self.Config

    local interiorX, interiorY, interiorWidth, interiorHeight = self:GetInteriorRect()
    local panelX, panelY = self:LocalToScreen( 0, 0 )

    local scissorX, scissorY = panelX + interiorX, panelY + interiorY

    config:ClearAllCaches()

    drawGraph.StartPanel( config, self, 0, 0, width, height )

    -- The axes and labels
    drawGraph.GraphExterior()

    if ( self.CurrentCurve ) then
        -- The curve
        render.SetScissorRect( scissorX, scissorY, scissorX + interiorWidth, scissorY + interiorHeight, true )
        drawGraph.Curve( self.CurrentCurve )
        render.SetScissorRect( 0, 0, 0, 0, false )

        -- Most recently evaluated point
        drawGraph.RecentEvaluation( self.CurrentCurve )

        -- Handles
        for _, mainHandle in ipairs( self.MainHandles ) do
            mainHandle:PaintManual()
            if mainHandle.LeftHandle then
                mainHandle.LeftHandle:PaintManual()
            end
            if mainHandle.RightHandle then
                mainHandle.RightHandle:PaintManual()
            end
        end

    end

    -- Box around selected handles
    if ( table.Count( self.SelectedHandles ) > 0 ) then
        drawGraph.SelectedOutline( self.SelectedHandles )
    end

    if ( self.IsDraggingHandles and self.HandleUnderMouseDown.IsMainHandle ) then
        local dragData = self.HandleDragData
        if ( dragData ) then
            drawGraph.HandleDrag( dragData )
        end
    end

    -- Box selection
    -- This should remain low on the draw order to ensure it is drawn over everything else
    if ( self.IsBoxSelecting ) then
        local mouseX, mouseY = self:CursorPos()
        mouseX = math.Clamp( mouseX, 0, self:GetWide() )
        mouseY = math.Clamp( mouseY, 0, self:GetTall() )

        self.BoxSelectionEndX = mouseX
        self.BoxSelectionEndY = mouseY

        drawGraph.BoxSelection( self.LeftMouseDownX, self.LeftMouseDownY, self.BoxSelectionEndX, self.BoxSelectionEndY )
    end

    drawGraph.EndPanel()
end

function PANEL:OnSizeChanged( width, height )
    self.Caches.InteriorRect = nil
    self:PositionHandles()
end

vgui.Register( "CurveLib.Editor.Graph.Panel", PANEL, "CurveLib.Editor.PanelBase" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )

PANEL = nil

Log.EndSection()