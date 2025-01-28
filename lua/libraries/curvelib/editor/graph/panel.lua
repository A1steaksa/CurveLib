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
	font = "Roboto Regular",
	extended = true,
	size = 18,
	weight = 400,
    antialias = true
} )

surface.CreateFont( fonts.NumberLineLarge, {
	font = "Roboto Regular",
	extended = true,
	size = 20,
	weight = 400,
    antialias = true
} )

surface.CreateFont( fonts.Label, {
	font = "Roboto Regular",
	extended = true,
	size = 30,
	weight = 400,
    antialias = true
} )
--#endregion Fonts

-- For Colors used multiple times within the Graph
local colors = {
    Text = Color( 22, 66, 91 ),
    Borders = Color( 22, 66, 91 ),
    Axes = Color( 22, 66, 91 )
}

---@class CurveLib.Editor.Graph.Panel : CurveLib.Editor.PanelBase
---@field CurrentCurve CurveLib.Curve.Data The Curve currently being edited
---@field MainHandles table<CurveLib.Editor.Graph.Handle.MainHandle> The Main Handles of the Graph
---@field SelectedHandles table<CurveLib.Editor.Graph.Handle.MainHandle> The currently selected Main Handles
---@field HoveredHandle CurveLib.Editor.Graph.Handle.Base? The Handle currently being hovered over
---@field HeldKeys table<KEY|integer, boolean> The keyboard keys currently being held down
---@field HeldMouseButtons table<MOUSE|integer, boolean> The mouse buttons currently being held down
---@field Caches table A table of cached values to improve performance
---@field SiblingDistance number The distance between the currently-being-dragged Handle's sibling Handle and their Main Handle.  Used to maintain this distance when mirroring rotation.
---@field LeftMouseDownX integer The X coordinate of the cursor when the left mouse button was pressed
---@field LeftMouseDownY integer The Y coordinate of the cursor when the left mouse button was pressed
---@field RightMouseDownX integer The X coordinate of the cursor when the right mouse button was pressed
---@field RightMouseDownY integer The Y coordinate of the cursor when the right mouse button was pressed
---@field _IsRotationMirrored boolean Whether Side Handles should mirror each other's angle around the Main Handle when one is moved
---@field _IsDistanceMirrored boolean Whether Side Handles should mirror each other's distance from the Main Handle when one is moved
---@field IsDraggingHandle boolean Whether the user is currently dragging a Handle
---@field IsBoxSelecting boolean Whether the user is currently performing a box selection
local PANEL = {
    MainHandles = {},
    _IsRotationMirrored = false,
    _IsDistanceMirrored = false,
    IsDraggingHandle = false,
    IsBoxSelecting = false,
    SiblingDistance = 0,
    SelectedHandles = {},
    HoveredHandle = nil
}

function PANEL:Init()
    self:RequestFocus()
    self:SetKeyboardInputEnabled( true )
    self:SetMouseInputEnabled( true )

    hook.Add( "OnPauseMenuShow", self, self.HandleEscPressed )
end

function PANEL:PostConnectionInit()
    self:SetMirrorHandleDistance( true )
    self:SetMirrorHandleRotation( true )
end

