_G.CurveLib = _G.CurveLib or {}

-- Curves
AddCSLuaFile( "libraries/curvelib/curves/curve-point.lua" )
AddCSLuaFile( "libraries/curvelib/curves/curve-data.lua" )

include( "libraries/curvelib/curves/curve-point.lua" )
include( "libraries/curvelib/curves/curve-data.lua" )

-- Curve Editor
if SERVER then
    AddCSLuaFile( "libraries/curvelib/curve-editor/editor-toolbar.lua" )
    AddCSLuaFile( "libraries/curvelib/curve-editor/editor-sidebar.lua" )
    AddCSLuaFile( "libraries/curvelib/curve-editor/editor-graph.lua" )
    AddCSLuaFile( "libraries/curvelib/curve-editor/editor-frame.lua" )
end

if CLIENT then
    include( "libraries/curvelib/curve-editor/editor-toolbar.lua" )
    include( "libraries/curvelib/curve-editor/editor-sidebar.lua" )
    include( "libraries/curvelib/curve-editor/editor-graph.lua" )
    include( "libraries/curvelib/curve-editor/editor-frame.lua" )
end