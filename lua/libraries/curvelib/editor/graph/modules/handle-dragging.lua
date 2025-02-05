require( "vguihotload" )

---@type CurveLib.Editor.Utils
local curveUtils = include( "libraries/curvelib/editor/utils.lua" )

---@alias HandleDragData CurveLib.Editor.Graph.Panel.HandleDragData

-- Data about the current Handle drag operation
---@class CurveLib.Editor.Graph.Panel.HandleDragData
---@field BoundingX integer The X coordinate of the bounding box
---@field BoundingY integer The Y coordinate of the bounding box
---@field BoundingWidth integer The width of the bounding box
---@field BoundingHeight integer The height of the bounding box
---@field DragStartX integer The X coordinate of the mouse when the drag started
---@field DragStartY integer The Y coordinate of the mouse when the drag started

local HandleDragData = {}
HandleDragData.BoundingX = 0
HandleDragData.BoundingY = 0
HandleDragData.BoundingWidth = 0
HandleDragData.BoundingHeight = 0
HandleDragData.DragStartX = 0
HandleDragData.DragStartY = 0

---@class CurveLib.Editor.Graph.Panel
---@field IsDraggingHandles boolean Whether the user is currently dragging a Handle
---@field SiblingDistance number The distance between the currently-being-dragged Handle's sibling Handle and their Main Handle.  Used to maintain this distance when mirroring rotation.
---@field HandleDragData HandleDragData
PANEL = PANEL

if not PANEL then error( "Failed to load HandleDragging module of CurveLib.Editor.Graph.Panel" ) return end

PANEL.IsDraggingHandles = false
PANEL.SiblingDistance = 0
PANEL.HandleDragData = HandleDragData

-- Called when a Handle detects that it is being dragged
---@param handle BaseHandle | MainHandle | SideHandle
function PANEL:OnHandleDragStarted( handle )
    self.IsDraggingHandles = true

    if handle.IsMainHandle then

        -- You can only drag selected Handles, so if this Handle isn't selected, select it.
        if not handle:IsSelected() then
            local ctrl, shift, alt = self:GetModifierKeys()
            self:SelectHandle( handle, shift )
        end

        HandleDragData.BoundingX,
        HandleDragData.BoundingY,
        HandleDragData.BoundingWidth,
        HandleDragData.BoundingHeight = curveUtils.GetHandlesBoundingBox( self.SelectedHandles )

    elseif handle.IsSideHandle then
        local mainHandle = handle.MainHandle
        local siblingHandle = handle.SiblingHandle

        if siblingHandle then
            local mainHandleX, mainHandleY = self:PanelToNormalized( mainHandle:GetCenterPos() )
            local siblingHandleX, siblingHandleY = self:PanelToNormalized( siblingHandle:GetCenterPos() )

            self.SiblingDistance = math.sqrt( math.pow( siblingHandleX - mainHandleX, 2 ) + math.pow( siblingHandleY - mainHandleY, 2 ) )
        end
    end

end

-- Called when a Handle stops being dragged
---@param handle BaseHandle | MainHandle | CurveLib.Editor.Graph.Handle.SideHandle
---@param wasCanceled boolean? Whether the drag was canceled
function PANEL:OnHandleDragEnded( handle, wasCanceled )
    self.IsDraggingHandles = false
    self.SiblingDistance = nil
end

-- Called when a Main Handle is moved
---@param mainHandle MainHandle
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

    -- Correct the Side Handle's proposed position
    local correctedSideHandleX, correctedSideHandleY = self:CorrectSideHandlePos( sideHandle.MainHandle.Index, sideHandle.IsRightHandle, x, y )

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