---@param config CurveLib.Editor.Config.Graph
function PANEL:SetConfig( config )
    self.Config = config

    config.BackgroundColor = Color( 217, 220, 214 )

    do -- Main Handles
        local handle = config.Handles.Main

        local handleColor = Color( 129, 195, 215, 255 )
        local handleRadius = 10

        local idle = handle.Idle
        idle.Color = handleColor
        idle.ColorChangeRate = 500
        idle.Radius = handleRadius
        idle.RadiusChangeRate = 50

        local hovered = handle.Hovered
        hovered.Color = handleColor
        hovered.ColorChangeRate = 500
        hovered.Radius = handleRadius
        hovered.RadiusChangeRate = 50

        local dragged = handle.Dragged
        dragged.Color = handleColor
        dragged.ColorChangeRate = 500
        dragged.Radius = handleRadius
        dragged.RadiusChangeRate = 50
    end

    do -- Side Handles
        local handle = config.Handles.Side

        local handleColor = Color( 6, 196, 239, 255 )
        local handleRadius = 10

        local idle = handle.Idle
        idle.Color = handleColor
        idle.ColorChangeRate = 500
        idle.Radius = handleRadius
        idle.RadiusChangeRate = 100

        local hovered = handle.Hovered
        hovered.Color = handleColor
        hovered.ColorChangeRate = 500
        hovered.Radius = handleRadius
        hovered.RadiusChangeRate = 100

        local dragged = handle.Dragged
        dragged.Color = handleColor
        dragged.ColorChangeRate = 1000
        dragged.Radius = handleRadius
        dragged.RadiusChangeRate = 100
    end

    do -- Handle Lines
        local line = config.Handles.Line
        line.Color = Color( 35, 80, 91 )
        line.Thickness = 5
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
        border.Thickness = 0.75
    end

    do -- Top Border
        local border = self.Config.Borders.Top
        border.Enabled = true
        border.Color = colors.Borders
        border.Thickness = 0.75
    end

    do -- Horizontal Axis
        local axis = self.Config.Axes.Horizontal
        axis.EndMargin = 25
        axis.Thickness = 1

        axis.Label.Text = "X"
        axis.Label.Rotation = 0
        axis.Label.Font = fonts.Label
        axis.Label.Color = colors.Axes
        axis.Label.EdgeMargin = 3

        axis.NumberLine.LabelMargin    = 5
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
        axis.EndMargin = 25
        axis.Thickness = 1

        axis.Label.Text = "Y"
        axis.Label.Rotation = 0
        axis.Label.Font = fonts.Label
        axis.Label.Color = colors.Axes
        axis.Label.EdgeMargin = 10

        axis.NumberLine.LabelMargin    = 5
        axis.NumberLine.MaxNumberCount = 3
        axis.NumberLine.StartingValue  = 0
        axis.NumberLine.EndingValue    = 1
        axis.NumberLine.LargeTextFont  = fonts.NumberLineLarge
        axis.NumberLine.LargeTextColor = colors.Text
        axis.NumberLine.SmallTextFont  = fonts.NumberLineSmall
        axis.NumberLine.SmallTextColor = colors.Text
    end
end

---@param value boolean Whether Side Handles should mirror each other's angle around the Main Handle when one is moved
function PANEL:SetMirrorHandleRotation( value )
    self._IsRotationMirrored = value

    self:GetSidebar().MirrorRotationCheckbox:SetChecked( value )
end

---@param value boolean Whether Side Handles should mirror each other's distance from the Main Handle when one is moved
function PANEL:SetMirrorHandleDistance( value )
    self._IsDistanceMirrored = value

    self:GetSidebar().MirrorDistanceCheckbox:SetChecked( value )
end

---@return boolean # Whether Side Handles should mirror each other's angle around the Main Handle when one is moved
function PANEL:IsHandleRotationMirrored()
    return self._IsRotationMirrored
end

---@return boolean # Whether Side Handles should mirror each other's distance from the Main Handle when one is moved
function PANEL:IsHandleDistanceMirrored()
    return self._IsDistanceMirrored
end

