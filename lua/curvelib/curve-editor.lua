AddCSLuaFile()
if SERVER then return end
require( "vguihotload" )

--[[ Enums and Constants ]]--
--#region

local COLOR_BACKGROUND = Color( 60, 60, 60 )
local COLOR_AXIS = Color( 200, 200, 200 )
local COLOR_AXIS_GRID = Color( 100, 100, 100 )
local COLOR_AXIS_LABEL = Color( 200, 200, 200 )


--#endregion

--[[ Fonts ]]--
--#region

surface.CreateFont( "CurveEditor_AxisLabel", {
    font = "Roboto Regular",
    extended = false,
    size = 28,
    weight = 500,
} )

surface.CreateFont( "CurveEditor_AxisNumber_Large", {
    font = "Roboto Regular",
    extended = false,
    size = 24,
    weight = 500,
} )

surface.CreateFont( "CurveEditor_AxisNumber_Small", {
    font = "Roboto Regular",
    extended = false,
    size = 16,
    weight = 500,
} )

--#endregion

--[[ Utils ]]--
--#region

-- Created here to avoid creating the table every time MultiFloor is called
local multifloor_buffer = {}

-- Rounds a variable set of numbers to their nearest integer and multi-returns them.
---@vararg number
local function MultiFloor( ... )
    local arg_count = select( "#", ... )

    for i = 1, arg_count do
        multifloor_buffer[i] = math.floor( select( i, ... ) )
    end

    return unpack( multifloor_buffer, 1, arg_count )
end

--#endregion [Utils]

--[[ Curve Editor ]]--
--#region
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
                LargeMargin = 23,
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
                LargeMargin = 23,
                SpaceBetween = 256
            }
        }
    }
}

function PANEL:GetGraphMinsMaxs()
    local width, height = self:GetSize()

    local minX = self.Axis.Vertical.Margins.Left
    + math.floor( self.Axis.Vertical.Width / 2 ) -- Line width should be taken into account

    local minY = height - self.Axis.Horizontal.Margins.Bottom
    - math.floor( self.Axis.Horizontal.Width / 2 ) -- Line width should be taken into account

    local mins = Vector( minX, minY )
    local maxs = Vector( width - self.Axis.Horizontal.Margins.Right, self.Axis.Vertical.Margins.Top )

    return mins, maxs
end

-- Draws a line by drawing a UV'd quad
---@param startX number
---@param startY number
---@param endX number
---@param endY number
---@param lineWidth number
function PANEL:DrawLine( startX, startY, endX, endY, lineWidth, color )
    startX, startY, endX, endY = MultiFloor( startX, startY, endX, endY )

    local startPos  = Vector( startX, startY )
    local endPos    = Vector( endX, endY )

    local direction = (endPos - startPos):GetNormalized()

    local perpendicularDirection = Vector( direction.y, direction.x )
    local vertexOffsetAmount = math.max( math.floor( lineWidth/2 ), 1 )
    
    local sideOffset = perpendicularDirection * vertexOffsetAmount

    -- In this function we're going to assuming "forward" is the 
    -- direction from the start position to the end position.
    -- "Left" and "Right" are relative to that forward direction.

    -- The left side of the quad as normal
    local startLeft  = startPos  + Vector(  sideOffset.x, -sideOffset.y )
    local endLeft    = endPos    + Vector(  sideOffset.x, -sideOffset.y )
    
    -- Our default case is when the line width is extremely low
    local startRight = startPos
    local endRight   = endPos
    
    -- The more common case is that our line is thick
    if lineWidth > 2 then
        startRight = startPos  + Vector( -sideOffset.x,  sideOffset.y )
        endRight   = endPos    + Vector( -sideOffset.x,  sideOffset.y )
    end

    local matrix = Matrix()
    local framePos = Vector( self:LocalToScreen( 0, 0 ) )
    matrix:SetTranslation( framePos )

    cam.Start2D()
    cam.PushModelMatrix( matrix )

    render.DrawQuad( endLeft, endRight, startRight, startLeft, color )

    cam.PopModelMatrix()
    cam.End2D()
end

function PANEL:DrawCenteredText( text, textX, textY, rotation )
    if not rotation then rotation = 0 end

    local textWidth, textHeight = surface.GetTextSize( text )

    local frameX, frameY = self:LocalToScreen( 0, 0 )

    local matrix = Matrix()
    matrix:Translate( Vector( frameX, frameY ) )
    matrix:Translate( Vector( textX, textY ) )
    matrix:Rotate( Angle( 0, rotation, 0 ) )
    matrix:Translate( Vector( -math.floor( textWidth / 2 ), -math.floor( textHeight / 2 ) ) )
    
    cam.Start2D()
    cam.PushModelMatrix( matrix, false )

    surface.SetTextPos( 0, 0 )
    surface.DrawText( text )
    
    cam.PopModelMatrix()
    cam.End2D()
    
end

-- Takes a number range and draws it in a line
-- Note: This will always draw at least 2 labels.  One for the start and one for the end.
---@param startX number
---@param startY number
---@param endX number
---@param endY number
---@param startNumber number
---@param endNumber number
---@param middleLabelCount integer
function PANEL:DrawNumberLine( startX, startY, endX, endY, startNumber, endNumber, middleLabelCount )
    startX, startY, endX, endY = MultiFloor( startX, startY, endX, endY )

    surface.SetTextColor( COLOR_AXIS_LABEL )

    surface.SetFont( "CurveEditor_AxisNumber_Large" )
    self:DrawCenteredText( startNumber, startX, startY )
    self:DrawCenteredText( endNumber, endX, endY )

    local startPos = Vector( startX, startY )
    local endPos = Vector( endX, endY )

    local distance = startPos:Distance2D( endPos )
    local labelInterval = math.floor( distance / middleLabelCount )

    local direction = ( endPos - startPos ):GetNormalized()

    surface.SetFont( "CurveEditor_AxisNumber_Small" )
    for i = 1, ( middleLabelCount - 1 ) do
        local pos = startPos + direction * ( i * labelInterval )
        
        local number = Lerp( i / middleLabelCount, startNumber, endNumber )
        local formattedNumber = string.format( "%.2f", number )

        self:DrawCenteredText( formattedNumber, pos.x, pos.y )
    end

end

function PANEL:DrawGrid()
    local width, height = self:GetSize()
    local mins, maxs = self:GetGraphMinsMaxs()



end

function PANEL:DrawAxis()
    local width, height = self:GetSize()
    local mins, maxs = self:GetGraphMinsMaxs()

    --[[ Vertical Axis ]]--
    -- Axis line
    render.SetColorMaterial()
    self:DrawLine( mins.x, mins.y, mins.x, maxs.y, self.Axis.Vertical.Width, COLOR_AXIS )

    -- Numbers
    local verticalLabelCount = math.ceil( height / self.Axis.Vertical.NumberLine.SpaceBetween )
    self:DrawNumberLine(
        mins.x - self.Axis.Vertical.NumberLine.LargeMargin,
        mins.y,
        mins.x - self.Axis.Vertical.NumberLine.LargeMargin,
        maxs.y,
        0, 1,
        verticalLabelCount
    )

    -- Label
    surface.SetFont( "CurveEditor_AxisLabel" )
    local verticalCenter = mins.y + math.floor( ( maxs.y - mins.y ) / 2 )
    self:DrawCenteredText(
        self.Axis.Vertical.Label.Text,
        mins.x - self.Axis.Vertical.NumberLine.LargeMargin - self.Axis.Vertical.Label.RightMargin,
        verticalCenter,
        self.Axis.Vertical.Label.Rotation
    )

    --[[ Horizontal Axis ]]--
    -- Axis line
    -- One of the two axis lines needs to extend backwards a little bit to cover the gap between them
    local originCoverOffset = math.ceil( self.Axis.Vertical.Width / 2 )
    render.SetColorMaterial()
    self:DrawLine( mins.x - originCoverOffset, mins.y, maxs.x, mins.y, self.Axis.Horizontal.Width, COLOR_AXIS )

    -- Numbers
    local horizontalLabelCount = math.ceil( width / self.Axis.Horizontal.NumberLine.SpaceBetween )
    self:DrawNumberLine(
        mins.x,
        mins.y + self.Axis.Horizontal.NumberLine.LargeMargin,
        maxs.x,
        mins.y + self.Axis.Horizontal.NumberLine.LargeMargin,
        0, 1,
        horizontalLabelCount
    )

    -- Label
    surface.SetFont( "CurveEditor_AxisLabel" )
    local horizontalCenter = mins.x + math.floor( ( maxs.x - mins.x ) / 2 )
    self:DrawCenteredText( 
        self.Axis.Horizontal.Label.Text,
        horizontalCenter,
        mins.y + self.Axis.Horizontal.NumberLine.LargeMargin + self.Axis.Horizontal.Label.TopMargin,
        self.Axis.Horizontal.Label.Rotation
    )
end

function PANEL:Paint( width, height )
    surface.SetDrawColor( COLOR_BACKGROUND )
    surface.DrawRect( 0, 0, width, height )

    self:DrawAxis()
end

vgui.Register( "CurveEditor", PANEL, "Panel" )

--#endregion [CurveEditor]

local minWidth, minheight = 512, 512

local function OpenCurveEditor()
    local frame = vgui.Create( "DFrame" )
    frame:SetTitle( "Curve Editor" )
    frame:SetSize( minWidth, minheight )
    frame:SetMinimumSize( minWidth, minheight )
    frame:SetSizable( true )
    frame:Center()

    local editor = vgui.Create( "CurveEditor", frame )
    editor:Dock( FILL )

    frame:MakePopup()

    return frame
end

concommand.Add( "curvelib_openeditor", function()
    vguihotload.Register( "CurveEditor", OpenCurveEditor )
end )

vguihotload.HandleHotload( "CurveEditor" )