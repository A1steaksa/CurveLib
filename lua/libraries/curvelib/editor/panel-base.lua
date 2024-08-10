print( "Panel Base Loaded" )
---@class CurveLib.Editor.PanelBase : DPanel
---@field Config table
---@field EditorFrame CurveLib.Editor.Frame
---@field Caches table
local PANEL = {}

function PANEL:ClearAllCaches()
    self.Caches = {}
end

function PANEL:Init()
    self:ClearAllCaches()
end

--#region Parent/Sibling Getters and Setters

---@param editorFrame CurveLib.Editor.Frame
function PANEL:SetEditorFrame( editorFrame )
    self.EditorFrame = editorFrame
end

---@return CurveLib.Editor.Frame
function PANEL:GetEditorFrame()
    return self.EditorFrame
end

---@return CurveLib.Editor.Graph.Panel
function PANEL:GetGraph()
    return self.EditorFrame.Panels.Graph
end

---@return CurveLib.Editor.Sidebar.Panel
function PANEL:GetSidebar()
    return self.EditorFrame.Panels.Sidebar
end

---@return CurveLib.Editor.MenuBar.Panel
function PANEL:GetToolbar()
    return self.EditorFrame.Panels.MenuBar
end

--#endregion Parent/Sibling Getters and Setters

---@param config table The config table this 
---@return boolean? # Returns false if there was a problem
function PANEL:SetConfig( config )
    if not config or not istable( config ) then return false end

    self.Config = config
end

vgui.Register( "CurveLib.Editor.PanelBase", PANEL, "DPanel" )