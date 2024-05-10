require( "vguihotload" )
if not _G.CurveLib or not istable( _G.CurveLib ) then
    error( "Curve Lib did not initialize correctly" )
elseif _G.CurveLib.IsDevelopment then
    vguihotload.HandleHotload( "CurveLib.EditorFrame" )
elseif _G.CurveLib.DrawGraph then return _G.CurveLib.DrawGraph end

---@type CurveEditor.CurveUtils
local curveUtils = include( "libraries/curvelib/utils.lua" )

---@type CurveEditor.DrawBasic
local drawBasic = include( "libraries/curvelib/draw-basic.lua" )

---@class CurveEditor.EditorGraph.DrawGraph
---@field ConfigStack Stack
local Draw = {
    ConfigStack = util.Stack()
}

--#region Editor Stack

---@return CurveEditor.EditorConfig.GraphConfig
function Draw.PeekConfig()
    return Draw.ConfigStack:Top()
end

---@param panel DPanel
---@param config CurveEditor.EditorConfig.GraphConfig
function Draw.StartPanel( panel, config )
    Draw.ConfigStack:Push( config )
    drawBasic.StartPanel( panel )
end

---@return DPanel, CurveEditor.EditorConfig.GraphConfig
function Draw.EndPanel()
    local topPanel = drawBasic.EndPanel()

    local topConfig = Draw.PeekConfig()
    Draw.ConfigStack:Pop( 1 )

    return topPanel, topConfig
end

--#endregion Editor Stack

-- Draws the currently pushed Editor Frame's Editor Graph
---@param x integer The x position of the graph
---@param y integer The y position of the graph
---@param width integer The width of the graph
---@param height integer The height of the graph
function Draw.Graph( x, y, width, height )
    x, y, width, height = curveUtils.MultiFloor( x, y, width, height )

    local config = Draw.PeekConfig()

    drawBasic.SimpleRect( x, y, width, height, config.BackgroundColor )


    local textX, textY = 500, 150
    surface.SetFont( config.Axes.Horizontal.Label.Font )
    surface.SetTextColor( config.Axes.Horizontal.Label.Color )
    drawBasic.Text( "Hello, World!", textX, textY, CurTime() * 100, math.Remap( math.sin( CurTime() * 3 ), -1, 1, 1, 5 ), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )

    local halfPointSize = 2
    drawBasic.SimpleRect( textX - halfPointSize, textY, halfPointSize * 2, halfPointSize * 2, Color( 255, 0, 0 ) )

    local cos = math.cos( CurTime() )
    local sin = math.sin( CurTime() )

    local center = Vector( x, y ) + Vector( math.floor( width / 2 ), math.floor( height / 2 ) )

    local xSize = width / 3
    local ySize = height / 8

    local startPos = center + Vector( cos * xSize, sin * ySize )
    local endPos = center + Vector( cos * -xSize, sin * -ySize )

    drawBasic.SimpleLine( startPos.x, startPos.y, endPos.x, endPos.y, 5, Color( 255, 255, 0, 255 ) )

    surface.SetFont( config.Axes.Horizontal.NumberLine.LargeTextFont )
    surface.SetTextColor( config.Axes.Horizontal.NumberLine.LargeTextColor )
    drawBasic.Text( "Big Text!", endPos.x, endPos.y, 0, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )

    surface.SetFont( config.Axes.Horizontal.NumberLine.SmallTextFont )
    surface.SetTextColor( config.Axes.Horizontal.NumberLine.SmallTextColor )
    drawBasic.Text( "Small Text!", startPos.x, startPos.y, 0, 1, TEXT_ALIGN_CENTER, TEXT_ALIGN_TOP )
end

_G.CurveLib.DrawGraph = Draw
return _G.CurveLib.DrawGraph