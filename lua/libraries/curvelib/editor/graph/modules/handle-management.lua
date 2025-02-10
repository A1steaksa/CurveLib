Log.StartSection( "Running HandleManagement module..." )

require( "vguihotload" )

---@class CurveLib.Editor.Graph.Panel
---@field MainHandles table<MainHandle> The Main Handles of the Graph
PANEL = PANEL

if not PANEL then
    vguihotload.HandleHotload( "CurveLib.Editor.Frame" )
    return
end

PANEL.MainHandles = {}

-- Removes all Main Handles on this Graph
function PANEL:ClearHandles()
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

-- Updates the graph to ensure that the Handles are populated and positioned correctly
function PANEL:UpdateHandles()
    if not self.CurrentCurve then return end

    self.SelectedHandles = {}

    -- Remove the previous Curve Data's Main Handles
    self:ClearHandles()

    -- Create new Main Handles
    self:PopulateHandles()

    -- Move all these new Main Handles to the position of their corresponding Curve Point
    self:PositionHandles()
end

-- Adds a given number of Main and Side Handles to the panel
-- Note: The first Main Handle will not have a Left Side Handle and the last Main Handle will not have a Right Side Handle
---@private
function PANEL:PopulateHandles()

    local count = #self.CurrentCurve.Points

    Log.StartSection( "Poopulating Handles" )

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

        Log.Print( index, " ", mainHandle )
        mainHandle.Index = index
        self.MainHandles[ index ] = mainHandle
    end

    Log.EndSection()
end

-- Moves all Handles, which are not being dragged, based on their position in the Curve Data being edited
---@private
function PANEL:PositionHandles()
    if not self.CurrentCurve then return end

    local points = self.CurrentCurve.Points

    for index, point in ipairs( points ) do
        local mainHandle = self.MainHandles[ index ] --[[@as MainHandle]]
        local leftHandle = mainHandle.LeftHandle
        local rightHandle = mainHandle.RightHandle

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
        if ( IsValid( selectedHandle ) ) then
            self:DeselectHandle( selectedHandle )
        end
    end

    self.SelectedHandles = {}
end

function PANEL:DeleteSelectedHandles()
    --TODO: Re-implement
end

Log.EndSection()