require( "vguihotload" )

---@type CurveLib.Editor.Graph.Draw
local drawGraph = include( "libraries/curvelib/editor/graph/draw.lua" )

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
	size = 45,
	weight = 800
} )
--#endregion Fonts

---@class CurveLib.Editor.Graph.Panel : CurveLib.Editor.PanelBase
---@field Caches table
---@field MainHandles table<CurveLib.Editor.Graph.Handle.MainHandle>
---@field CurrentCurve CurveLib.Curve.Data
local PANEL = {
    MainHandles = {}
}

-- For Colors used multiple times within the Graph
local colors = {
    Text = Color( 22, 66, 91 ),
    Borders = Color( 22, 66, 91 ),
    Axes = Color( 22, 66, 91 )
}

---@param config CurveLib.Editor.Config.Graph
function PANEL:SetConfig( config )
    self.Config = config

    config.BackgroundColor = Color( 217, 220, 214 )

    do -- Main Handles
        local handle = config.Handles.Main

        local idle = handle.Idle
        idle.Color = Color( 129, 195, 215, 255 )
        idle.ColorChangeRate = 500
        idle.Radius = 11
        idle.RadiusChangeRate = 50

        local hovered = handle.Hovered
        hovered.Color = Color( 129, 195, 215, 230 )
        hovered.ColorChangeRate = 500
        hovered.Radius = 10
        hovered.RadiusChangeRate = 50

        local dragged = handle.Dragged
        dragged.Color = Color( 129, 195, 215, 200 )
        dragged.ColorChangeRate = 500
        dragged.Radius = 9
        dragged.RadiusChangeRate = 50
    end

    do -- Side Handles
        local handle = config.Handles.Side

        local idle = handle.Idle
        idle.Color = Color( 6, 196, 239, 255 )
        idle.ColorChangeRate = 500
        idle.Radius = 8
        idle.RadiusChangeRate = 100

        local hovered = handle.Hovered
        hovered.Color = Color( 6, 196, 239, 230 )
        hovered.ColorChangeRate = 500
        hovered.Radius = 8
        hovered.RadiusChangeRate = 100

        local dragged = handle.Dragged
        dragged.Color = Color( 6, 196, 239, 200)
        dragged.ColorChangeRate = 1000
        dragged.Radius = 8
        dragged.RadiusChangeRate = 100
    end

    do -- Handle Lines
        local line = config.Handles.Line
        line.Color = Color( 22, 66, 91 )
        line.Thickness = 3
    end

    do -- Curve
        local curve = self.Config.Curve
        curve.Color = Color( 47, 102, 144 )
        curve.Thickness = 7
        curve.HoverSize = 10
        curve.VertexCount = 80
    end

    do -- Right Border
        local border = self.Config.Borders.Right
        border.Enabled = true
        border.Color = colors.Borders
        border.Thickness = 2
    end

    do -- Top Border
        local border = self.Config.Borders.Top
        border.Enabled = true
        border.Color = colors.Borders
        border.Thickness = 2
    end

    do -- Horizontal Axis
        local axis = self.Config.Axes.Horizontal
        axis.EndMargin = 50

        axis.Label.Text = "X"
        axis.Label.Rotation = 0
        axis.Label.Font = fonts.Label
        axis.Label.Color = colors.Axes
        axis.Label.EdgeMargin = 10

        axis.NumberLine.LabelMargin    = 3
        axis.NumberLine.MaxNumberCount = 3
        axis.NumberLine.StartingValue  = 0
        axis.NumberLine.EndingValue    = 1
        axis.NumberLine.LargeTextFont  = fonts.NumberLineLarge
        axis.NumberLine.LargeTextColor = colors.Text
        axis.NumberLine.SmallTextFont  = fonts.NumberLineSmall
        axis.NumberLine.SmallTextColor = colors.Text
    end

    do -- Vertical Axis
        local axis = self.Config.Axes.Vertical
        axis.EndMargin = 50

        axis.Label.Text = "Y"
        axis.Label.Rotation = 0
        axis.Label.Font = fonts.Label
        axis.Label.Color = colors.Axes
        axis.Label.EdgeMargin = 30

        axis.NumberLine.LabelMargin    = 25
        axis.NumberLine.MaxNumberCount = 3
        axis.NumberLine.StartingValue  = 0
        axis.NumberLine.EndingValue    = 1
        axis.NumberLine.LargeTextFont  = fonts.NumberLineLarge
        axis.NumberLine.LargeTextColor = colors.Text
        axis.NumberLine.SmallTextFont  = fonts.NumberLineSmall
        axis.NumberLine.SmallTextColor = colors.Text
    end
