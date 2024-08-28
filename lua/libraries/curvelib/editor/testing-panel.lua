require( "vguihotload" )

---@type CurveLib.Editor.Graph.Draw
local drawGraph = include( "libraries/curvelib/editor/graph/draw.lua" )

---@type CurveLib.Editor.DrawBase
local drawBase = include( "libraries/curvelib/editor/draw-base.lua" )

---@class CurveLib.Editor.Graph.Panel : CurveLib.Editor.PanelBase
local PANEL = {}

--- Adds a labeled numerical counter with buttons to increment and decrement the value for debugging
---@param x number
---@param y number
---@param labelText string
---@param startingValue number
---@param minValue number
---@param maxValue number
---@param incrementAmount number
---@param valueChangeCallback fun( newValue: number )
function PANEL:AddCounter( x, y, labelText, startingValue, minValue, maxValue, incrementAmount, valueChangeCallback )
    
    local key = "CounterValue" .. tostring( labelText )

    self[key] = startingValue

    local buttonWidth = 50
    local buttonHeight = 25

    local labelWidth = 65
    local labelHeight = buttonHeight

    local padding = 5

    local label = vgui.Create( "DLabel", self )
    local decreaseButton = vgui.Create( "DButton", self )
    local valueLabel = vgui.Create( "DLabel", self )
    local increaseButton = vgui.Create( "DButton", self )

    -- Label
    label:SetPos( x, y - labelHeight - padding )
    label:SetSize( labelWidth + buttonWidth * 2 + padding * 2, labelHeight )
    label:SetText( labelText )
    label:SetFont( "DermaLarge" )
    label:SetTextColor( Color( 255, 255, 255, 255 ) )
    label:SetContentAlignment( 5 )
    

    -- Decrease Button
    decreaseButton:SetText( "-" .. incrementAmount )
    decreaseButton:SetSize( buttonWidth, buttonHeight )
    decreaseButton:SetPos( x, y )
    decreaseButton.DoClick = function()
        self[key] = math.Clamp( self[key] - incrementAmount, minValue, maxValue )
        valueLabel:SetText(tostring( self[key] ) )
        valueChangeCallback( self[key] )
    end

    -- Radius Label
    valueLabel:SetPos( x + buttonWidth + padding, y )
    valueLabel:SetSize( labelWidth, labelHeight )
    valueLabel:SetText( tostring( self[key] ) )
    valueLabel:SetFont( "DermaLarge" )
    valueLabel:SetTextColor( Color( 255, 255, 255, 255 ) )
    valueLabel:SetContentAlignment( 5 )

    -- Increase Button
    increaseButton:SetText( "+" .. incrementAmount )
    increaseButton:SetSize( buttonWidth, buttonHeight )
    increaseButton:SetPos( x + buttonWidth + padding + labelWidth + padding, y )
    increaseButton.DoClick = function()
        self[key] = math.Clamp( self[key] + incrementAmount, minValue, maxValue )
        valueLabel:SetText( tostring( self[key] ) )
        valueChangeCallback( self[key] )
    end
end

local baseFont = "Roboto Regular"
local fontName = "CurveLib_TestFont"
function PANEL:RebuildFonts()
    surface.CreateFont( fontName, {
        font = baseFont,
        size = self.CurrentSize,
        weight = self.CurrentWeight,
        extended = true
    } )
end

function PANEL:Init()

    self.CurrentSize = 32
    self.CurrentWeight = 500
    self.CurrentRotation = 0
    self.CurrentScale = 1

    local fontLabel = vgui.Create( "DLabel", self )
    fontLabel:SetFont( "DermaLarge" )
    fontLabel:SetText( "Font: " .. baseFont )
    fontLabel:SetWide( 500 )
    fontLabel:SetTall( 70 )
    fontLabel:SetPos( 300, 0 )

    self:AddCounter( 15, 35, "Size", self.CurrentSize, 0, 9999, 4, function( value )
        self.CurrentSize = value
        self:RebuildFonts()
    end )

    self:AddCounter( 15, 135, "Weight", self.CurrentWeight, 300, 800, 25, function( value )
        self.CurrentWeight = value
        self:RebuildFonts()
    end )

    self:AddCounter( 15, 235, "Rotation", self.CurrentRotation, -360, 360, 15, function( value )
        self.CurrentRotation = value
        self:RebuildFonts()
    end )
    
    self:AddCounter( 15, 335, "Scale", self.CurrentScale, 0, 10, 0.25, function( value )
        self.CurrentScale = value
        self:RebuildFonts()
    end )

    self:RebuildFonts()
end

function PANEL:Paint( width, height )
    drawBase.StartPanel( self )

    -- Background
    drawBase.Rect( 0, 0, width, height, 0, Alignment.TopLeft, Color( 128, 128, 128 ) )

    local x = 750
    local y = 300

    local text = "Text 123456789.0"
    surface.SetFont( fontName )
    local textWidth = surface.GetTextSize( text )

    local lineSize = self.CurrentScale * textWidth/2

    drawBase.Line( x - lineSize, y, x + lineSize, y, 1, HorizontalAlignment.Center, Color( 255, 0, 0 ) )

    
    drawBase.Text( text, x, y, self.CurrentRotation, self.CurrentScale, Alignment.Center, Color( 255, 255, 255, 255 ) )

    drawBase.EndPanel()
end

vgui.Register( "CurveLib.Editor.TestingPanel", PANEL, "CurveLib.Editor.PanelBase" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )