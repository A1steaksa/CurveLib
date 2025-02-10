require( "vguihotload" )

---@type CurveLib.Editor.Utils
local curveUtils = include( "libraries/curvelib/editor/utils.lua" )

---@alias MainHandleDragData CurveLib.Editor.Graph.Panel.MainHandleDragData

-- Data about a drag operation containing potentially multiple Main Handles
---@class CurveLib.Editor.Graph.Panel.MainHandleDragData
---@field BoundingX integer The X coordinate of the bounding box containing the dragged Handles
---@field BoundingY integer The Y coordinate of the bounding box containing the dragged Handles
---@field BoundingWidth integer The width of the bounding box containing the dragged Handles
---@field BoundingHeight integer The height of the bounding box containing the dragged Handles
---@field DragStartX integer The X coordinate of the mouse inside the bounding box when the drag started
---@field DragStartY integer The Y coordinate of the mouse inside the bounding box when the drag started
local MainHandleDragData = {}
MainHandleDragData.BoundingX = 0
MainHandleDragData.BoundingY = 0
MainHandleDragData.BoundingWidth = 0
MainHandleDragData.BoundingHeight = 0
MainHandleDragData.DragStartX = 0
MainHandleDragData.DragStartY = 0
MainHandleDragData.DragEndX = 0
MainHandleDragData.DragEndY = 0

---@class CurveLib.Editor.Graph.Panel
---@field IsDraggingHandles boolean Whether the user is currently dragging the selected Handles.
---@field HandleUnderMouseDown? BaseHandle | MainHandle | SideHandle The Handle, if any, that the cursor was over when the left mouse button was pressed.
---@field MainHandleDragData MainHandleDragData
---@field SiblingDistance number The distance between the currently-being-dragged Handle's sibling Handle and their Main Handle.  Used to maintain this distance when mirroring rotation.
PANEL = PANEL

if not PANEL then
    vguihotload.HandleMultipartPanelHotload( "CurveLib.Editor.Graph.Panel" )
    return
end

PANEL.IsDraggingHandles = false
PANEL.SiblingDistance = 0
PANEL.MainHandleDragData = MainHandleDragData

-- Called when a Handle detects that the mouse has been pressed over it
---@param handle BaseHandle | MainHandle | SideHandle The Handle that was pressed
---@param mouseCode MOUSE | integer The mouse button that was pressed
function PANEL:OnHandleMousePressed( handle, mouseCode )
    self:MouseCapture( true )
    self.HandleUnderMouseDown = handle
    self:OnMousePressed( mouseCode )
end

function PANEL:HandleDragThink()
    -- Check if we've moved the mouse enough to count as a drag
    if not self.IsDraggingHandles then
        local mouseX, mouseY = self:CursorPos()
        local dragDistance = math.sqrt( math.pow( mouseX - self.LeftMouseDownX, 2 ) + math.pow( mouseY - self.LeftMouseDownY, 2 ) )

        if dragDistance < self.Config:GetDragDistanceThreshold() then return end

        self:StartHandleDragging()
    end

    if self.HandleUnderMouseDown.IsMainHandle then
        self:UpdateDraggedMainHandles()
    elseif self.HandleUnderMouseDown.IsSideHandle then
        self:UpdateDraggedSideHandle()
    end
end

-- Starts the Handle drag operation
function PANEL:StartHandleDragging()
    self.IsDraggingHandles = true

    if self.HandleUnderMouseDown.IsMainHandle then
        -- Tell our selected Handles that we're dragging them
        for handle, _ in pairs( self.SelectedHandles ) do
            handle.IsBeingDragged = true
        end

        MainHandleDragData.DragStartX = self.LeftMouseDownX
        MainHandleDragData.DragStartY = self.LeftMouseDownY

        MainHandleDragData.BoundingX,
        MainHandleDragData.BoundingY,
        MainHandleDragData.BoundingWidth,
        MainHandleDragData.BoundingHeight = curveUtils.GetHandlesBoundingBox( self.SelectedHandles )

    elseif self.HandleUnderMouseDown.IsSideHandle then
        -- Calculate how far from the Main Handle our sibling Side Handle is, if we have one
        -- This will later be used to position our sibling if rotation is being mirrored
        local siblingHandle = self.HandleUnderMouseDown.SiblingHandle
        if siblingHandle then
            local mainHandleX, mainHandleY = self:PanelToNormalized( self.HandleUnderMouseDown.MainHandle:GetCenterPos() )
            local siblingHandleX, siblingHandleY = self:PanelToNormalized( siblingHandle:GetCenterPos() )

            self.SiblingDistance = math.sqrt( math.pow( siblingHandleX - mainHandleX, 2 ) + math.pow( siblingHandleY - mainHandleY, 2 ) )
        end
    end
