require( "vguihotload" )

---@class CurveLib.Editor.Graph.Panel
---@field CurrentCurve CurveData The Curve currently being edited
PANEL = PANEL

if not PANEL then
    vguihotload.HandleMultipartPanelHotload( "CurveLib.Editor.Graph.Panel" )
    return
end

---@param curve CurveData
function PANEL:OpenCurve( curve )
    self.CurrentCurve = curve

    self:UpdateHandles()
end

function PANEL:CloseCurve()
    self.CurrentCurve = nil
    self:ClearHandles()
end