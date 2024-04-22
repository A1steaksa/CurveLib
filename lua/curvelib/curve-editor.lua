AddCSLuaFile()
if SERVER then return end

require( "vguihotload" )
include( "curvelib/curve.lua" )

---@type CurveDraw
local curveDraw = include( "includes/curvedraw.lua" )

---@class CurveEditor: DPanel
local PANEL = {
    Axis = {
        Horizontal = {
            Width = 1,
            Margins = {
                Bottom  = 65,
                Right   = 30
            },
            Label = {
                Text = "Time",
                Rotation = 0,
                TopMargin = 25
            },
            NumberLine = {
                Margins = {
                    LargeText = 23,
                    SmallText = 18
                },
                SpaceBetween = 256
            }
        },

        Vertical = {
            Width = 1,
            Margins = {
                Top     = 35,
                Left    = 85
            },
            Label = {
                Text = "Position",
                Rotation = -90,
                RightMargin = 40
            },
            NumberLine = {
                Margins = {
                    LargeText = 23,
                    SmallText = 18
                },
                SpaceBetween = 256
            }
        }
    }
}

function PANEL:GetGraphMinsMaxs()
    local width, height = self:GetSize()

    local minX = self.Axis.Vertical.Margins.Left
    + math.floor( self.Axis.Vertical.Width / 2 ) -- Line width

    local minY = height - self.Axis.Horizontal.Margins.Bottom
    - math.floor( self.Axis.Horizontal.Width / 2 ) -- Line width

    local mins = Vector( minX, minY )
    local maxs = Vector( width - self.Axis.Horizontal.Margins.Right, self.Axis.Vertical.Margins.Top )

    return mins, maxs
end

function PANEL:Paint( width, height )
    surface.SetDrawColor( curveDraw.Colors.Background )
    surface.DrawRect( 0, 0, width, height )

    local curve = Curve()

    curveDraw.PushOrigin( self:LocalToScreen( 0, 0 ) )
    curveDraw.DrawGraph( self, curve )
    curveDraw.PopOrigin()
end

vgui.Register( "CurveEditor", PANEL, "Panel" )

vguihotload.HandleHotload( "CurveEditor" )