print( "CurveLib Initializing..." )

include( "includes/curvelib/curve-classes.lua" )
include( "includes/curvelib/curve-utils.lua" )

if CLIENT then

    --- All files that need to hotload are included here
    --- so that they will inherit autorun's hotloading.
    include( "includes/curvelib/curve-drawing.lua" )
    include( "includes/curvelib/curve-editor-settings.lua" )
    include( "includes/curvelib/curve-editor.lua" )

    local minWidth, minheight = 512, 512

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