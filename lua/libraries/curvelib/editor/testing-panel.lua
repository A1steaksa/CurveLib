require( "vguihotload" )

---@type CurveLib.Editor.Graph.Draw
local drawGraph = include( "libraries/curvelib/editor/graph/draw.lua" )

---@type CurveLib.Editor.DrawBase
local drawBase = include( "libraries/curvelib/editor/draw-base.lua" )

---@class CurveLib.Editor.Graph.Panel : CurveLib.Editor.PanelBase
local PANEL = {}

local COLOR_WHITE = Color( 255, 255, 255, 255 )
local COLOR_BLACK = Color( 0, 0, 0, 255 )
local COLOR_RED = Color( 255, 0, 0, 255 )
local COLOR_GREEN = Color( 0, 255, 0, 255 )
local COLOR_BLUE = Color( 0, 0, 255, 255 )

PANEL.MinRadius = 3
PANEL.MaxRadius = 25
PANEL.Diameter = PANEL.MaxRadius

PANEL.MinVertexCount = 10
PANEL.MaxVertexCount = 100
PANEL.VertexCount = PANEL.MaxVertexCount

function PANEL:Init()
    local buttonWidth = 50
    local buttonHeight = 25

    local labelWidth = 65
    local labelHeight = buttonHeight

    local buttonStartX = 200
    local buttonStartY = 50

    local padding = 5

    do -- Radius Debug Config
        local label = vgui.Create( "DLabel", self )
        local decreaseButton = vgui.Create( "DButton", self )
        local valueLabel = vgui.Create( "DLabel", self )
        local increaseButton = vgui.Create( "DButton", self )

        -- Label
        label:SetPos( buttonStartX, buttonStartY - labelHeight - padding )
        label:SetSize( labelWidth + buttonWidth * 2 + padding * 2, labelHeight )
        label:SetText( "Radius" )
        label:SetFont( "DermaLarge" )
        label:SetTextColor( COLOR_WHITE )
        label:SetContentAlignment( 5 )

        -- Decrease Button
        decreaseButton:SetText( "-" )
        decreaseButton:SetSize( buttonWidth, buttonHeight )
        decreaseButton:SetPos(
            buttonStartX,
            buttonStartY
        )
        decreaseButton.DoClick = function()
            self.Diameter = math.max( self.Diameter - 1, self.MinRadius )
            valueLabel:SetText(tostring( self.Diameter ) )
        end

        -- Radius Label
        valueLabel:SetPos(
            buttonStartX + buttonWidth + padding,
            buttonStartY
        )
        valueLabel:SetSize( labelWidth, labelHeight )
        valueLabel:SetText( tostring( self.Diameter ) )
        valueLabel:SetFont( "DermaLarge" )
        valueLabel:SetTextColor( COLOR_WHITE )
        valueLabel:SetContentAlignment( 5 )

        -- Increase Button
        increaseButton:SetText( "+" )
        increaseButton:SetSize( buttonWidth, buttonHeight )
        increaseButton:SetPos(
            buttonStartX + buttonWidth + padding + labelWidth + padding,
            buttonStartY
        )
        increaseButton.DoClick = function()
            self.Diameter = math.min( self.Diameter + 1, self.MaxRadius )
            valueLabel:SetText(tostring( self.Diameter ) )
        end
    end

    do -- Vertex Count Debug Config
        local label = vgui.Create( "DLabel", self )
        local decreaseButton = vgui.Create( "DButton", self )
        local valueLabel = vgui.Create( "DLabel", self )
        local increaseButton = vgui.Create( "DButton", self )

        -- Label
        label:SetPos( buttonStartX, buttonStartY + buttonHeight + padding )
        label:SetSize( labelWidth + buttonWidth * 2 + padding * 2, labelHeight )
        label:SetText( "Vertex Count" )
        label:SetFont( "DermaLarge" )
        label:SetTextColor( COLOR_WHITE )
        label:SetContentAlignment( 5 )

        -- Decrease Button
        decreaseButton:SetText( "-" )
        decreaseButton:SetSize( buttonWidth, buttonHeight )
        decreaseButton:SetPos(
            buttonStartX,
            buttonStartY + buttonHeight + padding * 2 + labelHeight
        )
        decreaseButton.DoClick = function()
            self.VertexCount = math.max( self.VertexCount - 1, self.MinVertexCount )
            valueLabel:SetText(tostring( self.VertexCount ) )
        end

        -- Radius Label
        valueLabel:SetPos(
            buttonStartX + buttonWidth + padding,
            buttonStartY + buttonHeight + padding * 2 + labelHeight
        )
        valueLabel:SetSize( labelWidth, labelHeight )
        valueLabel:SetText( tostring( self.VertexCount ) )
        valueLabel:SetFont( "DermaLarge" )
        valueLabel:SetTextColor( COLOR_WHITE )
        valueLabel:SetContentAlignment( 5 )

        -- Increase Button
        increaseButton:SetText( "+" )
        increaseButton:SetSize( buttonWidth, buttonHeight )
        increaseButton:SetPos(
            buttonStartX + buttonWidth + padding + labelWidth + padding,
            buttonStartY + buttonHeight + padding * 2 + labelHeight
        )
        increaseButton.DoClick = function()
            self.VertexCount = math.min( self.VertexCount + 1, self.MaxVertexCount )
            valueLabel:SetText(tostring( self.VertexCount ) )
        end
    end

end

local drawStartX = 100
local drawStartY = 125

function PANEL:Paint( width, height )
    drawBase.StartPanel( self )

    -- Background
    drawBase.Rect( 0, 0, width, height, 0, Alignment.TopLeft, COLOR_BLACK )

    local alignment = Alignment.Center

    -- Draw a circle
    drawBase.Circle( drawStartX, drawStartY, self.Diameter + 0.5, 0, self.VertexCount, alignment, Color( 255, 0, 255, 255 ) )
    drawBase.Circle( drawStartX, drawStartY, self.Diameter, 0, self.VertexCount, alignment, Color( 0, 0, 255, 255 ) )
    --drawBase.Circle( drawStartX, drawStartY, self.Radius, 0, self.VertexCount, Alignment.Center, COLOR_BLUE )

    -- Draw Center Lines
    --drawBase.Line( drawStartX - self.MaxRadius * 2, drawStartY, drawStartX + self.MaxRadius * 2, drawStartY, 1, Alignment.Center, COLOR_RED )
    --drawBase.Line( drawStartX, drawStartY - self.MaxRadius * 2, drawStartX, drawStartY + self.MaxRadius * 2, 1, Alignment.Center, COLOR_RED )

    drawBase.EndPanel()
end

vgui.Register( "CurveLib.Editor.TestingPanel", PANEL, "CurveLib.Editor.PanelBase" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )