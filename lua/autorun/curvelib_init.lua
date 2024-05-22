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
RunShared( "libraries/curvelib/editor/utils.lua" )
RunShared( "libraries/curvelib/editor/draw-base.lua" )

-- Curves
RunShared( "libraries/curvelib/curve/point.lua" )
RunShared( "libraries/curvelib/curve/data.lua" )

-- Better Frames
RunClient( "libraries/better-frame/bframe.lua" )

-- Curve Editor Panel Base
RunClient( "libraries/curvelib/editor/panel-base.lua" )

-- Editor Sidebar
RunClient( "libraries/curvelib/editor/sidebar/draw.lua" )
RunClient( "libraries/curvelib/editor/sidebar/panel.lua" )

-- Editor Toolbar
RunClient( "libraries/curvelib/editor/toolbar/draw.lua" )
RunClient( "libraries/curvelib/editor/toolbar/panel.lua" )

-- Editor Graph Draggables
RunClient( "libraries/curvelib/editor/graph/draggable/draw.lua" )
RunClient( "libraries/curvelib/editor/graph/draggable/base.lua" )
RunClient( "libraries/curvelib/editor/graph/draggable/main-point.lua" )
RunClient( "libraries/curvelib/editor/graph/draggable/handle-point.lua" )

-- Editor Graph
RunClient( "libraries/curvelib/editor/graph/draw.lua" )
RunClient( "libraries/curvelib/editor/graph/panel.lua" )

-- Curve Editor Frame
RunClient( "libraries/curvelib/editor/config.lua" )
RunClient( "libraries/curvelib/editor/frame.lua" )

if not CLIENT then return end

concommand.Add( "curvelib_openeditor", function()
    vguihotload.Register( "CurveLib.Editor.Frame", function()
        return vgui.Create( "CurveLib.Editor.Frame" )
    end )
end )

hook.Add( "OnLuaError", "A1_CurveLib_CrashPrevention", function( error, realm, stack, name, id  )
    if _G.CurveLib and _G.CurveLib.IsDrawingMesh then
        print( error )
        mesh.End()
        _G.CurveLib.IsDrawingMesh = false
    end
end )