end

function PANEL:UpdateDraggedMainHandles()
    local dragData = self.MainHandleDragData
    local mouseX, mouseY = self:CursorPos()

    -- The area the bounding box can move within
    local interiorLeftX, interiorTopY, interiorWidth, interiorHeight = self:GetInteriorRect()
    local interiorRightX = interiorLeftX + interiorWidth
    local interiorBottomY = interiorTopY + interiorHeight

    -- Where the drag started, relative to the top-left corner of the bounding box
    local cursorDistanceToBoundingLeftX = dragData.DragStartX - dragData.BoundingX
    local cursorDistanceToBoundingTopY = dragData.DragStartY - dragData.BoundingY
    local cursorDistanceToBoundingRightX = dragData.BoundingWidth - cursorDistanceToBoundingLeftX
    local cursorDistanceToBoundingBottomY = dragData.BoundingHeight - cursorDistanceToBoundingTopY

    -- Constrain the X position
    dragData.DragEndX = math.Clamp( mouseX,
        interiorLeftX + cursorDistanceToBoundingLeftX,
        interiorRightX - cursorDistanceToBoundingRightX
    )

    -- Constrain the Y position
    dragData.DragEndY = math.Clamp( mouseY,
        interiorTopY + cursorDistanceToBoundingTopY,
        interiorBottomY - cursorDistanceToBoundingBottomY
    )
end

function PANEL:UpdateDraggedSideHandle()
    local mouseX, mouseY = self:CursorPos()

    local sideHandle = self.HandleUnderMouseDown
    ---@cast sideHandle SideHandle

    local mainHandle = sideHandle.MainHandle
    local siblingHandle = sideHandle.SiblingHandle

    local isDistanceMirrored = self:IsHandleDistanceMirrored()
    local isRotationMirrored = self:IsHandleRotationMirrored()

    -- Correct the Side Handle's proposed position
    local correctedSideHandleX, correctedSideHandleY = self:CorrectSideHandlePos( sideHandle.MainHandle.Index, sideHandle.IsRightHandle, mouseX, mouseY )

    -- From here on, all calculations are done in normalized coordinates
    local sideHandleX, sideHandleY = self:PanelToNormalized( correctedSideHandleX + sideHandle.HalfWidth, correctedSideHandleY + sideHandle.HalfHeight )

    -- Update the Curve Data with the Side Handle's new normalized coordinates    
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

        -- The sibling's position is created from an angle and distance from the Main Hhandle

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

        -- Update the Curve Data with the sibling Handle's new normalized coordinates
        local siblingPoint = sideHandle.IsRightHandle and point.LeftPoint or point.RightPoint
        siblingPoint.x = newSiblingX
        siblingPoint.y = newSiblingY
    end

    self:PositionHandles()

    return correctedSideHandleX, correctedSideHandleY
end

-- Modifies and corrects the position of a Main Handle so that it is within bounds and has its first and last points at the graph's horizontal extremes
---@param index integer The index of the Main Handle being modified
---@param x integer 
---@param y integer
---@return integer correctedX
---@return integer correctedY
function PANEL:CorrectMainHandlePos( index, x, y )
    local interiorX, interiorY, interiorWidth, interiorHeight = self:GetInteriorRect()

    ---@type MainHandle
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

    -- All Main Handles stay within the interior bounds
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

    ---@type MainHandle
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