if not _G.CurveLib then error("Cannot initialize Curve Popups - CurveLib not found") return end

---@class CurveLib
local CurveLib = _G.CurveLib
CurveLib.Popups = {}

function CurveLib.Popups.LoadFile( callback )
    local frame = vgui.Create( "BFrame" )
    frame:SetSize( 600, 440 )
    frame:Center()
    frame:SetTitle( "Load Curve" )
    frame:MakePopup()

    local framePanel = vgui.Create( "DPanel", frame )
    framePanel:Dock( FILL )

    local fileBrowser = vgui.Create( "DFileBrowser", framePanel )
    fileBrowser:Dock( TOP )
    fileBrowser:SetPath( "GAME" )
    fileBrowser:SetBaseFolder( "data" )
    fileBrowser:SetOpen( true )
    fileBrowser:SetSize( 0, 350 )

    local bottomPanel = vgui.Create( "DPanel", framePanel )
    bottomPanel:Dock( TOP )

    local filePathEntry = vgui.Create( "DTextEntry", bottomPanel )
    filePathEntry:Dock( TOP )
    filePathEntry:SetPlaceholderText( "File Name" )

    local buttonPanel = vgui.Create( "DPanel", bottomPanel )
    buttonPanel:Dock( TOP )
    bottomPanel:SetTall( 50 )

    local cancelButton = vgui.Create( "BButton", buttonPanel )
    cancelButton:Dock( RIGHT )
    cancelButton:SetText( "Cancel" )
    cancelButton.DoClick = function()
        frame:Close()
    end

    local loadButton = vgui.Create( "BButton", buttonPanel )
    loadButton:Dock( RIGHT )
    loadButton:DockMargin( 0, 0, 8, 0 )
    loadButton:SetText( "Load" )
    loadButton.DoClick = function()
        local path = filePathEntry:GetText()
        if not path or path == "" then return end

        frame:Close()

        if callback then
            callback( path )
        end
    end


    fileBrowser.OnSelect = function( _, path, _ )
        filePathEntry:SetText( path )
    end

    fileBrowser.OnDoubleClick = function( _, path, _ )
        filePathEntry:SetText( path )
        loadButton:DoClick()
    end
end

function CurveLib.Popups.SaveFile( callback )
    local frame = vgui.Create( "BFrame" )
    frame:SetSize( 600, 440 )
    frame:Center()
    frame:SetTitle( "Save Curve" )
    frame:MakePopup()

    local framePanel = vgui.Create( "DPanel", frame )
    framePanel:Dock( FILL )

    local fileBrowser = vgui.Create( "DFileBrowser", framePanel )
    fileBrowser:Dock( TOP )
    fileBrowser:SetPath( "GAME" )
    fileBrowser:SetBaseFolder( "data" )
    fileBrowser:SetOpen( true )
    fileBrowser:SetSize( 0, 350 )
    fileBrowser:SetCurrentFolder( "data" )

    local bottomPanel = vgui.Create( "DPanel", framePanel )
    bottomPanel:Dock( TOP )

    local filePathEntry = vgui.Create( "DTextEntry", bottomPanel )
    filePathEntry:Dock( TOP )
    filePathEntry:SetPlaceholderText( "File Name" )

    local buttonPanel = vgui.Create( "DPanel", bottomPanel )
    buttonPanel:Dock( TOP )
    bottomPanel:SetTall( 50 )

    local cancelButton = vgui.Create( "BButton", buttonPanel )
    cancelButton:Dock( RIGHT )
    cancelButton:SetText( "Cancel" )
    cancelButton.DoClick = function()
        frame:Close()
    end

    local saveButton = vgui.Create( "BButton", buttonPanel )
    saveButton:Dock( RIGHT )
    saveButton:DockMargin( 0, 0, 8, 0 )
    saveButton:SetText( "Save" )
    saveButton.DoClick = function()
        local path = filePathEntry:GetText()
        if not path or path == "" then return end

        frame:Close()

        if callback then
            callback( path )
        end
    end

    fileBrowser.OnSelect = function( _, path, _ )
        filePathEntry:SetText( path )
    end

    fileBrowser.OnDoubleClick = function( _, path, _ )
        filePathEntry:SetText( path )
        saveButton:DoClick()
    end
end
