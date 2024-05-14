require( "vguihotload" )

---@class (exact) BFrame.Config
---@field TitleBar BFrame.Config.TitleBar 
---@field DockPadding BFrame.Config.Sides The size of the padding between the Resizing Handles, TitleBar, and the docked contents .
---@field ResizeHandleSizes BFrame.Config.ResizingSides The size of the padding that allows for resizing of the BFrame.
---@field Colors { Focused: BFrame.Config.Colors, Unfocused: BFrame.Config.Colors }

---@class (exact) BFrame.Config.TitleBar
---@field Height integer The height of the TitleBar, in addition to the top Resize Handle and top Dock Padding.
---@field ButtonWidth integer The width, in pixels, of close, minimize, and maximize buttons.
---@field ButtonHeight integer The height, in pixels, of close, minimize, and maximize buttons.
---@field ButtonSpacing integer The horizontal spacing, in pixels, between the close, minimize, and maximize buttons.

---@class (exact) BFrame.Config.Sides
---@field Top integer
---@field Bottom integer
---@field Left integer
---@field Right integer

---@class (exact) BFrame.Config.ResizingSides : BFrame.Config.Sides
---@field ResizeCornerExtraWidth integer The width, in pixels, of the resizing corner in the bottom-right of the BFrame, in addition to the bottom and right Resize Handle sizes.
---@field ResizeCornerExtraHeight integer The height, in pixels, of the resizing corner in the bottom-right of the BFrame, in addition to the bottom and right Resize Handle sizes.

---@class (exact) BFrame.Config.Colors
---@field Background Color
---@field Border Color
---@field TitleText Color
---@field ResizeCornerBackground Color
---@field ResizeCornerForeground Color

---@type BFrame.Config
local DefaultConfig = {
    TitleBar = {
        Height = 24,
        ButtonWidth = 31,
        ButtonHeight = 24,
        ButtonSpacing = 4
    },
    DockPadding = {
        Top = 9,
        Bottom = 9,
        Left = 11,
        Right = 11
    },
    ResizeHandleSizes = {
        Top = 5,
        Bottom = 5,
        Left = 5,
        Right = 5,
        ResizeCornerExtraWidth = 10,
        ResizeCornerExtraHeight = 10
    },
    Colors = {
        Focused = {
            Background  = Color( 109, 112, 116, 250 ),
            Border      = Color(  35,  35,  35, 255 ),
            TitleText   = Color( 235, 235, 235, 255 ),
            ResizeCornerBackground = Color( 46, 46, 46, 255 ),
            ResizeCornerForeground = Color( 184, 184, 184, 184 )
        },
        Unfocused = {
            Background  = Color( 109, 112, 116, 220 ),
            Border      = Color( 35, 35, 35, 255 ),
            TitleText   = Color( 235, 235, 235, 200 ),
            ResizeCornerBackground = Color( 46, 46, 46, 255 ),
            ResizeCornerForeground = Color( 184, 184, 184, 184 )
        }
    }
}
local ConfigMetatable = {}
ConfigMetatable.__index = DefaultConfig

---@class BFrame : DFrame
---@field imgIcon  DImage? The BFrame's optional TitleBar Icon
---@field btnClose DButton The BFrame's close DButton
---@field btnMaxim DButton The BFrame's maximize DButton
---@field btnMinim DButton The BFrame's minimize DButton
---@field lblTitle DLabel The BFrame's TitleBar DLabel
---@field BFrame { Config: BFrame.Config } 
local PANEL = {}

-- Returns the Colors table for the current frame
---@return BFrame.Config.Colors
function PANEL:GetColorTable()
    if self:HasFocus() then
        return self.BFrame.Config.Colors.Focused
    else
        return self.BFrame.Config.Colors.Unfocused
    end
end

function PANEL:Init()
    self.BFrame = {}
    self.BFrame.Config = {}
    setmetatable( self.BFrame.Config, ConfigMetatable )

    local config = self.BFrame.Config
    local colors = self:GetColorTable()

    self:DockPadding(
        config.ResizeHandleSizes.Left + config.DockPadding.Left,
        config.ResizeHandleSizes.Top + config.DockPadding.Top + config.TitleBar.Height,
        config.ResizeHandleSizes.Right + config.DockPadding.Right,
        config.ResizeHandleSizes.Bottom + config.DockPadding.Bottom
    )

    self.lblTitle:SetTextColor( colors.TitleText )

end

function PANEL:PerformLayout()
    local config = self.BFrame.Config
    local handles = config.ResizeHandleSizes
    local dockPadding = config.DockPadding
    local titleBar = config.TitleBar

    local panelWidth, panelHeight = self:GetWide(), self:GetTall()

	local titlePush = 0

	if ( IsValid( self.imgIcon ) ) then

		self.imgIcon:SetPos( 5, 5 )
		self.imgIcon:SetSize( 16, 16 )
		titlePush = 16

	end

    local closeButtonX = panelWidth
        - titleBar.ButtonWidth
        - handles.Right

    local maximizeButtonX = closeButtonX
        - titleBar.ButtonWidth
        - titleBar.ButtonSpacing

    local minimizeButtonX = maximizeButtonX
        - titleBar.ButtonWidth
        - titleBar.ButtonSpacing

	self.btnClose:SetPos( closeButtonX, handles.Top )
	self.btnClose:SetSize( titleBar.ButtonWidth, titleBar.ButtonHeight )

	self.btnMaxim:SetPos( maximizeButtonX, handles.Top )
	self.btnMaxim:SetSize( titleBar.ButtonWidth, titleBar.ButtonHeight )

	self.btnMinim:SetPos( minimizeButtonX, handles.Top )
	self.btnMinim:SetSize( titleBar.ButtonWidth, titleBar.ButtonHeight )

	self.lblTitle:SetPos( dockPadding.Left + titlePush, handles.Top )
	--self.lblTitle:SetSize( panelWidth - titlePush, 20 )
end

function PANEL:GetLocalMousePos()
    local panelScreenPos = Vector( self:LocalToScreen( 0, 0 ) )

    local cursorScreenPos = Vector(
        math.Clamp( gui.MouseX(), 1, ScrW() - 1 ),
        math.Clamp( gui.MouseY(), 1, ScrH() - 1 )
    )
    
    return cursorScreenPos - panelScreenPos
end


local HANDLE_TOP_LEFT       = 1
local HANDLE_TOP            = 2
local HANDLE_TOP_RIGHT      = 3
local HANDLE_LEFT           = 4
local HANDLE_NONE           = 5
local HANDLE_RIGHT          = 6
local HANDLE_BOTTOM_LEFT    = 7
local HANDLE_BOTTOM         = 8
local HANDLE_BOTTOM_RIGHT   = 9
---@alias HANDLE integer
---| 1 HANDLE_TOP_LEFT
---| 2 HANDLE_TOP
---| 3 HANDLE_TOP_RIGHT
---| 4 HANDLE_LEFT
---| 5 HANDLE_NONE
---| 6 HANDLE_RIGHT
---| 7 HANDLE_BOTTOM_LEFT
---| 8 HANDLE_BOTTOM
---| 9 HANDLE_BOTTOM_RIGHT

local HandleToCursor = {
    [HANDLE_TOP_LEFT]       = "sizenwse",
    [HANDLE_TOP]            = "sizens",
    [HANDLE_TOP_RIGHT]      = "sizenesw",
    [HANDLE_LEFT]           = "sizewe",
    [HANDLE_NONE]           = "arrow",
    [HANDLE_RIGHT]          = "sizewe",
    [HANDLE_BOTTOM_LEFT]    = "sizenesw",
    [HANDLE_BOTTOM]         = "sizens",
    [HANDLE_BOTTOM_RIGHT]   = "sizenwse"
}

-- Returns an enum representing which, if any, resizing handle is at a given local position
---@param localPos any
---@return HANDLE
function PANEL:GetResizeHandle( localPos )
    local handles = self.BFrame.Config.ResizeHandleSizes
    local panelWidth, panelHeight = self:GetWide(), self:GetTall()

    local onLeftEdge = localPos.x <= handles.Left
    local onRightEdge = localPos.x >= panelWidth - handles.Right
    local onTopEdge = localPos.y <= handles.Top
    local onBottomEdge = localPos.y >= panelHeight - handles.Bottom
    local onResizableCorner =
    localPos.x >= panelWidth - handles.Right - handles.ResizeCornerExtraWidth
        and localPos.y >= panelHeight - handles.Bottom - handles.ResizeCornerExtraHeight

    if onResizableCorner then
        return HANDLE_BOTTOM_RIGHT
    elseif onTopEdge then
        if onLeftEdge then
            return HANDLE_TOP_LEFT
        elseif onRightEdge then
            return HANDLE_TOP_RIGHT
        else
            return HANDLE_TOP
        end
    elseif onBottomEdge then
        if onLeftEdge then
            return HANDLE_BOTTOM_LEFT
        else
            return HANDLE_BOTTOM
        end
    elseif onLeftEdge then
        return HANDLE_LEFT
    elseif onRightEdge then
        return HANDLE_RIGHT
    else
        return HANDLE_NONE
    end
end

function PANEL:Think()
    local panelScreenPos = Vector( self:LocalToScreen( 0, 0 ) )

    local cursorScreenPos = Vector(
        math.Clamp( gui.MouseX(), 1, ScrW() - 1 ),
        math.Clamp( gui.MouseY(), 1, ScrH() - 1 )
    )
    local cursorLocalPos = cursorScreenPos - panelScreenPos

    local panelWidth, panelHeight = self:GetWide(), self:GetTall()

    if not self.Dragging and not self.Resizing and self:IsHovered() then
        -- Resizing handler cursors
        if self:GetSizable() then
            local hoveredHandle = self:GetResizeHandle( cursorLocalPos )
            self:SetCursor( HandleToCursor[ hoveredHandle ] )
        end
    end

    if self.Dragging then
        local x = cursorScreenPos.x - self.Dragging[1]
		local y = cursorScreenPos.y - self.Dragging[2]

		-- Lock to screen bounds if screenlock is enabled
		if ( self:GetScreenLock() ) then
			x = math.Clamp( x, 0, ScrW() - panelWidth )
			y = math.Clamp( y, 0, ScrH() - panelHeight )
		end

		self:SetPos( x, y )
    elseif self.Resizing then

        local handle = self.Resizing.Handle

        self:SetCursor( HandleToCursor[handle] )

        local minWidth = self:GetMinWidth()
        local minHeight = self:GetMinHeight()

        -- Horizontal resizing
        local isLeftSide = handle == HANDLE_LEFT or handle == HANDLE_BOTTOM_LEFT or handle == HANDLE_TOP_LEFT
        local isRightSide = handle == HANDLE_RIGHT or handle == HANDLE_BOTTOM_RIGHT or handle == HANDLE_TOP_RIGHT
        if isLeftSide then
            local proposedWidth = math.max(
                ( panelScreenPos.x + panelWidth ) - ( cursorScreenPos.x - self.Resizing.x ),
                minWidth
            )

            self:SetX( panelScreenPos.x - ( proposedWidth - panelWidth ) )
            self:SetWide( proposedWidth )
        elseif isRightSide then
            local proposedWidth =  math.max(
                ( cursorScreenPos.x - panelScreenPos.x ) + ( self.Resizing.StartingWidth - self.Resizing.x ),
                minWidth
            )

            self:SetWide( proposedWidth )
        end

        -- Vertical resizing
        local isTopSide = handle == HANDLE_TOP or handle == HANDLE_TOP_LEFT or handle == HANDLE_TOP_RIGHT
        local isBottomSide = handle == HANDLE_BOTTOM or handle == HANDLE_BOTTOM_LEFT or handle == HANDLE_BOTTOM_RIGHT
        if isTopSide then
            local proposedHeight = math.max(
                ( panelScreenPos.y + panelHeight ) - ( cursorScreenPos.y - self.Resizing.y ),
                minHeight
            )

            self:SetY( panelScreenPos.y - ( proposedHeight - panelHeight ) )
            self:SetTall( proposedHeight )
        elseif isBottomSide then
            local proposedHeight = math.max(
                ( cursorScreenPos.y - panelScreenPos.y ) + ( self.Resizing.StartingHeight - self.Resizing.y ),
                minHeight
            )

            self:SetTall( proposedHeight )
        end
    end

	-- Don't allow the frame to go higher than 0
	if ( self:GetY() < 0 ) then
		self:SetPos( self:GetX(), 0 )
	end
end

function PANEL:Paint( width, height )
    local colors = self:GetColorTable()

	if self:GetBackgroundBlur() then
		Derma_DrawBackgroundBlur( self, self.m_fCreateTime )
	end

    -- Background
    surface.SetDrawColor( colors.Background )
    surface.DrawRect( 1, 1, width - 2, height - 2 )

    -- Border
    surface.SetDrawColor( colors.Border )
    surface.DrawOutlinedRect( 0, 0, width, height, 1 )

	return true
end

function PANEL:OnMousePressed( mouseButton )
    if mouseButton ~= MOUSE_LEFT then return end

    local localMousePos = self:GetLocalMousePos()

    if self:GetSizable() then
        local hoveredHandle = self:GetResizeHandle( localMousePos )

        if hoveredHandle ~= HANDLE_NONE then
            self.Resizing = {
                StartingWidth = self:GetWide(),
                StartingHeight = self:GetTall(),
                x = localMousePos.x,
                y = localMousePos.y,
                Handle = hoveredHandle
            }
            self:MouseCapture( true )
        end
    end

    if self:GetDraggable() and not self.Dragging then
        local handles = self.BFrame.Config.ResizeHandleSizes
        local panelWidth = self:GetWide()

        local onTitleBarX = localMousePos.x > handles.Left and localMousePos.x < panelWidth - handles.Right
        local onTitleBarY = localMousePos.y > handles.Top and localMousePos.y < handles.Top + self.BFrame.Config.TitleBar.Height
        if onTitleBarX and onTitleBarY then
            self.Dragging = Vector( localMousePos.x, localMousePos.y )
            self:MouseCapture( true )
        end
    end
end

function PANEL:OnMouseReleased()
	self.Dragging = nil
	self.Resizing = nil
	self:MouseCapture( false )
end

vgui.Register( "BFrame", PANEL, "DFrame" )
vguihotload.HandleHotload( "CurveLib.EditorFrame" )