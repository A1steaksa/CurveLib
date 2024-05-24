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

---@class CurveLib.Editor.Graph.Panel : CurveLib.Editor.PanelBase
local metatable = {
    Defaults = {
        Size = {
            Width = 450,
            Height = 450
        }
    }
}

---@class CurveLib.Editor.Graph.Panel : CurveLib.Editor.PanelBase
---@field Caches table
---@field MainHandles table<CurveLib.Editor.Graph.Handle.MainHandle>
---@field CurrentCurve CurveLib.Curve.Data
local PANEL = {
    MainHandles = {}
}
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

    --drawGraph.GraphExterior()

    drawGraph.AlignemntDebug()

    drawGraph.EndPanel()
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

--#region Coordinate Conversion

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

--#endregion Coordinate Conversion

--#region Curve Management

-- Modifies and corrects the position of a Main Handle so that it is within bounds and has its first and last points at the graph's horizontal extremes
---@param index integer The index of the Main Handle being modified
---@param x integer 
---@param y integer
---@return integer correctedX
---@return integer correctedY
function PANEL:CorrectMainHandlePos( index, x, y )
    local interiorX, interiorY, interiorWidth, interiorHeight = self:GetInteriorRect()

    ---@type CurveLib.Editor.Graph.Handle.MainHandle
    local mainHandle = self.MainHandles[ index ]

    local correctedX
    local correctedY

    -- First Main Handle stays on the left side
    if index == 1 then
        correctedX = interiorX - mainHandle.HalfWidth
    -- Last Main Handle stays on the right side
    elseif index == #self.MainHandles then
        correctedX = interiorX + interiorWidth - mainHandle.HalfWidth
    end

    -- All Main Points stay within the interior bounds
    correctedX = correctedX or math.Clamp( x, interiorX - mainHandle.HalfWidth, interiorX + interiorWidth - mainHandle.HalfWidth )
    correctedY = correctedY or math.Clamp( y, interiorY - mainHandle.HalfHeight, interiorY + interiorHeight - mainHandle.HalfHeight )

    return correctedX, correctedY
end

-- Removes all Main Points on this Graph
function PANEL:ClearPoints()
    local points = self.MainHandles
    for index = 1, #points do
        points[ index ]:Remove()
    end

    self.MainHandles = {}
end

-- Adds a given number of Main and Side Handles to the panel
-- Note: The first Main Handle will not have a Left Side Handle and the last Main Handle will not have a Right Side Handle
---@param count integer
function PANEL:PopulateHandles( count )

    -- Remove the previous Curve Data's Main Points
    self:ClearPoints()

    for index = 1, count do
        local mainHandle = vgui.Create( "CurveLib.Editor.Graph.Handle.MainHandle", self )

        local needsLeftHandle = index ~= 1
        local needsRightHandle = index ~= count

        if needsLeftHandle then
            local leftHandle = vgui.Create( "CurveLib.Editor.Graph.Handle.SideHandle", self )
            leftHandle.GraphPanel = self
            leftHandle.IsRightHandle = false
            leftHandle.MainHandle = mainHandle
            mainHandle.LeftHandle = leftHandle
        end

        if needsRightHandle then
            local rightHandle = vgui.Create( "CurveLib.Editor.Graph.Handle.SideHandle", self )
            rightHandle.GraphPanel = self
            rightHandle.IsRightHandle = true
            rightHandle.MainHandle = mainHandle
            mainHandle.RightHandle = rightHandle
        end

        mainHandle.Index = index
        self.MainHandles[ index ] = mainHandle
    end
end

-- Moves all handles, which are not being dragged, based on their position in the Curve Data being edited
function PANEL:PositionHandles()
    if not self.CurrentCurve then return end

    local points = self.CurrentCurve.Points

    for index = 1, #points do
        local mainHandle = self.MainHandles[ index ] --[[@as CurveLib.Editor.Graph.Handle.MainHandle]]
        local leftHandle = mainHandle.LeftHandle
        local rightHandle = mainHandle.RightHandle

        local point = points[ index ] --[[@as CurveLib.Curve.Point]]

        if not mainHandle.IsBeingDragged then
            local posX, posY = self:NormalToInterior( point.MainHandle.x, point.MainHandle.y )
            mainHandle:SetCenterPos( posX, posY )
        end

        if leftHandle and not leftHandle.IsBeingDragged then
            local posX, posY = self:NormalToInterior( point.LeftHandle.x, point.LeftHandle.y )
            leftHandle:SetCenterPos( posX, posY )
        end

        if rightHandle and not rightHandle.IsBeingDragged then
            local posX, posY = self:NormalToInterior( point.RightHandle.x, point.RightHandle.y )
            rightHandle:SetCenterPos( posX, posY )
        end
    end
end

---@param curve CurveLib.Curve.Data
function PANEL:EditCurve( curve )
    self.CurrentCurve = curve

    -- Each Curve Point in the Curve Data needs a corresponding Main Handle
    self:PopulateHandles( #curve.Points )

    -- Move all these new Main Points to the position of their corresponding Curve Point
    self:PositionHandles()
end

-- Called when a Main Handle is moved
---@param mainHandle CurveLib.Editor.Graph.Handle.MainHandle
---@param x integer The proposed new position's X coordinate
---@param y integer The proposed new position's Y coordinate
---@return integer x The X coordinate, with any adjustments made
---@return integer y The Y coordinate, with any adjustments made
function PANEL:OnMainHandleDragged( mainHandle, x, y )
    local correctedX, correctedY = self:CorrectMainHandlePos( mainHandle.Index, x, y )

    local newPointX, newPointY = self:PanelToNormal( correctedX + mainHandle.HalfWidth, correctedY + mainHandle.HalfHeight )

    ---@type CurveLib.Curve.Point
    local point = self.CurrentCurve.Points[ mainHandle.Index ]

    point.MainHandle.x = newPointX
    point.MainHandle.y = newPointY

    return correctedX, correctedY
end

-- Called when a Handle Point is moved
---@param sideHandle CurveLib.Editor.Graph.Handle.SideHandle
---@param x integer The proposed new position's X coordinate
---@param y integer The proposed new position's Y coordinate
---@return integer x The X coordinate, with any adjustments made
---@return integer y The Y coordinate, with any adjustments made
function PANEL:OnSideHandleDragged( sideHandle, x, y )

    -- TODO

    return x, y
end

--#endregion Curve Management

function PANEL:OnSizeChanged( width, height )
    self:ClearInteriorRectCache()
    self:PositionHandles()
end


vgui.Register( "CurveLib.Editor.Graph.Panel", PANEL, "CurveLib.Editor.PanelBase" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )