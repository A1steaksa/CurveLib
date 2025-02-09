require( "vguihotload" )

---@class CurveLib.Editor.Graph.Panel
---@field HeldKeys table<KEY|integer, boolean> The keyboard keys currently being held down
PANEL = PANEL

if not PANEL then error( "Failed to load KeyboardInput module of CurveLib.Editor.Graph.Panel" ) return end

PANEL.HeldKeys = {}

---@param keycode KEY|integer
---@return boolean # `true` if the key is currently held down, `false` otherwise
function PANEL:IsKeyDown( keycode )
    return self.HeldKeys[ keycode ]
end

-- Returns the state of the modifier keys
---@return boolean ctrl
---@return boolean shift
---@return boolean alt
function PANEL:GetModifierKeys()
    local ctrl = self:IsKeyDown( KEY_LCONTROL ) or self:IsKeyDown( KEY_RCONTROL )
    local shift = self:IsKeyDown( KEY_LSHIFT ) or self:IsKeyDown( KEY_RSHIFT )
    local alt = self:IsKeyDown( KEY_LALT ) or self:IsKeyDown( KEY_RALT )
    return ctrl, shift, alt
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
    local ctrl, shift, alt = self:GetModifierKeys()

    -- ESC - Cancel ongoing actions
    if keycode == KEY_ESCAPE then
        -- If there are keys down, cancel them
        if table.Count( self.HeldKeys ) > 0 then
            self.HeldKeys = {}
        elseif self.IsBoxSelecting then
            self:EndBoxSelection( true )
        elseif self.SelectedHandles then
            self:DeselectAllHandles()
        end

        -- Never consider Esc to be a held key
        return
    end

    -- CTRL + A - Select all Handles
    if ctrl and keycode == KEY_A then
        for _, handle in ipairs( self.MainHandles ) do
            self:SelectHandle( handle, true )
        end
    end

    -- CTRL + N - Open a new Curve
    if ctrl and keycode == KEY_N then
        self.EditorFrame:OpenNewCurve()
    end

    self.HeldKeys[ keycode ] = true
end

-- Called when a key is released
---@param keycode KEY|integer
function PANEL:OnKeyCodeReleased( keycode )
    if ( keycode == KEY_DELETE or keycode == KEY_BACKSPACE ) then
        self:DeleteSelectedHandles()
    end

    self.HeldKeys[ keycode ] = nil
end