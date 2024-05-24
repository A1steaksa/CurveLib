require( "vguihotload" )
if not _G.CurveLib or not istable( _G.CurveLib ) then
    error( "Curve Lib did not initialize correctly" )
end

---@type CurveLib.Editor.DrawBase
local drawBase

---@type CurveLib.Editor.Utils
local curveUtils = include( "libraries/curvelib/editor/utils.lua" )

---@class CurveLib.Editor.DrawBaseTests
local DRAW = {
    TestX = 500,
    TestY = 500,
    TestWidth = 200,
    TestHeight = 150,
    TestPadding = 150
}

local function DrawAlignmentTest( text, x, y, width, height, rotation, scale, alignment )

    local textColor = Color( 255, 255, 255 )
    local backgroundRectColor = Color( 100, 100, 100 )

    -- Background Rectangle
    drawBase.Rect( x, y, width, height, rotation, alignment, backgroundRectColor )

    -- Text 
    drawBase.Text( text, x, y, rotation, scale, alignment, textColor )
end

local function DrawAlignmentTestGrid()
    drawBase = _G.CurveLib.DrawBase

    -- Draw a red center line through every text's vertical and horizontal center
    surface.SetDrawColor( 255, 0, 0 )

    local centerX = DRAW.TestX
    local centerY = DRAW.TestY
    local testWidth = DRAW.TestWidth
    local testHeight = DRAW.TestHeight
    local padding = DRAW.TestPadding

    -- Top Row
    drawBase.Line( centerX - testWidth - padding, centerY - testHeight - padding, centerX + testWidth + padding, centerY - testHeight - padding, 1 )

    -- Center Row
    drawBase.Line( centerX - testWidth - padding, centerY, centerX + testWidth + padding, centerY, 1 )

    -- Bottom Row
    drawBase.Line( centerX - testWidth - padding, centerY + testHeight + padding, centerX + testWidth + padding, centerY + testHeight + padding, 1 )

    -- Left Column
    drawBase.Line( centerX - testWidth- padding, centerY - testHeight - padding, centerX - testWidth - padding, centerY + testHeight + padding, 1 )

    -- Center Column
    drawBase.Line( centerX, centerY - testHeight - padding, centerX, centerY + testHeight + padding, 1 )

    -- Right Column
    drawBase.Line( centerX + testWidth + padding, centerY - testHeight - padding, centerX + testWidth + padding, centerY + testHeight + padding, 1 )
end

function DRAW.RectTextAlignmentTest()
    drawBase = _G.CurveLib.DrawBase

    local text = "Hello, World!"
    surface.SetFont( "DermaDefault" )

    local centerX = DRAW.TestX
    local centerY = DRAW.TestY
    local testWidth = DRAW.TestWidth
    local testHeight = DRAW.TestHeight
    local padding = DRAW.TestPadding

    local textScale =  3 --math.Remap( math.sin( CurTime() * 2 ), -1, 1, 1, 3.5 )
    local rotation = 45 --( CurTime() * 30 ) % 360

    local textWidth, textHeight = surface.GetTextSize( text )
    textWidth = textWidth * textScale
    textHeight = textHeight * textScale

    do -- Top Left
        local x = centerX - testWidth - padding
        local y = centerY - testHeight - padding

        DrawAlignmentTest( text, x, y, textWidth, textHeight, rotation, textScale, Alignment.TopLeft )
    end

    do -- Top Center
        local x = centerX
        local y = centerY - testHeight - padding

        DrawAlignmentTest( text, x, y, textWidth, textHeight, rotation, textScale, Alignment.TopCenter )
    end

    
    do -- Top Right
        local x = centerX + testWidth + padding
        local y = centerY - testHeight - padding

        DrawAlignmentTest( text, x, y, textWidth, textHeight, rotation, textScale, Alignment.TopRight )
    end

    do -- Center Left
        local x = centerX - testWidth - padding
        local y = centerY

        DrawAlignmentTest( text, x, y, textWidth, textHeight, rotation, textScale, Alignment.CenterLeft )
    end

    do -- Center
        local x = centerX
        local y = centerY

        DrawAlignmentTest( text, x, y, textWidth, textHeight, rotation, textScale, Alignment.Center )
    end

    do -- Center Right
        local x = centerX + testWidth + padding
        local y = centerY

        DrawAlignmentTest( text, x, y, textWidth, textHeight, rotation, textScale, Alignment.CenterRight )
    end

    do -- Bottom Left
        local x = centerX - testWidth - padding
        local y = centerY + testHeight + padding

        DrawAlignmentTest( text, x, y, textWidth, textHeight, rotation, textScale, Alignment.BottomLeft )
    end

    do -- Bottom Center
        local x = centerX
        local y = centerY + testHeight + padding

        DrawAlignmentTest( text, x, y, textWidth, textHeight, rotation, textScale, Alignment.BottomCenter )
    end

    do -- Bottom Right
        local x = centerX + testWidth + padding
        local y = centerY + testHeight + padding

        DrawAlignmentTest( text, x, y, textWidth, textHeight, rotation, textScale, Alignment.BottomRight )
    end

    DrawAlignmentTestGrid()
end

function DRAW.LineAlignmentTest()
    drawBase = _G.CurveLib.DrawBase

    local alignment = HorizontalAlignment.Right

    local testX, testY = 100, 100

    local thickLineColor = Color( 255, 255, 255, 255 )
    local centerLineColor = Color( 255, 0, 0 )

    local lineSpacing = 30
    local lineLength = 150

    local minWidth = 1
    local maxWidth = 9

    -- Vertical Centered lines
    for i = minWidth, maxWidth do
        local startX = testX + ( i - 1 ) * lineSpacing
        local startY = testY

        local endX = startX
        local endY = testY + lineLength

        local lineWidth = i

        -- Thick line
        drawBase.Line( startX, startY, endX, endY, lineWidth, alignment, thickLineColor )


        -- Center line
        drawBase.Line( startX, startY, endX, endY, 1, alignment, centerLineColor )
    end

    -- Horizontal Centered Lines
    for i = minWidth, maxWidth do
        local startX = testX
        local startY = testY + lineLength + lineSpacing + ( i - 1 ) * lineSpacing

        local endX = testX + lineLength
        local endY = startY

        local lineWidth = i

        -- Thick line
        drawBase.Line( startX, startY, endX, endY, lineWidth, alignment, thickLineColor )

        -- Center line
        drawBase.Line( startX, startY, endX, endY, 1, alignment, centerLineColor )
    end

    -- Diagonal Centered Lines
    for i = minWidth, maxWidth do
        local startX = testX + lineSpacing * ( i - 1 )
        local startY = testY + ( lineLength + lineSpacing ) * 2.5

        local endX = testX + lineLength + lineSpacing * ( i - 1 )
        local endY = startY + lineLength

        local lineWidth = i

        -- Thick line
        drawBase.Line( startX, startY, endX, endY, lineWidth, alignment, thickLineColor )

        -- Center line
        drawBase.Line( startX, startY, endX, endY, 1, alignment, centerLineColor )
    end

end

vguihotload.HandleHotload( "CurveLib.Editor.Frame" )

return DRAW