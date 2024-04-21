AddCSLuaFile()

---@class Curve
local curves = {}
curves.__index = curves

function curves:Evaluate( x )
    print( x )
end

--- Creates a new Curve
function Curve()
    local curve = {}
    setmetatable( curve, curves )

    return curve
end

