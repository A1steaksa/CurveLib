_G.CurveLib = _G.CurveLib or {}

_G.CurveLib.IsDevelopment = true

local function RunClient( path )
    if SERVER then AddCSLuaFile( path ) end
    if CLIENT then include( path ) end
end

local function RunShared( path )
    AddCSLuaFile( path )
    include( path )
end

-- Utils
RunShared( "libraries/curvelib/utils.lua" )

-- Curves
RunShared( "libraries/curvelib/curves/curve-point.lua" )
RunShared( "libraries/curvelib/curves/curve-data.lua" )

-- Curve Editor
RunClient( "libraries/curvelib/curve-editor/editor-toolbar.lua" )
RunClient( "libraries/curvelib/curve-editor/editor-sidebar.lua" )
RunClient( "libraries/curvelib/curve-editor/editor-graph/curve-draw.lua" )
RunClient( "libraries/curvelib/curve-editor/editor-graph/editor-graph.lua" )
RunClient( "libraries/curvelib/curve-editor/editor-frame.lua" )

if CLIENT then
    concommand.Add( "curvelib_openeditor", function()
        vguihotload.Register( "CurveLib.EditorFrame", function()
            return vgui.Create( "CurveEditor.EditorFrame" )
        end )
    end )
end