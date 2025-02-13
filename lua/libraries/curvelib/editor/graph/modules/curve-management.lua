require( "vguihotload" )
if not PANEL then vguihotload.HandleMultipartPanelHotload( "CurveLib.Editor.Graph.Panel" ) return end

---@class CurveLib.Editor.Graph.Panel
---@field CurrentCurve CurveData The Curve currently being edited
PANEL = PANEL

---@param curve CurveData
function PANEL:OpenCurve( curve )
    self.CurrentCurve = curve

    self:UpdateHandles()
end

function PANEL:CloseCurve()
    self.CurrentCurve = nil
    self:ClearHandles()
end