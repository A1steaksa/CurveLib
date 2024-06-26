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

-- The current state of the Graph's editor
---@class CurveLib.Editor.Graph.State
---@field IsRotationMirrored boolean Whether Side Handles should mirror each other's angle around the Main Handle when one is moved
---@field IsDistanceMirrored boolean Whether Side Handles should mirror each other's distance from the Main Handle when one is moved
---@field IsDragging boolean Whether the user is currently dragging a Handle
---@field SiblingDistance number The distance between the dragged Handle's sibling Handle and their Main Handle


---@class CurveLib.Editor.Graph.Panel : CurveLib.Editor.PanelBase
---@field Caches table
---@field State CurveLib.Editor.Graph.State
---@field MainHandles table<CurveLib.Editor.Graph.Handle.MainHandle>
---@field CurrentCurve CurveLib.Curve.Data
local PANEL = {
    MainHandles = {},
    State = {
        IsRotationMirrored = false,
        IsDistanceMirrored = false,
        IsDragging = false,
        SiblingDistance = 0
    },
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

    local config = self.Config
    local state = self.State

    local interiorX, interiorY, interiorWidth, interiorHeight = self:GetInteriorRect()
    local panelX, panelY = self:LocalToScreen( 0, 0 )

    local scissorX, scissorY = panelX + interiorX, panelY + interiorY

    config:ClearAllCaches()

    drawGraph.StartPanel( config, self, 0, 0, width, height )

    -- The axes and labels
    drawGraph.GraphExterior()

    -- The curve
    render.SetScissorRect( scissorX, scissorY, scissorX + interiorWidth, scissorY + interiorHeight, true )
    drawGraph.Curve( self.CurrentCurve )
    render.SetScissorRect( 0, 0, 0, 0, false )

    -- Most recently evaluated point
    drawGraph.RecentEvaluation( self.CurrentCurve )

    -- Curve Hovering
    if not state.IsDragging and self:IsCurveHovered() then
        local isHandleHovered = self:IsChildHovered( true )
        if not isHandleHovered then
            drawGraph.CurveHovering()
        end
    end

    drawGraph.EndPanel()
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

--#region Curve Hovering

-- Returns whether the mouse is hovering over the active curve
---@return boolean isHovered Whether the mouse is hovering over the active curve
function PANEL:IsCurveHovered()
    local mouseX, mouseY = self:CursorPos()
    local _, distance = self:GetClosestPointOnCurve( mouseX, mouseY )

    return distance <= self.Config.Curve.HoverSize
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

--#endregion Curve Hovering

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

    -- First and last Main Handles need to stay at the horizontal extremes
    local correctedX, correctedY
    if index == 1 then
        -- First Main Handle needs to stay at x = 0 (normalized)
        correctedX = interiorX - mainHandle.HalfWidth
    elseif index == #self.MainHandles then
        -- Last Main Handle needs to stay at x = 1 (normalized)
        correctedX = interiorX + interiorWidth - mainHandle.HalfWidth
    end

    -- All Main Points stay within the interior bounds
    correctedX = correctedX or math.Clamp( x, interiorX - mainHandle.HalfWidth, interiorX + interiorWidth - mainHandle.HalfWidth )
    correctedY = math.Clamp( y, interiorY - mainHandle.HalfHeight, interiorY + interiorHeight - mainHandle.HalfHeight )

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

        local leftHandle, rightHandle
        if needsLeftHandle then
            leftHandle = vgui.Create( "CurveLib.Editor.Graph.Handle.SideHandle", self )
            leftHandle.GraphPanel = self
            leftHandle.IsRightHandle = false
            leftHandle.MainHandle = mainHandle
            leftHandle:MoveToAfter( mainHandle )
            mainHandle.LeftHandle = leftHandle
        end

        if needsRightHandle then
            rightHandle = vgui.Create( "CurveLib.Editor.Graph.Handle.SideHandle", self )
            rightHandle.GraphPanel = self
            rightHandle.IsRightHandle = true
            rightHandle.MainHandle = mainHandle
            rightHandle:MoveToAfter( mainHandle )
            mainHandle.RightHandle = rightHandle
        end

        if leftHandle then
            leftHandle.SiblingHandle = rightHandle
        end

        if rightHandle then
            rightHandle.SiblingHandle = leftHandle
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
            local posX, posY = self:NormalizedToInterior( point.MainPoint.x, point.MainPoint.y )
            mainHandle:SetCenterPos( posX, posY )
        end

        if leftHandle and not leftHandle.IsBeingDragged then
            local posX, posY = self:NormalizedToInterior( point.LeftPoint.x, point.LeftPoint.y )
            leftHandle:SetCenterPos( posX, posY )
        end

        if rightHandle and not rightHandle.IsBeingDragged then
            local posX, posY = self:NormalizedToInterior( point.RightPoint.x, point.RightPoint.y )
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

--#region Handle Events

-- Called when a Handle starts being dragged
---@param handle CurveLib.Editor.Graph.Handle.Base | CurveLib.Editor.Graph.Handle.MainHandle | CurveLib.Editor.Graph.Handle.SideHandle
function PANEL:OnDragStarted( handle )
    self.State.IsDragging = true

    if handle.IsSideHandle then
        local mainHandle = handle.MainHandle
        local siblingHandle = handle.SiblingHandle

        if siblingHandle then
            local mainHandleX, mainHandleY = self:PanelToNormalized( mainHandle:GetCenterPos() )
            local siblingHandleX, siblingHandleY = self:PanelToNormalized( siblingHandle:GetCenterPos() )
    
            self.State.SiblingDistance = math.sqrt( math.pow( siblingHandleX - mainHandleX, 2 ) + math.pow( siblingHandleY - mainHandleY, 2 ) )
        else
            self.State.SiblingDistance = 0
        end
    end

end


-- Called when a Handle stops being dragged
---@param handle CurveLib.Editor.Graph.Handle.Base | CurveLib.Editor.Graph.Handle.MainHandle | CurveLib.Editor.Graph.Handle.SideHandle
function PANEL:OnDragEnded( handle )
    self.State.IsDragging = false
    self.State.SiblingDistance = 0
end


-- Called when a Main Handle is moved
---@param mainHandle CurveLib.Editor.Graph.Handle.MainHandle
---@return integer x The X coordinate, with any adjustments made
---@return integer y The Y coordinate, with any adjustments made
function PANEL:OnMainHandleDragged( mainHandle, x, y)
    ---@type CurveLib.Curve.Point
    local point = self.CurrentCurve.Points[ mainHandle.Index ]

    local correctedX, correctedY = self:CorrectMainHandlePos( mainHandle.Index, x, y )
    local correctedNormalX, correctedNormalY = self:PanelToNormalized( correctedX + mainHandle.HalfWidth, correctedY + mainHandle.HalfHeight )

    local oldX, oldY = mainHandle:GetX(), mainHandle:GetY()

    -- Move the Left Handle with the Main Handle
    if point.LeftPoint then
        local leftHandle = mainHandle.LeftHandle

        local newPosX, newPosY = leftHandle.x + (correctedX - oldX), leftHandle.y + ( correctedY - oldY )
        newPosX, newPosY = self:CorrectSideHandlePos( mainHandle.Index, false, newPosX, newPosY )

        -- Move the vgui element
        leftHandle.x = newPosX
        leftHandle.y = newPosY

        -- Update the Curve Data
        point.LeftPoint.x, point.LeftPoint.y = self:PanelToNormalized( newPosX + leftHandle.HalfWidth, newPosY + leftHandle.HalfHeight )
    end

    -- Move the Right Handle with the Main Handle
    if point.RightPoint then
        local rightHandle = mainHandle.RightHandle

        local newPosX, newPosY = rightHandle.x + (correctedX - oldX), rightHandle.y + ( correctedY - oldY )
        newPosX, newPosY = self:CorrectSideHandlePos( mainHandle.Index, true, newPosX, newPosY )

        -- Move the vgui element
        rightHandle.x = newPosX
        rightHandle.y = newPosY

        -- Update the Curve Data
        point.RightPoint.x, point.RightPoint.y = self:PanelToNormalized( newPosX + rightHandle.HalfWidth, newPosY + rightHandle.HalfHeight )
    end

    point.MainPoint.x = correctedNormalX
    point.MainPoint.y = correctedNormalY

    return correctedX, correctedY
end


-- Called when a Handle Point is moved
---@param sideHandle CurveLib.Editor.Graph.Handle.SideHandle
---@return integer x The X coordinate, with any adjustments made
---@return integer y The Y coordinate, with any adjustments made
function PANEL:OnSideHandleDragged( sideHandle, x, y)
    local mainHandle = sideHandle.MainHandle
    local siblingHandle = sideHandle.SiblingHandle

    local isDistanceMirrored = self.State.IsDistanceMirrored
    local isRotationMirrored = self.State.IsRotationMirrored

    -- Correct the side handle's proposed position
    local correctedSideHandleX, correctedSideHandleY = self:CorrectSideHandlePos( sideHandle.MainHandle.Index, sideHandle.IsRightHandle, x, y )

    -- From here on, all calculations are done in normalized coordinates
    local sideHandleX, sideHandleY = self:PanelToNormalized( correctedSideHandleX, correctedSideHandleY )

    -- Update the Curve Data with the side handle's new normalized coordinates    
    local point = self.CurrentCurve.Points[ mainHandle.Index ]
    local sidePoint = sideHandle.IsRightHandle and point.RightPoint or point.LeftPoint
    sidePoint.x = sideHandleX
    sidePoint.y = sideHandleY

    -- If there is a sibling that needs to be mirrored
    if siblingHandle and ( isDistanceMirrored or isRotationMirrored ) then
        local mainHandleX, mainHandleY = self:PanelToNormalized( mainHandle:GetCenterPos() )
        local siblingHandleX, siblingHandleY = self:PanelToNormalized( siblingHandle:GetCenterPos() )

        local mainToSideX = sideHandleX - mainHandleX
        local mainToSideY = sideHandleY - mainHandleY

        -- The sibling's position is created from an angle and distance from the main handle

        local newSiblingAngle
        if isRotationMirrored then
            newSiblingAngle = math.atan2( mainToSideY, mainToSideX ) + math.pi
        else
            newSiblingAngle = math.atan2( siblingHandleY - mainHandleY, siblingHandleX - mainHandleX )
        end

        local newSiblingDistance
        if isDistanceMirrored then
            newSiblingDistance = math.sqrt( math.pow( mainToSideX, 2 ) + math.pow( mainToSideY, 2 ) )
        else
            newSiblingDistance = self.State.SiblingDistance
        end

        local newSiblingX = mainHandleX + math.cos( newSiblingAngle ) * newSiblingDistance
        local newSiblingY = mainHandleY + math.sin( newSiblingAngle ) * newSiblingDistance

        -- Update the Curve Data with the sibling handle's new normalized coordinates
        local siblingPoint = sideHandle.IsRightHandle and point.LeftPoint or point.RightPoint
        siblingPoint.x = newSiblingX
        siblingPoint.y = newSiblingY
    end

    self:PositionHandles()

    return correctedSideHandleX, correctedSideHandleY
end

function PANEL:OnSizeChanged( width, height )
    self.Caches.InteriorRect = nil
    self:PositionHandles()
end

vgui.Register( "CurveLib.Editor.Graph.Panel", PANEL, "CurveLib.Editor.PanelBase" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )