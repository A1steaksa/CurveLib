require( "vguihotload" )

---@class FileMenu : table
---@field Menu DMenu
---@field New DMenuOption
---@field NewFromTemplate DMenuOption
---@field OpenFile DMenuOption
---@field OpenEntity DMenuOption
---@field OpenViewModel DMenuOption
---@field OpenAddon DMenuOption
---@field Save DMenuOption
---@field SaveAs DMenuOption
---@field SaveAll DMenuOption
---@field Export DMenuOption
---@field CloseCurve DMenuOption
---@field CloseAllCurves DMenuOption
---@field Exit DMenuOption

---@class EditMenu : table
---@field Menu DMenu
---@field Undo DMenuOption
---@field Redo DMenuOption
---@field Copy DMenuOption
---@field Cut DMenuOption
---@field Paste DMenuOption
---@field SelectAll DMenuOption
---@field DeselectAll DMenuOption

---@class CurveLib.Editor.MenuBar.Panel : CurveLib.Editor.PanelBase
---@field File FileMenu
---@field Edit EditMenu
local PANEL = {}

--#region File Menu

function PANEL:AddFileMenu( menuBar )
    self.File = {}
    self.File.Menu = menuBar:AddMenu( "File" )

    do -- New
        self.File.New = self.File.Menu:AddOption( "New", function()
            self:DoFileNew()
        end )
        self.File.New:SetIcon( "icon16/page_white.png" )

        self.File.NewFromTemplate = self.File.Menu:AddOption( "New from Template", function()
            self:DoFileNewFromTemplate()
        end )
        self.File.NewFromTemplate:SetIcon( "icon16/page_white_go.png" )
        self.File.NewFromTemplate:SetEnabled( false )

    end

    self.File.Menu:AddSpacer()

    do -- Open/Load

        -- Files
        self.File.OpenFile = self.File.Menu:AddOption( "Open File", function()
            self:DoOpenFile()
        end )
        self.File.OpenFile:SetIcon( "icon16/folder_page_white.png" )

        -- Entities
        self.File.OpenEntity = self.File.Menu:AddOption( "Open Entity", function()
            self:DoOpenEntity()
        end )
        self.File.OpenEntity:SetIcon( "icon16/application_edit.png" )

        -- Viewmodels
        self.File.OpenViewModel = self.File.Menu:AddOption( "Open View Model", function()
            self:DoOpenViewModel()
        end )
        self.File.OpenViewModel:SetIcon( "icon16/application_edit.png" )

        -- Addon
        local _, openAddonOption = self.File.Menu:AddSubMenu( "Open Addon" )
        self.File.OpenAddon = openAddonOption
        self.File.OpenAddon:SetIcon( "icon16/monitor_edit.png" )
    end

    self.File.Menu:AddSpacer()

    do -- Save
        self.File.Save = self.File.Menu:AddOption( "Save to File", function()
            self:DoSaveToFile()
        end )
        self.File.Save:SetIcon( "icon16/disk.png" )
        self.File.Save:SetEnabled( false )

        self.File.SaveAs = self.File.Menu:AddOption( "Save to File As", function()
            self:DoSaveToFileAs()
        end )
        self.File.SaveAs:SetIcon( "icon16/disk.png" )
        self.File.SaveAs:SetEnabled( false )

        self.File.SaveAll = self.File.Menu:AddOption( "Save All to File", function()
            self:DoSaveAllToFile()
        end )
        self.File.SaveAll:SetIcon( "icon16/disk_multiple.png" )
        self.File.SaveAll:SetEnabled( false )
    end

    self.File.Menu:AddSpacer()

    do -- Export
        self.File.Export = self.File.Menu:AddOption( "Export as Text", function()
            self:DoExportAsText()
        end )
        self.File.Export:SetIcon( "icon16/page_white_text.png" )
        self.File.Export:SetEnabled( false )
    end

    self.File.Menu:AddSpacer()

    do -- Closing
        self.File.CloseCurve = self.File.Menu:AddOption( "Close Current Curve", function()
            self:DoCloseCurrentCurve()
        end )
        self.File.CloseCurve:SetIcon( "icon16/cross.png" )
        self.File.CloseCurve:SetEnabled( false )

        self.File.CloseAllCurves = self.File.Menu:AddOption( "Close All Curves", function()
            self:DoCloseAllCurves()
        end )
        self.File.CloseAllCurves:SetIcon( "icon16/cross.png" )
        self.File.CloseAllCurves:SetEnabled( false )
    end

    self.File.Menu:AddSpacer()

    do -- Exit
        self.File.Exit = self.File.Menu:AddOption( "Exit", function()
            self:DoExit()
        end )
        self.File.Exit:SetIcon( "icon16/door_open.png" )
    end

    -- Override the menu open function to update the menu options based on the current state
    local defaultOpen = self.File.Menu.Open
    self.File.Menu.Open = function( ... )

        do -- Update/Populate the Open Addon submenu
            self.File.OpenAddon:SetEnabled( CurveLib.HasRegisteredAddons() )
            local openAddonSubmenu = self.File.OpenAddon:AddSubMenu()

            local addons = CurveLib.GetRegisteredAddons()

            self.File.OpenAddon:SetText( "Open Addon (" .. table.Count( addons ) .. ")" )

            for name, _ in pairs( addons ) do
                openAddonSubmenu:AddOption( name, function()
                    self:DoOpenAddon( name )
                end )
            end

            if openAddonSubmenu:GetCanvas():GetChildren() == 0 then
                openAddonSubmenu:AddOption( "No Addons Found" ):SetEnabled( false )
            end
        end

        defaultOpen( ... )
    end
end

--#region New

function PANEL:DoFileNew()
    self.EditorFrame:OpenCurve( CurveData(
        CurvePoint( Vector( 0, 0 ), nil, Vector( 0.25, 0.25 ) ),
        CurvePoint( Vector( 1, 1 ), Vector( 0.75, 0.75 ), nil )
    ) )
end

function PANEL:DoFileNewFromTemplate()
    ErrorNoHalt( "New from Template not implemented yet" )
end

--#endregion New

--#region Open/Load

function PANEL:DoOpenFile()
    CurveLib.Popups.LoadFile( function( path )
        local curve = CurveLib.LoadCurve( path )
        self.EditorFrame:OpenCurve( curve )
    end )
end

function PANEL:DoOpenEntity()
    ErrorNoHalt( "Open Entity not implemented yet" )
end

function PANEL:DoOpenViewModel()
    ErrorNoHalt( "Open View Model not implemented yet" )
end

---Opens an addon by name and 
---@param addonName string
function PANEL:DoOpenAddon( addonName )
    self.EditorFrame:OpenAddon( addonName )
end

--#endregion Open/Load

--#region Save

function PANEL:DoSaveToFile()
    ErrorNoHalt( "Save to File not implemented yet" )
end

function PANEL:DoSaveToFileAs()
    CurveLib.Popups.SaveFile( function( path )
        CurveLib.SaveCurve( path, self.EditorFrame.CurrentCurve  )
    end )
end

function PANEL:DoSaveAllToFile()
    ErrorNoHalt( "Save All to File not implemented yet" )
end

--#endregion Save

--#region Export

function PANEL:DoExportAsText()
    ErrorNoHalt( "Export as Text not implemented yet" )
end

--#endregion Export

--#region Closing

function PANEL:DoCloseCurrentCurve()
    self.EditorFrame:CloseCurve()
end

function PANEL:DoCloseAllCurves()
    ErrorNoHalt( "Close All Curves not implemented yet" )
end

--#endregion Closing

--#region Exit

function PANEL:DoExit()
    self.EditorFrame:Close()
end

--#endregion Exit

--#endregion File Menu

--#region Edit Menu

function PANEL:AddEditMenu( menuBar )
    self.Edit = {}
    self.Edit.Menu = menuBar:AddMenu( "Edit" )

    do -- Undo/Redo
        self.Edit.Undo = self.Edit.Menu:AddOption( "Undo", function()
            self:DoUndo()
        end )
        self.Edit.Undo:SetIcon( "icon16/arrow_undo.png" )
        self.Edit.Undo:SetEnabled( false )

        self.Edit.Redo = self.Edit.Menu:AddOption( "Redo", function()
            self:DoRedo()
        end )
        self.Edit.Redo:SetIcon( "icon16/arrow_redo.png" )
        self.Edit.Redo:SetEnabled( false )
    end

    self.Edit.Menu:AddSpacer()

    do -- Cut, Copy, Paste
        self.Edit.Copy = self.Edit.Menu:AddOption( "Copy", function()
            self:DoCopy()
        end )
        self.Edit.Copy:SetIcon( "icon16/page_copy.png" )
        self.Edit.Copy:SetEnabled( false )

        self.Edit.Cut = self.Edit.Menu:AddOption( "Cut", function()
            self:DoCut()
        end )
        self.Edit.Cut:SetIcon( "icon16/cut.png" )
        self.Edit.Cut:SetEnabled( false )

        self.Edit.Paste = self.Edit.Menu:AddOption( "Paste", function()
            self:DoPaste()
        end )
        self.Edit.Paste:SetIcon( "icon16/page_paste.png" )
        self.Edit.Paste:SetEnabled( false )
    end

    self.Edit.Menu:AddSpacer()

    do -- Select/Deselect
        self.Edit.SelectAll = self.Edit.Menu:AddOption( "Select All", function()
            self:DoSelectAll()
        end )
        self.Edit.SelectAll:SetIcon( "icon16/table.png" )
        self.Edit.SelectAll:SetEnabled( false )

        self.Edit.DeselectAll = self.Edit.Menu:AddOption( "Deselect All", function()
            self:DoDeselectAll()
        end )
        self.Edit.DeselectAll:SetIcon( "icon16/table_delete.png" )
        self.Edit.DeselectAll:SetEnabled( false )
    end
end

--#region Undo/Redo

function PANEL:DoUndo()
    ErrorNoHalt( "Undo not implemented yet" )
end

function PANEL:DoRedo()
    ErrorNoHalt( "Redo not implemented yet" )
end

--#endregion Undo/Redo

--#region Cut, Copy, Paste

function PANEL:DoCopy()
    ErrorNoHalt( "Copy not implemented yet" )
end

function PANEL:DoCut()
    ErrorNoHalt( "Cut not implemented yet" )
end

function PANEL:DoPaste()
    ErrorNoHalt( "Paste not implemented yet" )
end

--#endregion Cut, Copy, Paste

--#region Select/Deselect

function PANEL:DoSelectAll()
    ErrorNoHalt( "Select All not implemented yet" )
end

function PANEL:DoDeselectAll()
    ErrorNoHalt( "Deselect All not implemented yet" )
end

--#endregion Select/Deselect

--#endregion Edit Menu

function PANEL:Init()
    local menuBar = vgui.Create( "DMenuBar", self )

    self:AddFileMenu( menuBar )
    self:AddEditMenu( menuBar )
end

--- Called externally to alert the panel that a curve has been opened.
function PANEL:OnCurveOpened()
    self.File.Save:SetEnabled( true )
    self.File.SaveAs:SetEnabled( true )
    self.File.SaveAll:SetEnabled( true )

    self.File.Export:SetEnabled( true )

    self.File.CloseCurve:SetEnabled( true )
    self.File.CloseAllCurves:SetEnabled( true )
end

--- Called externally to alert the panel that a curve has been closed.
function PANEL:OnCurveClosed()
    self.File.Save:SetEnabled( false )
    self.File.SaveAs:SetEnabled( false )
    self.File.SaveAll:SetEnabled( false )

    self.File.Export:SetEnabled( false )

    self.File.CloseCurve:SetEnabled( false )
    self.File.CloseAllCurves:SetEnabled( false )
end


vgui.Register( "CurveLib.Editor.MenuBar.Panel", PANEL, "CurveLib.Editor.PanelBase" )
vguihotload.HandleHotload( "CurveLib.Editor.Frame" )