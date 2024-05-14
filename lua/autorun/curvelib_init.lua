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
RunShared( "libraries/curvelib/draw-basic.lua" )

-- Better Frames
RunClient( "libraries/better-frame/bframe.lua" )

-- Curves
RunShared( "libraries/curvelib/curves/curve-point.lua" )
RunShared( "libraries/curvelib/curves/curve-data.lua" )

-- Curve Editor
RunClient( "libraries/curvelib/curve-editor/editor-config.lua" )
RunClient( "libraries/curvelib/curve-editor/editor-toolbar.lua" )
RunClient( "libraries/curvelib/curve-editor/editor-sidebar.lua" )
RunClient( "libraries/curvelib/curve-editor/editor-graph/draw-graph.lua" )
RunClient( "libraries/curvelib/curve-editor/editor-graph/editor-graph.lua" )
RunClient( "libraries/curvelib/curve-editor/editor-frame.lua" )

if not CLIENT then return end

concommand.Add( "curvelib_openeditor", function()
    vguihotload.Register( "CurveLib.EditorFrame", function()
        return vgui.Create( "CurveEditor.EditorFrame" )
    end )
end )

hook.Add( "OnLuaError", "A1_CurveLib_CrashPrevention", function( error, realm, stack, name, id  )
    if _G.CurveLib and _G.CurveLib.IsDrawingMesh then
        print( error )
        mesh.End()
        _G.CurveLib.IsDrawingMesh = false
    end
end )