function PANEL:Paint( width, height )
    drawGraph = _G.CurveLib.GraphDraw or drawGraph

    local config = self.Config

    local interiorX, interiorY, interiorWidth, interiorHeight = self:GetInteriorRect()
    local panelX, panelY = self:LocalToScreen( 0, 0 )

    local scissorX, scissorY = panelX + interiorX, panelY + interiorY

    config:ClearAllCaches()

    drawGraph.StartPanel( config, self, 0, 0, width, height )

    -- The axes and labels
    drawGraph.GraphExterior()

    if ( self.CurrentCurve ) then
        -- The curve
        render.SetScissorRect( scissorX, scissorY, scissorX + interiorWidth, scissorY + interiorHeight, true )
        drawGraph.Curve( self.CurrentCurve )
        render.SetScissorRect( 0, 0, 0, 0, false )

        -- Most recently evaluated point
        drawGraph.RecentEvaluation( self.CurrentCurve )

        -- Handles
        for _, mainHandle in ipairs( self.MainHandles ) do
            mainHandle:PaintManual()
            if mainHandle.LeftHandle then
                mainHandle.LeftHandle:PaintManual()
            end
            if mainHandle.RightHandle then
                mainHandle.RightHandle:PaintManual()
            end
        end

    end

    if ( self.IsBoxSelecting ) then
        local mouseX, mouseY = self:CursorPos()
        mouseX = math.Clamp( mouseX, 0, self:GetWide() )
        mouseY = math.Clamp( mouseY, 0, self:GetTall() )
        drawGraph.BoxSelection( self.LeftMouseDownX, self.LeftMouseDownY, mouseX, mouseY )
    end

    drawGraph.EndPanel()
end

function PANEL:Think()
    if self.HeldMouseButtons and self.HeldMouseButtons[ MOUSE_LEFT ] then
        -- If we don't know where the mouse was pressed, something has gone wrong
        if not self.LeftMouseDownX or not self.LeftMouseDownY then return end

        if self.IsDraggingHandle then return end

        if not self.IsBoxSelecting then
            local mouseX, mouseY = self:CursorPos()
            local distanceFromMouseDown = math.sqrt( math.pow( mouseX - self.LeftMouseDownX, 2 ) + math.pow( mouseY - self.LeftMouseDownY, 2 ) )

            if distanceFromMouseDown >= self.Config:GetDragDistanceThreshold() then
                self:OnBoxSelectionStarted()
            end
        end
    end

    if self.IsBoxSelecting then
        self:BoxSelectionThink()
    end
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
    if not self.CurrentCurve then return false end
    
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
function PANEL:GetCursorPosOnCurveAsTime()
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

-- Updates the graph to ensure that the handles are populated and positioned correctly
function PANEL:UpdateHandles()
    if not self.CurrentCurve then return end

    -- Each Curve Point in the Curve Data needs a corresponding Main Handle
    self:PopulateHandles()

    -- Move all these new Main Points to the position of their corresponding Curve Point
    self:PositionHandles()
end

-- Adds a given number of Main and Side Handles to the panel
-- Note: The first Main Handle will not have a Left Side Handle and the last Main Handle will not have a Right Side Handle
---@private
function PANEL:PopulateHandles()

    -- Remove the previous Curve Data's Main Points
    self:ClearPoints()

    local count = #self.CurrentCurve.Points

    for index = 1, count do
        local mainHandle = vgui.Create( "CurveLib.Editor.Graph.Handle.MainHandle", self )
        mainHandle:SetConfig( self.Config.Handles.Main )

        local needsLeftHandle = index ~= 1
        local needsRightHandle = index ~= count

        local leftHandle, rightHandle
        if needsLeftHandle then
            leftHandle = vgui.Create( "CurveLib.Editor.Graph.Handle.SideHandle", self )
            leftHandle:SetConfig( self.Config.Handles.Side )
            leftHandle.GraphPanel = self
            leftHandle.IsRightHandle = false
            leftHandle.MainHandle = mainHandle
            leftHandle:MoveToAfter( mainHandle )
            mainHandle.LeftHandle = leftHandle

            leftHandle:SetEnabled( false )
        end

        if needsRightHandle then
            rightHandle = vgui.Create( "CurveLib.Editor.Graph.Handle.SideHandle", self )
            rightHandle:SetConfig( self.Config.Handles.Side )
            rightHandle.GraphPanel = self
            rightHandle.IsRightHandle = true
            rightHandle.MainHandle = mainHandle
            rightHandle:MoveToAfter( mainHandle )
            mainHandle.RightHandle = rightHandle

            rightHandle:SetEnabled( false )
        end

        if leftHandle then
            leftHandle.SiblingHandle = rightHandle
            leftHandle.LeftHandle = leftHandle
            leftHandle.RightHandle = rightHandle
        end

        if rightHandle then
            rightHandle.SiblingHandle = leftHandle
            rightHandle.LeftHandle = leftHandle
            rightHandle.RightHandle = rightHandle
        end

        mainHandle.Index = index
        self.MainHandles[ index ] = mainHandle
    end
