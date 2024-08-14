---@class CurveLib
---@field IsDevelopment boolean
_G.CurveLib = _G.CurveLib or {}
local CurveLib = _G.CurveLib

CurveLib.IsDevelopment = true

local function RunClient( path )
    if SERVER then AddCSLuaFile( path ) end
    if CLIENT then include( path ) end
end

local function RunShared( path )
    AddCSLuaFile( path )
    include( path )
end

hook.Add( "InitPostEntity", "A1_CurveLib_RegisterAddons", function()
    CurveLib.Addons = {}
    hook.Call( "CurveLib.RegisterAddons" )
end )

---
--- CurveLib Core
---

-- Curves
RunShared( "libraries/curvelib/core/curve/point.lua" )
RunShared( "libraries/curvelib/core/curve/data.lua" )

-- File Loading/Saving
RunShared( "libraries/curvelib/core/loading.lua" )

-- Addon Registration
RunShared( "libraries/curvelib/core/addons.lua" )


---
--- Curvelib Editor
---

-- Utils
RunShared( "libraries/curvelib/editor/utils.lua" )
RunShared( "libraries/curvelib/editor/draw-base.lua" )
if CurveLib.IsDevelopment then
    RunClient( "libraries/curvelib/editor/draw-base-tests.lua" )
end

-- Popups
RunClient( "libraries/curvelib/editor/popups.lua" )

-- Better Derma
RunClient( "libraries/better-derma/blabel.lua" )
RunClient( "libraries/better-derma/bframe.lua" )
RunClient( "libraries/better-derma/bbutton.lua" )

-- Curve Editor Panel Base
RunClient( "libraries/curvelib/editor/panel-base.lua" )

-- Editor Sidebar
RunClient( "libraries/curvelib/editor/sidebar/draw.lua" )
RunClient( "libraries/curvelib/editor/sidebar/panel.lua" )

-- Editor Menu Bar
RunClient( "libraries/curvelib/editor/menubar/panel.lua" )

-- Editor Graph Draggables
RunClient( "libraries/curvelib/editor/graph/handle/draw.lua" )
RunClient( "libraries/curvelib/editor/graph/handle/base.lua" )
RunClient( "libraries/curvelib/editor/graph/handle/main-handle.lua" )
RunClient( "libraries/curvelib/editor/graph/handle/side-handle.lua" )

-- Editor Graph
RunClient( "libraries/curvelib/editor/graph/draw.lua" )
RunClient( "libraries/curvelib/editor/graph/panel.lua" )

-- Curve Editor Frame
RunClient( "libraries/curvelib/editor/config.lua" )
RunClient( "libraries/curvelib/editor/frame.lua" )

-- Editor Testing Panel
RunClient( "libraries/curvelib/editor/testing-panel.lua" )

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