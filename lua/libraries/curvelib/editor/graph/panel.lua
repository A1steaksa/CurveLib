require( "vguihotload" )
---@type CurveLib.Editor.Graph.Draw
local drawGraph = include( "libraries/curvelib/editor/graph/draw.lua" )

---@type CurveLib.Editor.Utils
local curveUtils = include( "libraries/curvelib/editor/utils.lua" )

local colors = {
    NumberLineSmall = Color( 0, 0, 0 ),
    NumberLineLarge = Color( 0, 0, 0 ),
    Label           = Color( 0, 0, 0 ),
}

--#region Fonts

local fonts = {
    NumberLineSmall = "CurveLib_Graph_Small",
    NumberLineLarge = "CurveLib_Graph_Large",
    Label           = "CurveLib_Graph_Label",
}

surface.CreateFont( fonts.NumberLineSmall, {
	font = "Roboto",
	extended = false,
	size = 18,
	weight = 500
} )

surface.CreateFont( fonts.NumberLineLarge, {
	font = "Roboto",
	extended = false,
	size = 24,
	weight = 700
} )

surface.CreateFont( fonts.Label, {
	font = "Roboto",
	extended = false,
	size = 32,
	weight = 700
} )
--#endregion Fonts

---@class CurveLib.Editor.Graph.Panel : DPanel
local metatable = {
    Defaults = {
        Size = {
            Width = 450,
            height = 450
        }
    }
}

---@class CurveLib.Editor.Graph.Panel : DPanel
---@field Config CurveLib.Editor.Config.Graph
---@field Caches table
local PANEL = {}
PANEL.__index = metatable
setmetatable( PANEL, metatable )


---@param config CurveLib.Editor.Config.Graph
function PANEL:SetConfig( config )
    self.Config = config

    -- Horizontal Axis
    local horizontal = self.Config.Axes.Horizontal
    horizontal.EndMargin = 50

    horizontal.Label.Text = "Time"
    horizontal.Label.Rotation = 0
    horizontal.Label.Font = fonts.Label
    horizontal.Label.Color = colors.Label

    horizontal.NumberLine.LabelMargin    = 3
    horizontal.NumberLine.MaxNumberCount = 3
    horizontal.NumberLine.LargeTextFont  = fonts.NumberLineLarge
    horizontal.NumberLine.LargeTextColor = colors.NumberLineLarge
    horizontal.NumberLine.SmallTextFont  = fonts.NumberLineSmall
    horizontal.NumberLine.SmallTextColor = colors.NumberLineSmall

    -- Vertical Axis
    local vertical = self.Config.Axes.Vertical
    vertical.EndMargin = 50

    vertical.Label.Text = "Position"
    vertical.Label.Rotation = -30
    vertical.Label.Font = fonts.Label
    vertical.Label.Color = colors.Label

    vertical.NumberLine.LabelMargin    = 3
    vertical.NumberLine.MaxNumberCount = 3
    vertical.NumberLine.LargeTextFont  = fonts.NumberLineLarge
    vertical.NumberLine.LargeTextColor = colors.NumberLineLarge
    vertical.NumberLine.SmallTextFont  = fonts.NumberLineSmall
    vertical.NumberLine.SmallTextColor = colors.NumberLineSmall
end


function PANEL:Paint( width, height )
    drawGraph = _G.CurveLib.GraphDraw or drawGraph

    self.Config:ClearAllCaches()

    drawGraph.StartPanel( self.Config, self, 0, 0, width, height )

    drawGraph.GraphExterior()

    drawGraph.EndPanel()
end


---@param curve CurveLib.Curve.Data
function PANEL:EditCurve( curve )
    local graphWidth, graphHeight = self:GetWide(), self:GetTall()
    local config = self.Config

    local points = curve.Points
    for i = 1, #points do
        local point = points[ i ] --[[@as CurveLib.Curve.Point]]

        local mainPoint = vgui.Create( "CurveLib.Editor.Graph.Draggable.MainPoint", self )

        local interiorX, interiorY = self:NormalToInterior( point.MainPoint.x, point.MainPoint.y )

        mainPoint:SetPoint( point )
        mainPoint:SetCenterPos( interiorX, interiorY )
    end
end

function PANEL:ClearInteriorRectCache()
    self.Caches.InteriorRect = nil
end

