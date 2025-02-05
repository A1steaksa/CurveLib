require( "vguihotload" )

---@class CurveLib.Editor.Graph.Panel
PANEL = PANEL

if not PANEL then error( "Failed to load CoordinatesPositioning module of CurveLib.Editor.Graph.Panel" ) return end

-- Returns a rectangle that defines the position and dimensions of the Graph's interior plot
---@return integer x 
---@return integer y
---@return integer Width
---@return integer Height
function PANEL:GetInteriorRect()
    if not self.Caches.InteriorRect then
        local config = self.Config
        local horizontal = config.Axes.Horizontal
        local vertical = config.Axes.Vertical

        local _, horizontalLabelHeight = config:GetLabelSize( horizontal )
        local _, horizontalNumberLineHeight = config:GetNumberLineTextSize( horizontal.NumberLine )

        local verticalLabelWidth, _ = config:GetLabelSize( vertical )
        local verticalNumberLineWidth, _ = config:GetNumberLineTextSize( vertical.NumberLine )

        local interiorRect = {}
        interiorRect.x = vertical.Thickness
            + vertical.NumberLine.AxisMargin
            + verticalNumberLineWidth
            + vertical.NumberLine.LabelMargin
            + verticalLabelWidth
            + vertical.Label.EdgeMargin
        interiorRect.y = vertical.EndMargin

        interiorRect.Width = self:GetWide() - interiorRect.x - horizontal.EndMargin
        interiorRect.Height = self:GetTall()
            - horizontal.Thickness
            - horizontal.NumberLine.AxisMargin
            - horizontalNumberLineHeight
            - horizontal.NumberLine.LabelMargin
            - horizontalLabelHeight
            - horizontal.Label.EdgeMargin
            - horizontal.EndMargin

        self.Caches.InteriorRect = interiorRect
    end

    local rect = self.Caches.InteriorRect
    return rect.x, rect.y, rect.Width, rect.Height
end

-- Converts coordinates from a range of 0-1 (As they are stored in Curves) to the panel-relative coordinates of the Graph's Interior.
---@param x number The X coordinate in the range 0-1
---@param y number The Y coordinate in the range 0-1
function PANEL:NormalizedToInterior( x, y )
    local interiorX, interiorY, interiorWidth, interiorHeight = self:GetInteriorRect()
    return interiorX + ( x * interiorWidth ), interiorY + ( interiorHeight - y * interiorHeight )
end


-- Converts coordinates from the panel-relative coordinates of the Graph's Interior to a range of 0-1 (As they are stored in Curves)
---@param x number The X coordinate, relative to the Graph Panel
---@param y number The Y coordinate, relative to the Graph Panel
function PANEL:PanelToNormalized( x, y )
    local interiorX, interiorY, interiorWidth, interiorHeight = self:GetInteriorRect()
    return ( x - interiorX ) / interiorWidth, 1 - ( y - interiorY ) / interiorHeight
end
