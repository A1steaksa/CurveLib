require( "vguihotload" )

---@alias BaseHandle CurveLib.Editor.Graph.Handle.Base

---@class CurveLib.Editor.Graph.Handle.Base : DPanel
---@field x integer
---@field y integer
---@field GraphPanel GraphPanel The Graph Panel this Handle is parented to.  Cached here for autocomplete convenience and access speed.
---@field IsBeingDragged boolean? Whether or not the Handle is being dragged
---@field HalfWidth integer
---@field HalfHeight integer
---@field HoverStartTime number
---@field HoverEndTime number
---@field CurrentRadius number The current radius of the Handle, as a float pixel value which will be made into an integer for rendering.
---@field CurrentColor Color The current color of the Handle
---@field IsMainHandle boolean? Whether or not this Handle is the main Handle
---@field IsSideHandle boolean? Whether or not this Handle is a side Handle
---@field MainHandle MainHandle
---@field LeftHandle SideHandle?
---@field RightHandle SideHandle?
local PANEL = {}

function PANEL:Init()
    self.GraphPanel = self:GetParent() --[[@as GraphPanel]]
    self:SetSelectable( true )
    self:SetPaintedManually( true )
end

---@param handleConfig HandleConfig The Handle's configuration
function PANEL:SetConfig( handleConfig )
    self.Config = handleConfig
end

---@return HandleConfig # The Handle's configuration
function PANEL:GetConfig()
    return self.Config
end

function PANEL:OnSizeChanged( width, height )
    self.HalfWidth = math.floor( width / 2 )
    self.HalfHeight = math.floor( height / 2 )
end

-- Like SetPos, but relative to the center of the Panel.
---@param x integer
---@param y integer
function PANEL:SetCenterPos( x, y )
    self:SetX( x - self.HalfWidth )
    self:SetY( y - self.HalfHeight )
end

-- Like GetPos, but returns the center of the Panel.
---@return integer x
---@return integer y
function PANEL:GetCenterPos()
    return self.x + self.HalfWidth, self.y + self.HalfHeight
end

function PANEL:OnMousePressed( mouseButton )
    self.GraphPanel:OnHandleMousePressed( self, mouseButton )
end

function PANEL:OnCursorEntered()
    self.GraphPanel:OnHandleHoverStarted( self )

    self.HoverStartTime = CurTime()
end

function PANEL:OnCursorExited()
    self.GraphPanel:OnHandleHoverEnded( self )

    self.HoverEndTime = CurTime()
end

-- Returns the duration the cursor has been hovering over the Handle.
---@return number Duration The duration, in seconds
function PANEL:GetHoverDuration()
    if not self.HoverStartTime then return 0 end
    return self.HoverEndTime and self.HoverEndTime - self.HoverStartTime or CurTime() - self.HoverStartTime
end

-- Returns the current state of the Handle
function PANEL:GetState()
    if self.IsBeingDragged then
        return self.Config.Dragged
    elseif self:IsHovered() then
        return self.Config.Hovered
    else
        return self.Config.Idle
    end
end

-- Updates the current visuals of the Handle based on its current state
function PANEL:UpdateVisuals()
    local goalState = self:GetState()

    if not self.CurrentRadius or not self.CurrentColor then
        local goalColor = goalState.Color
        self.CurrentColor = Color( goalColor.r, goalColor.g, goalColor.b, goalColor.a )
        self.CurrentRadius = goalState.Radius
    end

    local goalColor = goalState.Color
    local colorChange = FrameTime() * goalState.ColorChangeRate
    self.CurrentColor.r = math.Approach( self.CurrentColor.r, goalColor.r, colorChange )
    self.CurrentColor.g = math.Approach( self.CurrentColor.g, goalColor.g, colorChange )
    self.CurrentColor.b = math.Approach( self.CurrentColor.b, goalColor.b, colorChange )
    self.CurrentColor.a = math.Approach( self.CurrentColor.a, goalColor.a, colorChange )

    self.CurrentRadius = math.Approach( self.CurrentRadius, goalState.Radius, FrameTime() * goalState.RadiusChangeRate )
end

vgui.Register( "CurveLib.Editor.Graph.Handle.Base", PANEL, "DPanel" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )