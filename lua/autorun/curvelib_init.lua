---@class CurveLib
---@field IsDevelopment boolean
_G.CurveLib = _G.CurveLib or {}
local CurveLib = _G.CurveLib

CurveLib.IsDevelopment = true

local function RunShared( path )
    AddCSLuaFile( path )
    include( path )
end

local function RunClient( path )
    AddCSLuaFile( path )
    if CLIENT then include( path ) end
end

---
--- Curvelib Resources
---

resource.AddFile( "materials/curvelib/logo.png" )


---
--- Better Print
---
RunShared( "libraries/better-print/better-print.lua" )

---
--- CurveLib Core
---

-- Curves
RunShared( "libraries/curvelib/core/curve/point.lua" )
RunShared( "libraries/curvelib/core/curve/data.lua" )

-- File Loading/Saving
RunShared( "libraries/curvelib/core/loading.lua" )


---
--- Curvelib Editor
---

-- Utils
RunShared( "libraries/curvelib/editor/utils.lua" )
RunShared( "libraries/curvelib/editor/draw-base.lua" )
if CurveLib.IsDevelopment then
    RunClient( "libraries/curvelib/editor/draw-base-tests.lua" )
end

-- Addon Registration
RunShared( "libraries/curvelib/editor/addons.lua" )

-- Popups
RunClient( "libraries/curvelib/editor/popups.lua" )

-- Better Derma
RunClient( "libraries/better-derma/blabel.lua" )
RunClient( "libraries/better-derma/bframe.lua" )
RunClient( "libraries/better-derma/bbutton.lua" )

-- Curve Editor Panel Base
RunClient( "libraries/curvelib/editor/panel-base.lua" )

-- Editor Sidebar
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

-- Editor Graph Panel Modules
AddCSLuaFile( "libraries/curvelib/editor/graph/modules/config.lua" )
AddCSLuaFile( "libraries/curvelib/editor/graph/modules/coordinates-positioning.lua" )
AddCSLuaFile( "libraries/curvelib/editor/graph/modules/curve-hovering.lua" )
AddCSLuaFile( "libraries/curvelib/editor/graph/modules/curve-management.lua" )
AddCSLuaFile( "libraries/curvelib/editor/graph/modules/handle-dragging.lua" )
AddCSLuaFile( "libraries/curvelib/editor/graph/modules/handle-hovering.lua" )
AddCSLuaFile( "libraries/curvelib/editor/graph/modules/handle-management.lua" )
AddCSLuaFile( "libraries/curvelib/editor/graph/modules/handle-selection.lua" )
AddCSLuaFile( "libraries/curvelib/editor/graph/modules/interaction-settings.lua" )
AddCSLuaFile( "libraries/curvelib/editor/graph/modules/keyboard-input.lua" )
AddCSLuaFile( "libraries/curvelib/editor/graph/modules/mouse-input.lua" )

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