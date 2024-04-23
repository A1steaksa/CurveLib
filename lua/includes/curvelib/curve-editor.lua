AddCSLuaFile()
if SERVER then return end

require( "vguihotload" )

local drawing = include( "includes/curvelib/curve-drawing.lua" ) --[[@as CurveDraw]]

---@class CurveEditor: DPanel
local PANEL = {
    Settings = CurveEditorSettings()
}

function PANEL:GetGraphMinsMaxs()
    local width, height = self:GetSize()

    local verticalTbl = self.Settings.Axis.Vertical
    local horizontalTbl = self.Settings.Axis.Horizontal

    local minX = verticalTbl.Margins.Left
    + math.floor( verticalTbl.Width / 2 ) -- Line width

    local minY = height - horizontalTbl.Margins.Bottom
    - math.floor( horizontalTbl.Width / 2 ) -- Line width

    local mins = Vector( minX, minY )
    local maxs = Vector( width - horizontalTbl.Margins.Right, verticalTbl.Margins.Top )

    return mins, maxs
end

function PANEL:Paint( width, height )
    surface.SetDrawColor( self.Settings.Background.Color )
    surface.DrawRect( 0, 0, width, height )

    local curve = Curve()
    drawing.PushOrigin( self:LocalToScreen( 0, 0 ) )
    --drawing.DrawGraph( self, curve )

    surface.SetFont( self.Settings.Axis.Horizontal.Label.Font )

    local text = "Hello, World!"
    local centerX, centerY = 500, 500
    local padding = 100
    local textWidth, textHeight = surface.GetTextSize( text )

    local rotation = ( CurTime() * 10 ) % 360

    -- Top Left
    drawing.DrawText( text, centerX - textWidth * 1.5 - padding, centerY - textHeight - padding, rotation, TEXT_ALIGN_LEFT, TEXT_ALIGN_TOP )

    -- Top Center
    drawing.DrawText( text, centerX, centerY - textHeight - padding, rotation, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

    -- Top Right
    drawing.DrawText( text, centerX + textWidth * 1.5 + padding, centerY - textHeight - padding, rotation, TEXT_ALIGN_RIGHT, TEXT_ALIGN_TOP )

    -- Center Left
    drawing.DrawText( text, centerX - textWidth * 1.5 - padding, centerY, rotation, TEXT_ALIGN_LEFT, TEXT_ALIGN_CENTER )

    -- Center Center
    drawing.DrawText( text, centerX, centerY, rotation, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

    -- Center Right
    drawing.DrawText( text, centerX + textWidth * 1.5 + padding, centerY, rotation, TEXT_ALIGN_RIGHT, TEXT_ALIGN_CENTER )

    -- Bottom Left
    drawing.DrawText( text, centerX - textWidth * 1.5 - padding, centerY + textHeight + padding, rotation, TEXT_ALIGN_LEFT, TEXT_ALIGN_BOTTOM )

    -- Bottom Center
    drawing.DrawText( text, centerX, centerY + textHeight + padding, rotation, TEXT_ALIGN_CENTER, TEXT_ALIGN_BOTTOM )

    -- Bottom Right
    drawing.DrawText( text, centerX + textWidth * 1.5 + padding, centerY + textHeight + padding, rotation, TEXT_ALIGN_RIGHT, TEXT_ALIGN_BOTTOM )

    -- Draw a red center line through every text's vertical and horizontal center
    surface.SetDrawColor( 255, 0, 0 )

    -- Top Row
    drawing.DrawLine( centerX - textWidth * 2.5 - padding, centerY - textHeight - padding, centerX + textWidth * 2.5 + padding, centerY - textHeight - padding, 1 )

    -- Center Row
    drawing.DrawLine( centerX - textWidth * 2.5 - padding, centerY, centerX + textWidth * 2.5 + padding, centerY, 1 )

    -- Bottom Row
    drawing.DrawLine( centerX - textWidth * 2.5 - padding, centerY + textHeight + padding, centerX + textWidth * 2.5 + padding, centerY + textHeight + padding, 1 )

    -- Left Column
    drawing.DrawLine( centerX - textWidth * 1.5 - padding, centerY - textHeight * 2 - padding, centerX - textWidth * 1.5 - padding, centerY + textHeight * 2 + padding, 1 )

    -- Center Column
    drawing.DrawLine( centerX, centerY - textHeight * 2 - padding, centerX, centerY + textHeight * 2 + padding, 1 )

    -- Right Column
    drawing.DrawLine( centerX + textWidth * 1.5 + padding, centerY - textHeight * 2 - padding, centerX + textWidth * 1.5 + padding, centerY + textHeight * 2 + padding, 1 )

    drawing.PopOrigin()
end

vgui.Register( "CurveEditor", PANEL, "Panel" )

vguihotload.HandleHotload( "CurveEditor" )