end

-- Moves all handles, which are not being dragged, based on their position in the Curve Data being edited
---@private
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

function PANEL:DeselectAllHandles()
    for selectedHandle in pairs( self.SelectedHandles ) do
        if ( selectedHandle and selectedHandle ~= NULL and IsValid( selectedHandle ) ) then
            self:OnHandleDeselected( selectedHandle )
        end
        self.SelectedHandles[ selectedHandle ] = nil
    end
end

function PANEL:DeleteSelectedHandles()
    local hadEdgeHandleSelected = false

    for handle, _ in pairs( self.SelectedHandles ) do
        ---@cast handle CurveLib.Editor.Graph.Handle.MainHandle
        if not handle then continue end

        -- Don't delete the first or last Main Handle
        if handle.Index == 1 or handle.Index == lastHandleIndex then
            hadEdgeHandleSelected = true
            continue
        end

        self.CurrentCurve:RemovePoint( handle.Index )
    end

    -- Communicate to the user why some Handles were not deleted
    if hadEdgeHandleSelected then
        notification.AddLegacy( "You cannot delete a curve's first or last point!", NOTIFY_ERROR, 5 )
    end

    self:UpdateHandles()
end

---@param curve CurveLib.Curve.Data
function PANEL:OpenCurve( curve )
    self.CurrentCurve = curve

    self:UpdateHandles()
end

function PANEL:CloseCurve()
    self.CurrentCurve = nil
    self:ClearPoints()
end

--#region Handle Events

-- Called when a Handle is selected
---@param handle CurveLib.Editor.Graph.Handle.Base
function PANEL:OnHandleSelected( handle )
    if not handle.IsMainHandle then return end

    local isMultiSelect = input.IsKeyDown( KEY_LSHIFT ) or input.IsKeyDown( KEY_RSHIFT )

    -- Deselect all other handles if not multi-selecting
    if not isMultiSelect then
        for selectedHandle in pairs( self.SelectedHandles ) do
            if ( selectedHandle and selectedHandle ~= NULL and IsValid( selectedHandle ) ) then
                self:OnHandleDeselected( selectedHandle )
            end
            self.SelectedHandles[ selectedHandle ] = nil
        end
    end

    handle:SetSelected( true )
    self.SelectedHandles[ handle ] = true

    if handle.LeftHandle then
        handle.LeftHandle:SetEnabled( true )
    end

    if handle.RightHandle then
        handle.RightHandle:SetEnabled( true )
    end
end

-- Called when a Handle is deselected
---@param handle CurveLib.Editor.Graph.Handle.Base
function PANEL:OnHandleDeselected( handle )
    if not handle.IsMainHandle then return end

    self.SelectedHandles[ handle ] = nil
    handle:SetSelected( false )

    if handle.LeftHandle then
        handle.LeftHandle:SetEnabled( false )
    end

    if handle.RightHandle then
        handle.RightHandle:SetEnabled( false )
    end
end

