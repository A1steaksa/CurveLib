require( "vguihotload" )
local circles = include( "includes/circles/circles.lua" )

-- Holds Color information about a Draggable
---@class (exact) CurveEditor.CurveDraggableBase.Colors
---@field Idle Color The color of this Draggable when it is not being interacted with.
---@field Hovered Color The color of this Draggable when the mouse is hovering over it.
---@field Pressed Color The color of this Draggable when it is being clicked and dragged.
---@field Dragged Color The color of this Draggable when it is being dragged.

-- Holds information about the visuals of a Draggable.
---@class (exact) CurveEditor.CurveDraggableBase.VisualSettings
---@field Circle Circle The Circle that represents this draggable.
---@field Radius number The radius of this draggable's Circle, in pixels.
---@field VertexDistance number How far apart each of the vertices of this Draggable's Circle are, in pixels.
---@field Colors CurveEditor.CurveDraggableBase.Colors The colors of this Draggable.

-- Holds information about a digital input like Keyboard keys or mouse buttons.
---@class (exact) CurveEditor.CurveDraggableBase.InputData
---@field KeyCode integer What KeyCode this InputInfo represents.
---@field PressTime number When this input was last pressed, in terms of CurTime.
---@field ReleaseTime number When this input was last released, in terms of CurTime.
---@field IsPressed boolean If this input is currently held down on this Draggable.

-- Holds information about a mouse button.
---@class (exact) CurveEditor.CurveDraggableBase.MouseButtonData : CurveEditor.CurveDraggableBase.InputData
---@field ClickTime number When this mouse button was last clicked, in terms of CurTime.
---@field ClickPos Vector Where the mouse button was clicked on the screen, in pixels.

-- Holds information about the current state of the mouse's buttons.
---@class (exact) CurveEditor.CurveDraggableBase.MouseData
---@field LeftMouse CurveEditor.CurveDraggableBase.MouseButtonData Input data for the left mouse button.
---@field RightMouse CurveEditor.CurveDraggableBase.MouseButtonData Input data for the right mouse button.
---@field IsBeingDragged boolean If the mouse has left the deadzone for dragging this Draggable.
---@field IsBeingHovered boolean If the mouse is currently hovering over this Draggable.
---@field IsBeingPressed boolean If the mouse is currently dragging this Draggable.

-- Holds mostly static settings related to interactions.
---@class (exact) CurveEditor.CurveDraggableBase.InteractionSettings
---@field DragDeadzoneSize number The size of the deadzone for dragging this Draggable, in pixels.

--- The Base Class for nodes and handles that can be clicked and dragged on the graph.
---@class (exact) CurveEditor.CurveDraggableBase : DPanel
---@field VisualSettings CurveEditor.CurveDraggableBase.VisualSettings Variables, data, and settings used in rendering the draggable.
---@field InteractionData CurveEditor.CurveDraggableBase.MouseData Variables and data used in handling interactions like clicking and dragging.
---@field InteractionSettings CurveEditor.CurveDraggableBase.InteractionSettings Settings for how this Draggable should behave when interacted with.
local PANEL = {
    VisualSettings = {
        Circle          = circles.New( CIRCLE_TYPE_FILLED, 10, 10, 10 ),
        Radius          = 10,
        VertexDistance  = 10,
        Colors = {
            Idle        = Color( 75, 75, 200, 255 ),
            Hovered     = Color( 100, 100, 250, 255 ),
            Pressed     = Color( 255, 255, 255, 255 ),
            Dragged     = Color( 100, 100, 100, 100 )
        }
    },
    InteractionData = {
        IsBeingDragged = false,
        IsBeingHovered  = false,
        IsBeingPressed  = false,
        LeftMouse = {
            KeyCode     = MOUSE_LEFT,
            PressTime   = 0,
            ReleaseTime = 1,
            ClickTime   = 0,
            IsPressed   = false,
            ClickPos    = Vector( 0, 0, 0 )
        },
        RightMouse = {
            KeyCode     = MOUSE_RIGHT,
            PressTime   = 0,
            ReleaseTime = 1,
            ClickTime   = 0,
            IsPressed   = false,
            ClickPos    = Vector( 0, 0, 0 )
        }
    },
    InteractionSettings = {
        DragDeadzoneSize = 5
    }
}

function PANEL:SetRadius( radius )
    if not radius or not isnumber( radius ) then return end

    -- No negative radii, that makes the renderer sad
    radius = math.abs( radius )

    self.VisualSettings.Radius = radius
    self:SetSize( radius * 2, radius * 2 )

    self.VisualSettings.Circle:SetRadius( radius )
    self.VisualSettings.Circle:SetPos( radius, radius )
end

function PANEL:GetRadius()
    return self.VisualSettings.Radius
end

function PANEL:SetVertexDistance( distance )
    if not distance or not isnumber( distance ) then return end

    -- No negative distances, that makes the renderer sad
    distance = math.abs( distance )

    self.VisualSettings.VertexDistance = distance
    self.VisualSettings.Circle:SetDistance( distance )
end

function PANEL:GetVertexDistance()
    return self.VisualSettings.VertexDistance
end

function PANEL:SetColor( color )
    if not color or not IsColor( color ) then return end

    self.VisualSettings.Circle:SetColor( color )
end

function PANEL:GetColor()
    return self.VisualSettings.Circle:GetColor()
end

function PANEL:SetHovering( hovering )
    self.InteractionData.IsBeingHovered = hovering
    
end

function PANEL:IsBeingHovered()
    return self.InteractionData.IsBeingHovered
end

function PANEL:UpdateColors()
    local colors = self.VisualSettings.Colors

    local color = colors.Idle

    if self:IsBeingHovered() then
        color = colors.Hovered
    end

    if self.InteractionData.LeftMouse.IsPressed then
        color = colors.Pressed
    end

    self.VisualSettings.Circle:SetColor( color )
end

function PANEL:OnMousePressed( mouseButton )
    local buttonData
    if mouseButton == MOUSE_LEFT then
        buttonData = self.InteractionData.LeftMouse
    elseif mouseButton == MOUSE_RIGHT then
        buttonData = self.InteractionData.RightMouse
    else return end

    buttonData.PressTime = CurTime()
    buttonData.IsPressed = true
    buttonData.ClickPos = Vector( input.GetCursorPos() )

    self:UpdateColors()
end

function PANEL:OnMouseReleased( mouseButton )
    local buttonData
    if mouseButton == MOUSE_LEFT then
        buttonData = self.InteractionData.LeftMouse
    elseif mouseButton == MOUSE_RIGHT then
        buttonData = self.InteractionData.RightMouse
    else return end

    local wasValidClick = buttonData.PressTime > buttonData.ReleaseTime
    local heldTime = buttonData.ReleaseTime - buttonData.PressTime

    buttonData.ReleaseTime = CurTime()
    buttonData.IsPressed = false

    self:UpdateColors()
end

function PANEL:OnCursorExited()
    self.InteractionData.IsBeingHovered = false

    self:UpdateColors()
end

function PANEL:OnCursorEntered()
    self.InteractionData.IsBeingHovered = true

    local left = self.InteractionData.LeftMouse
    local right = self.InteractionData.RightMouse

    if left.IsPressed then
        left.IsPressed = input.IsMouseDown( MOUSE_LEFT )
    end

    if right.IsPressed then
        right.IsPressed = input.IsMouseDown( MOUSE_RIGHT )
    end

    self:UpdateColors()
end

function PANEL:Think()
    local left = self.InteractionData.LeftMouse

    -- Can't be dragging if the left mouse button isn't down
    if not left.IsPressed then return end

    local justReleasedLeft = not input.IsMouseDown( MOUSE_LEFT )

    -- Did we just stop dragging?
    if justReleasedLeft then
        left.IsPressed = false
        left.ReleaseTime = CurTime()
        self:UpdateColors()
        return
    end

    local cursorPos = Vector( input.GetCursorPos() )

    -- Are we breaking out of the deadzone?
    if not self.InteractionData.IsBeingDragged then
        local mouseDelta = cursorPos - left.ClickPos

        if mouseDelta:Length() >= self.InteractionSettings.DragDeadzoneSize then
            -- We've broken out of the deadzone and are officially being dragged
            self.InteractionData.IsBeingDragged = true
        else
            return
        end
    end

    local localPos = Vector( self:GetParent():ScreenToLocal( cursorPos.x, cursorPos.y ) )

    self:SetPos( localPos.x - self:GetRadius(), localPos.y - self:GetRadius() )
end

function PANEL:Paint( width, height )
    draw.NoTexture()
    self.VisualSettings.Circle()
end

vgui.Register( "CurveEditor.CurveDraggableBase", PANEL, "DPanel" )

vguihotload.HandleHotload( "CurveEditor" )