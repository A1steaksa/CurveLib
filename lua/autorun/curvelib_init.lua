print( "CurveLib Initializing..." )

include( "curvelib/curve-editor.lua" )

local minWidth, minheight = 512, 512

if CLIENT then
    local function OpenCurveEditor()
        local frame = vgui.Create( "DFrame" )
        frame:SetTitle( "Curve Editor" )
        frame:SetSize( minWidth, minheight )
        frame:SetMinimumSize( minWidth, minheight )
        frame:SetSizable( true )
        frame:Center()

        local editor = vgui.Create( "CurveEditor", frame )
        editor:Dock( FILL )

        frame:MakePopup()

        return frame
    end

    concommand.Add( "curvelib_openeditor", function()
        vguihotload.Register( "CurveEditor", OpenCurveEditor )
    end )
end

print( "CurveLib Finished Initializing" )