end


function PANEL:Paint( width, height )
    drawGraph = _G.CurveLib.GraphDraw or drawGraph

    local interiorX, interiorY, interiorWidth, interiorHeight = self:GetInteriorRect()
    local panelX, panelY = self:LocalToScreen( 0, 0 )

    local scissorX, scissorY = panelX + interiorX, panelY + interiorY

    self.Config:ClearAllCaches()

    drawGraph.StartPanel( self.Config, self, 0, 0, width, height )

    -- The axes and labels
    drawGraph.GraphExterior()

    -- The curve
    render.SetScissorRect( scissorX, scissorY, scissorX + interiorWidth, scissorY + interiorHeight, true )
    drawGraph.Curve( self.CurrentCurve )
    render.SetScissorRect( 0, 0, 0, 0, false )

    -- Most recently evaluated point
    drawGraph.RecentEvaluation( self.CurrentCurve )

    -- Hovering on the curve
    drawGraph.CurveHovering()

    drawGraph.EndPanel()
end


function PANEL:ClearInteriorRectCache()
    self.Caches.InteriorRect = nil
end


function PANEL:ClearMousePosOnCurveCache()
    self.Config.Caches.MousePosOnCurve = nil
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
        interiorRect.x = vertical.Thickness
            + vertical.NumberLine.AxisMargin
            + verticalNumberLineWidth
            + vertical.NumberLine.LabelMargin
            + verticalLabelWidth
            + vertical.Label.EdgeMargin
        interiorRect.y = vertical.EndMargin

        interiorRect.Width = self:GetWide() - interiorRect.x - horizontal.EndMargin
        interiorRect.Height = self:GetTall()
            - horizontal.Thickness
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


-- Finds where on the active curve curve is closest to a given point.  Results are cached each frame.
-- **Note:** This function will always return the closest point on the curve, even if it is not within the bounds of the curve.
---@param x integer The X coordinate, in panel-relative coordinates
---@param y integer The Y coordinate, in panel-relative coordinates
---@param checkCount? integer The number of points to check on the curve [Default: 400]
---@return number time The time value of the closest point on the curve
---@return number distance The distance between the point and the closest point on the curve
---@return integer x The X coordinate of the closest point on the curve, in panel-relative coordinates
---@return integer y The Y coordinate of the closest point on the curve, in panel-relative coordinates
function PANEL:GetClosestPointOnCurve( x, y, checkCount )
    local curve = self.CurrentCurve
    local lowestDistanceSquared = math.huge
    local closestTime = 0
    local closestX, closestY = 0, 0

    for i = 1, ( checkCount or 400 ) do
        local time = i / 400

        local point = curve:Evaluate( time, true )

        local pointX, pointY = self:NormalizedToInterior( point.x, point.y )

        local distanceSquared = math.pow( x - pointX, 2 ) + math.pow( y - pointY, 2 )

        if distanceSquared < lowestDistanceSquared then
            lowestDistanceSquared = distanceSquared
            closestTime = time
            closestX = pointX
            closestY = pointY
        end
    end

    return closestTime, math.sqrt( lowestDistanceSquared ), closestX, closestY
end


-- Returns whether the mouse is hovering over the active curve
---@return boolean isHovered Whether the mouse is hovering over the active curve
function PANEL:IsCurveHovered()
    local mouseX, mouseY = self:CursorPos()
    local _, distance = self:GetClosestPointOnCurve( mouseX, mouseY )

    return distance <= self.Config.Curve.HoverSize
end


-- Returns the position of the mouse on the active curve
---@return number time The time value of the closest point on the curve
---@return number distance The distance between the point and the closest point on the curve
---@return integer x The X coordinate of the closest point on the curve, in panel-relative coordinates
---@return integer y The Y coordinate of the closest point on the curve, in panel-relative coordinates
function PANEL:GetMousePosOnCurve()
    if not self.Config.Caches.MousePosOnCurve then
        local time, distance, x, y = self:GetClosestPointOnCurve( self:CursorPos() )
        self.Config.Caches.MousePosOnCurve = {
            Time = time,
            Distance = distance,
            X = x,
            Y = y
        }
    end

    local cache = self.Config.Caches.MousePosOnCurve
    return cache.Time, cache.Distance, cache.X, cache.Y
end

--#region Coordinate Conversion

-- Converts coordinates from a range of 0-1 (As they are stored in Curves) to the panel-relative coordinates of the Graph's Interior.
---@param x number The X coordinate in the range 0-1
---@param y number The Y coordinate in the range 0-1
function PANEL:NormalizedToInterior( x, y )
    local interiorX, interiorY, interiorWidth, interiorHeight = self:GetInteriorRect()
    return interiorX + ( x * interiorWidth ), interiorY + ( interiorHeight - y * interiorHeight )
end


-- Converts coordinates from the panel-relative coordinates of the Graph's Interior to a range of 0-1 (As they are stored in Curves)
---@param x number The X coordinate, relative to the Graph Panel
---@param y number The Y coordinate, relative to the Graph Panel
function PANEL:PanelToNormalized( x, y )
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

-- Modifies and corrects the position of a Side Handle so that it is within bounds
---@param index integer The index of the Main Handle being modified
---@param isRightHandle boolean Which of the Side Handles is being corrected
---@param x integer 
---@param y integer
---@return integer correctedX
---@return integer correctedY
function PANEL:CorrectSideHandlePos( index, isRightHandle, x, y )

    ---@type CurveLib.Editor.Graph.Handle.MainHandle
    local mainHandle = self.MainHandles[ index ]
    local sideHandle
    if isRightHandle then
        sideHandle = mainHandle.RightHandle
    else
        sideHandle = mainHandle.LeftHandle
    end

    -- Stay within the interior rect bounds
    local correctedX = math.Clamp( x, -sideHandle.HalfWidth, self:GetWide() - sideHandle.HalfWidth )
    local correctedY = math.Clamp( y, -sideHandle.HalfHeight, self:GetTall() - sideHandle.HalfHeight )

    return correctedX, correctedY
end

