print( "Curve Point Loaded" )

---@class Curve.CurvePoint : table
---@field MainPoint Vector
---@field LeftHandle Vector?
---@field RightHandle Vector?
local metatable = {
    MainPoint   = Vector( 0, 0, 0 ),
    LeftHandle  = nil,
    RightHandle = nil
}
metatable.__index = metatable

function metatable:HasLeftHandle()
    return self.LeftHandle and isvector( self.LeftHandle )
end

function metatable:HasRightHandle()
    return self.RightHandle and isvector( self.RightHandle )
end

function CurvePoint()
    local curvePoint = {}
    setmetatable( curvePoint, metatable )
    return curvePoint
end