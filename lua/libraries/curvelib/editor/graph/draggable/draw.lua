if not _G.CurveLib or not istable( _G.CurveLib ) then
    error( "Curve Lib did not initialize correctly" )
elseif _G.CurveLib.DraggableDraw and not _G.CurveLib.IsDevelopment then
    return _G.CurveLib.DraggableDraw
end

---@type CurveLib.Editor.Utils
local curveUtils = include( "libraries/curvelib/editor/utils.lua" )

---@class CurveLib.Editor.Graph.Draggable.Draw
---@field GraphStack Stack
local DRAW = {
    GraphStack = util.Stack()
}

--#region Draggable Stack

-- An entry in the Draggable Stack
---@class CurveLib.Editor.Graph.Draggable.Draw.StackEntry
---@field Config CurveLib.Editor.Config
---@field Draggable CurveLib.Editor.Graph.Draggable.Base
---@field x integer
---@field y integer
---@field Width integer
---@field Height integer

---@return CurveLib.Editor.Graph.Draggable.Draw.StackEntry
function DRAW.PeekEntry()
    return DRAW.GraphStack:Top()
end

function DRAW.UnpackEntry()
    local entry = DRAW.PeekEntry()
    return entry.Config, entry.Draggable, entry.x, entry.y, entry.Width, entry.Height
end

---@param config CurveLib.Editor.Config.Graph The configuration for the Graph
---@param graph CurveLib.Editor.Graph.Panel The Graph being drawn
---@param x integer The x position of the Graph within the panel
---@param y integer The y position of the Graph within the panel
---@param width integer The width of the Graph, in pixels
---@param height integer The height of the Graph, in pixels
function DRAW.StartPanel( config, graph, x, y, width, height )
    drawBasic = _G.CurveLib.DrawBase or drawBasic or include( "libraries/curvelib/editor/draw-base.lua" )

    x, y, width, height = curveUtils.MultiFloor( x, y, width, height )

    DRAW.GraphStack:Push(
        {
            Config = config,
            Graph = graph,
            x = x,
            y = y,
            Width = width,
            Height = height
        }
    )
    drawBasic.StartPanel( graph )
end

---@return DPanel, CurveLib.Editor.Graph.Draw.StackEntry
function DRAW.EndPanel()
    local topPanel = drawBasic.EndPanel()

    local topEntry = DRAW.PeekEntry()
    DRAW.GraphStack:Pop( 1 )

    return topPanel, topEntry
end

--#endregion Draggable Stack

_G.CurveLib.DraggableDraw = DRAW
return _G.CurveLib.DraggableDraw