-- Removes all Main Points on this Graph
function PANEL:ClearPoints()
    local mainHandles = self.MainHandles
    for index = 1, #mainHandles do
        local mainHandle = mainHandles[ index ]
        if mainHandle.LeftHandle then
            mainHandle.LeftHandle:Remove()
        end
        if mainHandle.RightHandle then
            mainHandle.RightHandle:Remove()
        end
        mainHandle:Remove()
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
            leftHandle:MoveToAfter( mainHandle )
            mainHandle.LeftHandle = leftHandle
        end

        if needsRightHandle then
            local rightHandle = vgui.Create( "CurveLib.Editor.Graph.Handle.SideHandle", self )
            rightHandle.GraphPanel = self
            rightHandle.IsRightHandle = true
            rightHandle.MainHandle = mainHandle
            rightHandle:MoveToAfter( mainHandle )
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
            local posX, posY = self:NormalizedToInterior( point.MainHandle.x, point.MainHandle.y )
            mainHandle:SetCenterPos( posX, posY )
        end

        if leftHandle and not leftHandle.IsBeingDragged then
            local posX, posY = self:NormalizedToInterior( point.LeftHandle.x, point.LeftHandle.y )
            leftHandle:SetCenterPos( posX, posY )
        end

        if rightHandle and not rightHandle.IsBeingDragged then
            local posX, posY = self:NormalizedToInterior( point.RightHandle.x, point.RightHandle.y )
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
    ---@type CurveLib.Curve.Point
    local point = self.CurrentCurve.Points[ mainHandle.Index ]
    
    local correctedX, correctedY = self:CorrectMainHandlePos( mainHandle.Index, x, y )
    local correctedNormalX, correctedNormalY = self:PanelToNormalized( correctedX + mainHandle.HalfWidth, correctedY + mainHandle.HalfHeight )

    local oldX, oldY = mainHandle:GetX(), mainHandle:GetY()

    -- Move the Left Handle with the Main Handle
    if point.LeftHandle then
        local leftHandle = mainHandle.LeftHandle

        local newPosX, newPosY = leftHandle.x + (correctedX - oldX), leftHandle.y + ( correctedY - oldY )
        newPosX, newPosY = self:CorrectSideHandlePos( mainHandle.Index, false, newPosX, newPosY )

        -- Move the vgui element
        leftHandle.x = newPosX
        leftHandle.y = newPosY

        -- Update the Curve Data
        point.LeftHandle.x, point.LeftHandle.y = self:PanelToNormalized( newPosX + leftHandle.HalfWidth, newPosY + leftHandle.HalfHeight )
    end

    -- Move the Right Handle with the Main Handle
    if point.RightHandle then
        local rightHandle = mainHandle.RightHandle

        local newPosX, newPosY = rightHandle.x + (correctedX - oldX), rightHandle.y + ( correctedY - oldY )
        newPosX, newPosY = self:CorrectSideHandlePos( mainHandle.Index, true, newPosX, newPosY )

        -- Move the vgui element
        rightHandle.x = newPosX
        rightHandle.y = newPosY

        -- Update the Curve Data
        point.RightHandle.x, point.RightHandle.y = self:PanelToNormalized( newPosX + rightHandle.HalfWidth, newPosY + rightHandle.HalfHeight )
    end

    point.MainHandle.x = correctedNormalX
    point.MainHandle.y = correctedNormalY

    return correctedX, correctedY
end

-- Called when a Handle Point is moved
---@param sideHandle CurveLib.Editor.Graph.Handle.SideHandle
---@param x integer The proposed new position's X coordinate
---@param y integer The proposed new position's Y coordinate
---@return integer x The X coordinate, with any adjustments made
---@return integer y The Y coordinate, with any adjustments made
function PANEL:OnSideHandleDragged( sideHandle, x, y )

    local mainHandleIndex = sideHandle.MainHandle.Index

    local correctedX, correctedY = self:CorrectSideHandlePos( mainHandleIndex, sideHandle.IsRightHandle, x, y )

    local correctedNormalX, correctedNormalY = self:PanelToNormalized( correctedX + sideHandle.HalfWidth, correctedY + sideHandle.HalfHeight )

    ---@type CurveLib.Curve.Point
    local point = self.CurrentCurve.Points[ mainHandleIndex ]

    if sideHandle.IsRightHandle then
        point.RightHandle.x = correctedNormalX
        point.RightHandle.y = correctedNormalY
    else
        point.LeftHandle.x = correctedNormalX
        point.LeftHandle.y = correctedNormalY
    end

    return correctedX, correctedY
end

--#endregion Curve Management

function PANEL:OnSizeChanged( width, height )
    self:ClearInteriorRectCache()
    self:PositionHandles()
end

vgui.Register( "CurveLib.Editor.Graph.Panel", PANEL, "CurveLib.Editor.PanelBase" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )