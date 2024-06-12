if not _G.CurveLib or not istable( _G.CurveLib ) then
    error( "Curve Lib did not initialize correctly" )
elseif _G.CurveLib.HandleDraw and not _G.CurveLib.IsDevelopment then
    return _G.CurveLib.HandleDraw
end

---@type CurveLib.Editor.DrawBase
local drawBase

---@type CurveLib.Editor.Utils
local curveUtils = include( "libraries/curvelib/editor/utils.lua" )

---@class CurveLib.Editor.Graph.Handle.Draw
---@field GraphStack Stack
local DRAW = {
    GraphStack = util.Stack()
}

--#region Handle Stack

-- An entry in the Handle Stack
---@class CurveLib.Editor.Graph.Handle.Draw.StackEntry
---@field Config CurveLib.Editor.Config.Graph
---@field Handle CurveLib.Editor.Graph.Handle.MainHandle|CurveLib.Editor.Graph.Handle.SideHandle
---@field x integer
---@field y integer
---@field Width integer
---@field Height integer

---@return CurveLib.Editor.Graph.Handle.Draw.StackEntry
function DRAW.PeekEntry()
    return DRAW.GraphStack:Top()
end

---@return CurveLib.Editor.Config.Graph
---@return CurveLib.Editor.Graph.Handle.MainHandle|CurveLib.Editor.Graph.Handle.SideHandle
---@return integer
---@return integer
---@return integer
---@return integer
function DRAW.UnpackEntry()
    local entry = DRAW.PeekEntry()
    return entry.Config, entry.Handle, entry.x, entry.y, entry.Width, entry.Height
end

---@param config CurveLib.Editor.Config.Graph The configuration for the Graph
---@param handle CurveLib.Editor.Graph.Handle.MainHandle|CurveLib.Editor.Graph.Handle.SideHandle|CurveLib.Editor.Graph.Handle.Base The Graph being drawn
---@param x integer The x position of the Graph within the panel
---@param y integer The y position of the Graph within the panel
---@param width integer The width of the Graph, in pixels
---@param height integer The height of the Graph, in pixels
function DRAW.StartPanel( config, handle, x, y, width, height )
    drawBase = _G.CurveLib.DrawBase or drawBase or include( "libraries/curvelib/editor/draw-base.lua" )

    x, y, width, height = curveUtils.MultiFloor( x, y, width, height )

    DRAW.GraphStack:Push(
        {
            Config = config,
            Handle = handle,
            x = x,
            y = y,
            Width = width,
            Height = height
        }
    )
    drawBase.StartPanel( handle )
end

---@return DPanel, CurveLib.Editor.Graph.Handle.Draw.StackEntry
function DRAW.EndPanel()
    local topPanel = drawBase.EndPanel()

    local topEntry = DRAW.PeekEntry()
    DRAW.GraphStack:Pop( 1 )

    return topPanel, topEntry
end

--#endregion Handle Stack


---@param handleConfig CurveLib.Editor.Config.Graph.Handles.Handle
function DRAW.Handle( handleConfig )
    local handle = DRAW.PeekEntry().Handle

    handle:UpdateVisuals( handleConfig )

    local graphX, graphY = handle.GraphPanel:LocalToScreen( 0, 0 )
    local interiorX, interiorY, interiorWidth, interiorHeight = handle.GraphPanel:GetInteriorRect()

    render.SetScissorRect( graphX + interiorX, graphY + interiorY, graphX + interiorX + interiorWidth, graphY + interiorY + interiorHeight, true )
    drawBase.StartPanel( handle )

    drawBase.Circle( handle.HalfWidth, handle.HalfHeight, handle.CurrentRadius, 45, 25, Alignment.Center, handle.CurrentColor )

    drawBase.EndPanel()
    render.SetScissorRect( 0, 0, 0, 0, false )
end


function DRAW.MainHandle()
    DRAW.Handle( DRAW.PeekEntry().Config.Handles.Main )
end


function DRAW.SideHandle()
    drawBase = _G.CurveLib.DrawBase or drawBase or include( "libraries/curvelib/editor/draw-base.lua" )

    local config, handle --[[@as CurveLib.Editor.Graph.Handle.SideHandle]], _, _, width, height = DRAW.UnpackEntry()

    drawBase.StartPanel( handle )

    DRAW.Handle( DRAW.PeekEntry().Config.Handles.Side )

    drawBase.EndPanel()
end


function DRAW.MainHandleLines()
    drawBase = _G.CurveLib.DrawBase or drawBase or include( "libraries/curvelib/editor/draw-base.lua" )

    local config, handle --[[@as CurveLib.Editor.Graph.Handle.MainHandle]] = DRAW.UnpackEntry()

    local lineColor = config.Handles.Line.Color
    local lineThickness = config.Handles.Line.Thickness

    -- Lines to handles
    if handle.LeftHandle then
        local leftX, leftY = handle.LeftHandle:GetPos()

        -- Drawing positions are relative to our position and need to be corrected
        leftX = leftX - handle.x + handle.LeftHandle.HalfWidth
        leftY = leftY - handle.y + handle.LeftHandle.HalfHeight

        drawBase.Line( handle.HalfWidth, handle.HalfHeight, leftX, leftY, lineThickness, HorizontalAlignment.Center, lineColor )
    end

    if handle.RightHandle then
        local rightX, rightY = handle.RightHandle:GetPos()

        -- Drawing positions are relative to our position and need to be corrected
        rightX = rightX - handle.x + handle.RightHandle.HalfWidth
        rightY = rightY - handle.y + handle.RightHandle.HalfHeight

        drawBase.Line( handle.HalfWidth, handle.HalfHeight, rightX, rightY, lineThickness, HorizontalAlignment.Center, lineColor )
    end
end

_G.CurveLib.HandleDraw = DRAW
return _G.CurveLib.HandleDraw