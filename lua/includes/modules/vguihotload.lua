module( "vguihotload", package.seeall )
---@class VGUIHotload

---@alias UniqueId string|number

---@class RegisteredFrame
---@field InitFunction function The function that will be called to create and return the DFrame when it needs to be created or recreated.
---@field Frame DFrame The DFrame that was created by the InitFunction.
---@field HotloadTime number The time at which the DFrame was last hotloaded.

---@type table<UniqueId, RegisteredFrame>
RegisteredFrames = RegisteredFrames or {}

-- Registers the initializer function for a DFrame to be hotloaded with the system.  
-- The function should create the DFrame, set it up, and return it.  
-- It will be closed and recreated in the same position and at the same size whenever the code is hotloaded.  
--- **Note:** This will immediately call the function and create the DFrame.
---@param id UniqueId The unique ID for this frame.
---@param vguiCreateFunction function The function that will be called to create and return the DFrame when it needs to be created or recreated.
function Register( id, vguiCreateFunction )
    RegisteredFrames[ id ] = {
        InitFunction = vguiCreateFunction,
        Frame = vguiCreateFunction(),
        HotloadTime = 0
    }
end

-- Checks if a given ID corresponds to a registered function.
---@private
---@param id UniqueId The unique ID for the frame.
---@return boolean `true` if the ID corresponds to a valid frame registration
function IsIdValid( id )
    return id and
        RegisteredFrames[ id ] and
        RegisteredFrames[ id ].Frame and
        RegisteredFrames[ id ].Frame:IsValid()
end


-- Hotloads a given unique ID's corresponding DFrame.  
-- Practically, this closes the existing DFrame, uses the initializer function to create a new one,  
-- and sets the new DFrame's position and size to match the one that was just closed.
---@param id UniqueId The unique ID for this frame.
function HandleHotload( id )
    if not IsIdValid( id ) then return end

    local vguiTable = RegisteredFrames[ id ]
    
    local width, height = vguiTable.Frame:GetSize()
    local x, y          = vguiTable.Frame:GetPos()

    vguiTable.Frame:Close()
    vguiTable.Frame = vguiTable.InitFunction()

    vguiTable.Frame:SetSize( width, height )
    vguiTable.Frame:SetPos( x, y )

    vguiTable.HotloadTime = CurTime()
end

local COLOR_HOTLOAD_INDICATOR = Color( 200, 200, 0 )
local HOTLOAD_INDICATOR_DURATION = 0.25

-- Adds a flashing rectangle over each registered VGUI element when it hotloads
hook.Add( "DrawOverlay", "A1_VguiHotload_DrawIndicator", function()
    cam.Start2D()
    for _, vguiTable in pairs( RegisteredFrames ) do

        local secondsSinceHotload = CurTime() - vguiTable.HotloadTime

        local shouldDrawIndicator = secondsSinceHotload < HOTLOAD_INDICATOR_DURATION
        if not shouldDrawIndicator then continue end

        local durationPercent = secondsSinceHotload / HOTLOAD_INDICATOR_DURATION

        local maxAlpha = 100
        local indicatorColor = ColorAlpha( COLOR_HOTLOAD_INDICATOR, maxAlpha - ( durationPercent * maxAlpha ) )
        local frameX, frameY = vguiTable.Frame:GetPos()
        local frameWidth, frameHeight = vguiTable.Frame:GetSize()

        surface.SetDrawColor( indicatorColor )
        surface.DrawRect( frameX, frameY, frameWidth, frameHeight )
    end
    cam.End2D()
end )