-- Called when a Handle starts being dragged
---@param handle CurveLib.Editor.Graph.Handle.Base | CurveLib.Editor.Graph.Handle.MainHandle | CurveLib.Editor.Graph.Handle.SideHandle
function PANEL:OnHandleDragStarted( handle )
    self.IsDraggingHandle = true

    if handle.IsMainHandle then
        self.HandleDragStartX, self.HandleDragStartY = handle:GetCenterPos()

        if not handle:IsSelected() then
            self:OnHandleSelected( handle )
        end
    end

    if handle.IsSideHandle then
        local mainHandle = handle.MainHandle
        local siblingHandle = handle.SiblingHandle

        if siblingHandle then
            local mainHandleX, mainHandleY = self:PanelToNormalized( mainHandle:GetCenterPos() )
            local siblingHandleX, siblingHandleY = self:PanelToNormalized( siblingHandle:GetCenterPos() )

            self.SiblingDistance = math.sqrt( math.pow( siblingHandleX - mainHandleX, 2 ) + math.pow( siblingHandleY - mainHandleY, 2 ) )
        else
            self.SiblingDistance = 0
        end
    end
end

-- Called when a Handle stops being dragged
---@param handle CurveLib.Editor.Graph.Handle.Base | CurveLib.Editor.Graph.Handle.MainHandle | CurveLib.Editor.Graph.Handle.SideHandle
---@param wasCanceled boolean? Whether the drag was canceled
function PANEL:OnHandleDragEnded( handle, wasCanceled )
    self.IsDraggingHandle = false
    self.HandleDragStartX = nil
    self.HandleDragStartY = nil
    self.SiblingDistance = 0
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
function PANEL:OnSideHandleDragged( sideHandle, x, y )
    local mainHandle = sideHandle.MainHandle
    local siblingHandle = sideHandle.SiblingHandle

    local isDistanceMirrored = self:IsHandleDistanceMirrored()
    local isRotationMirrored = self:IsHandleRotationMirrored()

    -- Correct the side handle's proposed position
    local correctedSideHandleX, correctedSideHandleY = self:CorrectSideHandlePos( sideHandle.MainHandle.Index, sideHandle.IsRightHandle, x, y )

    -- From here on, all calculations are done in normalized coordinates
    local sideHandleX, sideHandleY = self:PanelToNormalized( correctedSideHandleX + sideHandle.HalfWidth, correctedSideHandleY + sideHandle.HalfHeight )

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
            newSiblingDistance = self.SiblingDistance
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

-- Called when box selection begins
function PANEL:OnBoxSelectionStarted()
    self.IsBoxSelecting = true
    self:MouseCapture( true ) -- Capture the mouse so that the box selection can continue even if the cursor leaves the panel
end

-- Called each frame while box selection is active
function PANEL:BoxSelectionThink()

end

-- Called when box selection ends
---@param isCanceled boolean? True if the box selection was canceled prematurely rather than ending naturally. [Default: false] 
function PANEL:OnBoxSelectionEnded( isCanceled )
    self.IsBoxSelecting = false
    self:MouseCapture( false )

    if isCanceled then
        self.LeftMouseDownX = nil
        self.LeftMouseDownY = nil
    end
end

-- Called externally when a handle is hovered
---@param handle CurveLib.Editor.Graph.Handle.Base
function PANEL:OnHandleHoverStarted( handle )
    self.HoveredHandle = handle
end

-- Called externally when a handle no longer hovered
---@param handle CurveLib.Editor.Graph.Handle.Base
function PANEL:OnHandleHoverEnded( handle )
    self.HoveredHandle = nil
end

-- Called when the graph is clicked
---@param mouseButton MOUSE
function PANEL:OnMousePressed( mouseButton )
    self.HeldMouseButtons = self.HeldMouseButtons or {}

    if mouseButton == MOUSE_LEFT then
        self.LeftMouseDownX, self.LeftMouseDownY = self:CursorPos()
    elseif mouseButton == MOUSE_RIGHT then
        self.RightMouseDownX, self.RightMouseDownY = self:CursorPos()
    end

    self.HeldMouseButtons[ mouseButton ] = true
end

-- Called when the mouse is released
---@param mouseButton MOUSE
function PANEL:OnMouseReleased( mouseButton )
    self.HeldMouseButtons = self.HeldMouseButtons or {}

    local isLeftMouseDown = self.HeldMouseButtons[ MOUSE_LEFT ]
    if mouseButton == MOUSE_LEFT and isLeftMouseDown and self.LeftMouseDownX and self.LeftMouseDownY then
        local leftMouseUpX, leftMouseUpY = self:CursorPos()
        local dragDistance = math.sqrt( math.pow( leftMouseUpX - self.LeftMouseDownX, 2 ) + math.pow( leftMouseUpY - self.LeftMouseDownY, 2 ) )
        local wasClick = dragDistance < self.Config:GetDragDistanceThreshold()

        if wasClick then
            -- Add a new point to the curve
            if self:IsCurveHovered() then
                local time = self:GetCursorPosOnCurveAsTime()
                local pointIndex = self.CurrentCurve:AddPoint( time )
                self:UpdateHandles()

                self:OnHandleSelected( self.MainHandles[ pointIndex ] )
            else
                -- Clicking on the background deselects all handles
                self:DeselectAllHandles()
            end
        end

        if self.IsBoxSelecting then
            self:OnBoxSelectionEnded()
        end
    end

    self.HeldMouseButtons[ mouseButton ] = nil
    if mouseButton == MOUSE_LEFT then
        self.LeftMouseDownX = nil
        self.LeftMouseDownY = nil
    elseif mouseButton == MOUSE_RIGHT then
        self.RightMouseDownX = nil
        self.RightMouseDownY = nil
    end
end

---@param keycode KEY|integer
---@return boolean # True if the key is currently held down, false otherwise
function PANEL:IsKeyDown( keycode )
    return self.HeldKeys and self.HeldKeys[ keycode ]
end

-- The Esc key requires special handling
function PANEL:HandleEscPressed()
    if self:IsVisible() then
        self:OnKeyCodePressed( KEY_ESCAPE )

        -- Don't open the main menu if the editor is open
        return false
    end
end

-- Called when a key is pressed
---@param keycode KEY|integer
function PANEL:OnKeyCodePressed( keycode )
    self.HeldKeys = self.HeldKeys or {}

    local ctrl = self:IsKeyDown( KEY_LCONTROL ) or self:IsKeyDown( KEY_RCONTROL )
    local shift = self:IsKeyDown( KEY_LSHIFT ) or self:IsKeyDown( KEY_RSHIFT )
    local alt = self:IsKeyDown( KEY_LALT ) or self:IsKeyDown( KEY_RALT )

    -- ESC - Cancel ongoing actions
    if keycode == KEY_ESCAPE then
        -- If there are keys down, cancel them
        if table.Count( self.HeldKeys ) > 0 then
            self.HeldKeys = nil
        elseif self.IsBoxSelecting then
            self:OnBoxSelectionEnded( true )
        elseif self.SelectedHandles then
            self:DeselectAllHandles()
        end

        -- Never consider Esc to be a held key
        return
    end

    -- CTRL + N - Open a new curve
    if ctrl and keycode == KEY_N then
        self.EditorFrame:OpenNewCurve()
    end

    self.HeldKeys[ keycode ] = true
end

-- Called when a key is released
---@param keycode KEY|integer
function PANEL:OnKeyCodeReleased( keycode )
    if not self.HeldKeys then return end

    if ( keycode == KEY_DELETE or keycode == KEY_BACKSPACE ) then
        self:DeleteSelectedHandles()
    end

    self.HeldKeys[ keycode ] = nil
end

function PANEL:OnSizeChanged( width, height )
    self.Caches.InteriorRect = nil
    self:PositionHandles()
end

vgui.Register( "CurveLib.Editor.Graph.Panel", PANEL, "CurveLib.Editor.PanelBase" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )