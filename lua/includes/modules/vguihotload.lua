AddCSLuaFile()
module( "vguihotload", package.seeall )

--- Format: [ID] -> { function InitFunction, DFrame Frame, number HotloadTime }
---@type table<any,table>
RegisteredFrames = RegisteredFrames or {}

function Register( id, vguiCreateFunction )
    RegisteredFrames[ id ] = {
        InitFunction = vguiCreateFunction,
        Frame = vguiCreateFunction(),
        HotloadTime = 0
    }
end

function IsIdValid( id )
    return
        id and
        RegisteredFrames[ id ] and
        RegisteredFrames[ id ].Frame and
        RegisteredFrames[ id ].Frame:IsValid()
end

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

hook.Add( "DrawOverlay", "A1_VguiHotload_DrawIndicator", function()

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
end )