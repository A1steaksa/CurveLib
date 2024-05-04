---@class CurveUtils
local utils = {}

-- Created here to avoid creating the table every time MultiFloor is called
local multifloor_buffer = {}

-- Rounds a variable set of numbers to their nearest integer and multi-returns them.
-- Thanks to SneakySquid for the optimizations.
---@vararg number
function utils.MultiFloor( ... )
    local arg_count = select( "#", ... )

    for i = 1, arg_count do
        multifloor_buffer[i] = math.floor( select( i, ... ) )
    end

    return unpack( multifloor_buffer, 1, arg_count )
end

return utils