-- Returns a rectangle that defines the position and dimensions of the Graph's interior plot
---@return integer x 
---@return integer y
---@return integer Width
---@return integer Height
function PANEL:GetInteriorRect()
    if not self.Caches.InteriorRect then
        local config = self.Config
        local horizontal = config.Axes.Horizontal
        local vertical = config.Axes.Vertical

        local _, horizontalLabelHeight = config:GetLabelSize( horizontal )
        local _, horizontalNumberLineHeight = config:GetNumberLineTextSize( horizontal.NumberLine )

        local verticalLabelWidth, _ = config:GetLabelSize( vertical )
        local verticalNumberLineWidth, _ = config:GetNumberLineTextSize( vertical.NumberLine )

        local interiorRect = {}
        interiorRect.x = vertical.Width
            + vertical.NumberLine.AxisMargin
            + verticalNumberLineWidth
            + vertical.NumberLine.LabelMargin
            + verticalLabelWidth
            + vertical.Label.EdgeMargin
        interiorRect.y = vertical.EndMargin

        interiorRect.Width = self:GetWide() - interiorRect.x - horizontal.EndMargin
        interiorRect.Height = self:GetTall()
            - horizontal.Width
            - horizontal.NumberLine.AxisMargin
            - horizontalNumberLineHeight
            - horizontal.NumberLine.LabelMargin
            - horizontalLabelHeight
            - horizontal.Label.EdgeMargin
            - horizontal.EndMargin

        self.Caches.InteriorRect = interiorRect
    end

    local rect = self.Caches.InteriorRect
    return rect.x, rect.y, rect.Width, rect.Height
end


-- Converts coordinates from a range of 0-1 (As they are stored in Curves) to the panel-relative coordinates of the Graph's Interior.
---@param x number The X coordinate in the range 0-1
---@param y number The Y coordinate in the range 0-1
function PANEL:NormalToInterior( x, y )
    local interiorX, interiorY, interiorWidth, interiorHeight = self:GetInteriorRect()
    return interiorX + ( x * interiorWidth ), interiorY + ( interiorHeight - y * interiorHeight )
end


-- Converts coordinates from the panel-relative coordinates of the Graph's Interior to a range of 0-1 (As they are stored in Curves)
---@param x number The X coordinate, relative to the Graph Panel
---@param y number The Y coordinate, relative to the Graph Panel
function PANEL:PanelToNormal( x, y )
    local interiorX, interiorY, interiorWidth, interiorHeight = self:GetInteriorRect()
    return ( x - interiorX ) / interiorWidth, 1 - ( y - interiorY ) / interiorHeight
end


-- Called when a Main Point is moved
---@param mainPoint CurveLib.Editor.Graph.Draggable.MainPoint
---@param x integer The proposed new position's X coordinate
---@param y integer The proposed new position's Y coordinate
---@return integer x The X coordinate, with any adjustments made
---@return integer y The Y coordinate, with any adjustments made
function PANEL:OnMainPointDragged( mainPoint, x, y )
    local interiorX, interiorY, interiorWidth, interiorHeight = self:GetInteriorRect()

    local draggableHalfWidth, draggableHalfHeight =  curveUtils.MultiFloor( mainPoint:GetWide() / 2, mainPoint:GetTall() / 2 )

    -- Ensure we don't drag outside of the Graph Interior
    local correctedX = math.Clamp( x, interiorX - draggableHalfWidth, interiorX + interiorWidth - draggableHalfWidth )
    local correctedY = math.Clamp( y, interiorY - draggableHalfHeight, interiorY + interiorHeight - draggableHalfHeight )

    local newPointX, newPointY = self:PanelToNormal( correctedX + draggableHalfWidth, correctedY + draggableHalfHeight)

    local point = mainPoint.Point.MainPoint
    point.x = newPointX
    point.y = newPointY

    return correctedX, correctedY
end

-- Called when a Handle Point is moved
---@param handlePoint CurveLib.Editor.Graph.Draggable.HandlePoint
---@param x integer The proposed new position's X coordinate
---@param y integer The proposed new position's Y coordinate
---@return integer x The X coordinate, with any adjustments made
---@return integer y The Y coordinate, with any adjustments made
function PANEL:OnHandlePointDragged( handlePoint, x, y )
    local interiorX, interiorY, interiorWidth, interiorHeight = self:GetInteriorRect()

    local draggableHalfWidth, draggableHalfHeight =  curveUtils.MultiFloor( handlePoint:GetWide() / 2, handlePoint:GetTall() / 2 )

    -- Ensure we don't drag outside of the Graph Interior
    local correctedX = math.Clamp( x, interiorX - draggableHalfWidth, interiorX + interiorWidth - draggableHalfWidth )
    local correctedY = math.Clamp( y, interiorY - draggableHalfHeight, interiorY + interiorHeight - draggableHalfHeight )

    local newPointX, newPointY = self:PanelToNormal( correctedX + draggableHalfWidth, correctedY + draggableHalfHeight)

    local point = handlePoint
    point.x = newPointX
    point.y = newPointY

    return correctedX, correctedY
end


function PANEL:OnSizeChanged( width, height )
    self:ClearInteriorRectCache()
end


vgui.Register( "CurveLib.Editor.Graph.Panel", PANEL, "CurveLib.Editor.PanelBase" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )