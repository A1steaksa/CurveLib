require( "vguihotload" )


---@class (exact) BButton.Config
---@field States BButton.Config.States


---@class (exact) BButton.Config.States
---@field Focused { Idle: BButton.Config.States.State, Hovered: BButton.Config.States.State, Pressed: BButton.Config.States.State }
---@field Unfocused { Idle: BButton.Config.States.State, Hovered: BButton.Config.States.State }

---@class (exact) BButton.Config.States.Set
---@field Idle BButton.Config.States.State
---@field Hovered BButton.Config.States.State
---@field Pressed BButton.Config.States.State

---@class (exact) BButton.Config.States.State
---@field Border BButton.Config.States.State.Border
---@field Background BButton.Config.States.State.Background
---@field Text BButton.Config.States.State.Text

-- The visual settings for the border of a button in a given state
---@class (exact) BButton.Config.States.State.Border
---@field Enabled boolean
---@field Thickness integer
---@field Color Color

-- The visual settings for the background of a button in a given state
---@class (exact) BButton.Config.States.State.Background
---@field Enabled boolean
---@field Color Color

-- The visual settings for the text of a button in a given state
---@class (exact) BButton.Config.States.State.Text
---@field Enabled boolean
---@field Font string
---@field Color Color
---@field Alignment number
---@field Inset BetterDerma.Config.TextInset

---@type BButton.Config
local DefaultConfig = {
	States = {
		Focused = {
			Idle = {
				Border = {
					Enabled = true,
					Thickness = 1,
					Color = Color( 0, 0, 0 )
				},
				Background = {
					Enabled = true,
					Color = Color( 228, 228, 228 )
				},
				Text = {
					Enabled = true,
					Font = "DermaDefault",
					Color = Color( 81, 81, 81 ),
					Alignment = 4,
					Inset = {
						Top = 0,
						Left = 6
					}
				}
			},
			Hovered = {
				Border = {
					Enabled = true,
					Thickness = 1,
					Color = Color( 0, 0, 0 )
				},
				Background = {
					Enabled = true,
					Color = Color( 241, 241, 241 )
				},
				Text = {
					Enabled = true,
					Font = "DermaDefault",
					Color = Color( 42, 115, 180 ),
					Alignment = 4,
					Inset = {
						Top = 0,
						Left = 6
					}
				}
			},
			Pressed = {
				Border = {
					Enabled = true,
					Thickness = 1,
					Color = Color( 35, 35, 35 )
				},
				Background = {
					Enabled = true,
					Color = Color( 83, 180, 245 )
				},
				Text = {
					Enabled = true,
					Font = "DermaDefault",
					Color = Color( 255, 255, 255 ),
					Alignment = 4,
					Inset = {
						Top = 0,
						Left = 6
					}
				}
			}
		},

		Unfocused = {
			Idle = {
				Border = {
					Enabled = true,
					Thickness = 1,
					Color = Color( 79, 79, 79 )
				},
				Background = {
					Enabled = true,
					Color = Color( 228, 228, 228 )
				},
				Text = {
					Enabled = true,
					Font = "DermaDefault",
					Color = Color( 81, 81, 81 ),
					Alignment = 4,
					Inset = {
						Top = 0,
						Left = 6
					}
				}
			},
			Hovered = {
				Border = {
					Enabled = true,
					Thickness = 1,
					Color = Color( 79, 79, 79 )
				},
				Background = {
					Enabled = true,
					Color = Color( 241, 241, 241 )
				},
				Text = {
					Enabled = true,
					Font = "DermaDefault",
					Color = Color( 42, 115, 180 ),
					Alignment = 4,
					Inset = {
						Top = 0,
						Left = 6
					}
				}
			}
		}
	}
}


local ConfigMetatable = {}
ConfigMetatable.__index = DefaultConfig

---@class BButton : DButton
---@field BButton { Config: BButton.Config }
---@field Depressed boolean Whether the button is currently being held down
local PANEL = {}


function PANEL:Init()
    self.BFrame = {}
    self.BFrame.Config = {}
    setmetatable( self.BFrame.Config, ConfigMetatable )

	self:SetContentAlignment( 5 )

	self:SetPaintBackground( true )

	self:SetTall( 22 )
	self:SetMouseInputEnabled( true )
	self:SetKeyboardInputEnabled( true )

	self:SetCursor( "arrow" )
	self:SetFont( "DermaDefault" )
end

-- Set the button's current visual configuration
---@return BButton.Config.States.State
function PANEL:GetState()
	local states = self.BFrame.Config.States

	local stateSet
	if self:HasFocus() then
		stateSet = states.Focused
	else
		stateSet = states.Unfocused
	end

	if self.Depressed then
		return states.Focused.Pressed
	elseif self:IsHovered() then
		return stateSet.Hovered
	else
		return stateSet.Idle
	end
end

function PANEL:Paint( width, height )
	local state = self:GetState()
	local border = state.Border
	local background = state.Background
	local text = state.Text

	if border.Enabled then
		surface.SetDrawColor( border.Color )
		surface.DrawOutlinedRect( 0, 0, width, height, border.Thickness )
	end

	if background.Enabled then
		local borderOffset = border.Enabled and border.Thickness or 0

		surface.SetDrawColor( state.Background.Color )
		surface.DrawRect( borderOffset, borderOffset, width - borderOffset * 2, height - borderOffset * 2 )
	end

	if text.Enabled then
		self:SetFont( text.Font )
		self:SetTextColor( text.Color )
		self:SetContentAlignment( text.Alignment )
		self:SetTextInset( text.Inset.Left, text.Inset.Top )

		return false
	else
		return true
	end
end


function PANEL:PerformLayout( w, h )
	-- If we have an image we have to place the image on the left
	-- and make the text align to the left, then set the inset
	-- so the text will be to the right of the icon.
	if ( IsValid( self.m_Image ) ) then

		local targetSize = math.min( self:GetWide() - 4, self:GetTall() - 4 )

		local imgW, imgH = self.m_Image.ActualWidth, self.m_Image.ActualHeight
		local zoom = math.min( targetSize / imgW, targetSize / imgH, 1 )
		local newSizeX = math.ceil( imgW * zoom )
		local newSizeY = math.ceil( imgH * zoom )

		self.m_Image:SetWide( newSizeX )
		self.m_Image:SetTall( newSizeY )

		if ( self:GetWide() < self:GetTall() ) then
			self.m_Image:SetPos( 4, ( self:GetTall() - self.m_Image:GetTall() ) * 0.5 )
		else
			self.m_Image:SetPos( 2 + ( targetSize - self.m_Image:GetWide() ) * 0.5, ( self:GetTall() - self.m_Image:GetTall() ) * 0.5 )
		end

		self:SetTextInset( self.m_Image:GetWide() + 16, 0 )

	end

	DLabel.PerformLayout( self, w, h )

end


function PANEL:SizeToContents()
	local w, h = self:GetContentSize()
	self:SetSize( w + 8, h + 4 )
end


vgui.Register( "BButton", PANEL, "BLabel" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )