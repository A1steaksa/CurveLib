require( "vguihotload" )

---@class (exact) BLabel.Config
---@field MaxDoubleClickInterval number The maximum time, in seconds, that can be between two clicks and still count as a double-click


---@type BLabel.Config
local DefaultConfig = {
	MaxDoubleClickInterval = 0.2
}

local ConfigMetatable = {}
ConfigMetatable.__index = DefaultConfig

---@class BLabel : DLabel
---@field BLabel { Config: BLabel.Config }
---@field m_bDoubleClicking boolean Whether double-clicking is enabledw
local PANEL = {}


function PANEL:Init()
	self.BLabel = {}
    self.BLabel.Config = {}
    setmetatable( self.BLabel.Config, ConfigMetatable )

	self:SetIsToggle( false )
	self:SetToggle( false )
	self:SetDisabled( false )
	self:SetMouseInputEnabled( false )
	self:SetKeyboardInputEnabled( false )
	self:SetDoubleClickingEnabled( false )

	-- This turns off the engine drawing
	self:SetPaintBackgroundEnabled( false )
	self:SetPaintBorderEnabled( false )

	self:SetFont( "DermaDefault" )
end


function PANEL:Toggle()
	if ( !self:GetIsToggle() ) then return end

	self:SetToggle( !self:GetToggle() )
	self:OnToggled( self:GetToggle() )
end

function PANEL:UpdateColours( skin )
	if ( self:GetBright() ) then return self:SetTextStyleColor( skin.Colours.Label.Bright ) end
	if ( self:GetDark() ) then return self:SetTextStyleColor( skin.Colours.Label.Dark ) end
	if ( self:GetHighlight() ) then return self:SetTextStyleColor( skin.Colours.Label.Highlight ) end

	return self:SetTextStyleColor( skin.Colours.Label.Default )
end


function PANEL:Think()
	if ( self:GetAutoStretchVertical() ) then
		self:SizeToContentsY()
	end
end


function PANEL:OnCursorEntered()
	self:InvalidateLayout( true )
end


function PANEL:OnCursorExited()
	self:InvalidateLayout( true )
end


-- Called when the label has a mouse button pressed while it is in focus
---@param mouseCode MOUSE The mouse button that was pressed
---@return boolean? shouldOverride Whether the default action should be overridden
function PANEL:OnMousePressed( mouseCode )
	if ( not self:IsEnabled() ) then return end

	self:RequestFocus()

	local config = self.BLabel.Config

	if self.m_bDoubleClicking and mouseCode == MOUSE_LEFT and !dragndrop.IsDragging() then
		local timeSinceLastClick = SysTime() - ( self.LastClickTime or 0 )
		if timeSinceLastClick < config.MaxDoubleClickInterval then
			self:DoDoubleClickInternal()
			self:DoDoubleClick()
			return
		end

		self.LastClickTime = SysTime()
	end

	-- Do not do selections if playing is spawning things while moving
	local isPlyMoving = LocalPlayer and IsValid( LocalPlayer() ) and ( LocalPlayer():KeyDown( IN_FORWARD ) or LocalPlayer():KeyDown( IN_BACK ) or LocalPlayer():KeyDown( IN_MOVELEFT ) or LocalPlayer():KeyDown( IN_MOVERIGHT ) )

	-- If we're selectable and have shift held down then go up
	-- the parent until we find a selection canvas and start box selection
	if ( self:IsSelectable() and mouseCode == MOUSE_LEFT and ( input.IsShiftDown() or input.IsControlDown() ) and !isPlyMoving ) then
		return self:StartBoxSelection()
	end

	self:MouseCapture( true )
	self.Depressed = true
	self:OnDepressed()
	self:InvalidateLayout( true )

	-- Tell DragNDrop that we're down, and might start getting dragged!
	self:DragMousePress( mouseCode )
end


function PANEL:OnMouseReleased( mousecode )

	self:MouseCapture( false )

	if ( not self:IsEnabled() ) then return end
	if ( !self.Depressed and dragndrop.m_DraggingMain ~= self ) then return end

	if ( self.Depressed ) then
		self.Depressed = nil
		self:OnReleased()
		self:InvalidateLayout( true )
	end

	--
	-- If we were being dragged then don't do the default behaviour!
	--
	if ( self:DragMouseRelease( mousecode ) ) then
		return
	end

	if ( self:IsSelectable() and mousecode == MOUSE_LEFT ) then

		local canvas = self:GetSelectionCanvas()
		if ( canvas ) then
			canvas:UnselectAll()
		end

	end

	if ( !self.Hovered ) then return end

	--
	-- For the purposes of these callbacks we want to
	-- keep depressed true. This helps us out in controls
	-- like the checkbox in the properties dialog. Because
	-- the properties dialog will only manually change the value
	-- if IsEditing() is true - and the only way to work out if
	-- a label/button based control is editing is when it's depressed.
	--
	self.Depressed = true

	if ( mousecode == MOUSE_RIGHT ) then
		self:DoRightClick()
	end

	if ( mousecode == MOUSE_LEFT ) then
		self:DoClickInternal()
		self:DoClick()
	end

	if ( mousecode == MOUSE_MIDDLE ) then
		self:DoMiddleClick()
	end

	self.Depressed = nil

end


function PANEL:DoClick()
	print( "DoClick" )
	self:Toggle()
end


vgui.Register( "BLabel", PANEL, "DLabel" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )