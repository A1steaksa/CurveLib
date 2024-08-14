if not _G.CurveLib then error("Cannot initialize Curve Addons - CurveLib not found") return end

---@class CurveLib
---@field Addons table
local CurveLib = _G.CurveLib
CurveLib.Addons = CurveLib.Addons or {}

---Register an addon with the CurveLib so that it can be used in the curve editor  
---**Note:** If the editor is not present, registration does nothing.
---@param name string The name and unique identifier of the addon.
---@param curves CurveLib.Curve.Data[]|function():CurveLib.Curve.Data[] The curves to register. Can be a table of curves or a function that returns a table of curves.
function CurveLib.RegisterAddon( name, curves )
    if not curves then
        error( "Cannot register addon with nil curves" )
    end

    if( not ( istable( curves ) or isfunction( curves ) ) ) then
        error( "Registered curves must be a table or function" )
    end

    name = name:Trim()

    if CurveLib.Addons[ name ] then
        error( "Addon \"" .. name .. "\" already registered" )
    end

    if string.len( name ) == 0 then
        error( "Addon name cannot be empty" )
    end

    CurveLib.Addons[ name ] = curves
end

---@param name string The name of the addon to unregister
function CurveLib.UnregisterAddon( name )
    CurveLib.Addons[ name ] = nil
end

---@param name string The name of the addon to check
function CurveLib.IsAddonRegistered( name )
    return CurveLib.Addons[ name ] ~= nil
end

---@return boolean # True if there are registered addons, false otherwise
function CurveLib.HasRegisteredAddons()
    return table.Count( CurveLib.Addons ) > 0
end

---@return table # All registered addons, indexed by name
function CurveLib.GetRegisteredAddons()
    return CurveLib.Addons
end

---Gets the curves for an addon
---@param name string The name of the addon
---@return CurveLib.Curve.Data[]
function CurveLib.GetAddonCurves( name )
    local curves = CurveLib.Addons[name]

    if not curves then
        error( "Addon " .. name .. " not found" )
    end

    if isfunction( curves ) then
        curves = curves()
    end

    return curves

end