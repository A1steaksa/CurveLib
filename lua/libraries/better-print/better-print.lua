Log = {}

-- The current level of indentation
---@private
Log._IndentLevel = 0

-- Whether the last print was a section ending
---@private
Log._LastPrintWasDone = false

-- Whether to suppress output
---@private
Log._SuppressOutput = true

-- The maximum level of indentation to print
---@private
Log._MaxIndentLevel = 10

-- When debugging a function, this is the level of indentation that 
---@private
Log._DebugStartIndentLevel = 0

-- Whether suppression was enabled when debugging started
Log._DebugStartSuppression = true

---@private
Log._IsDebugging = false

-- Call this function before calling a function you want to see debug output for.
-- This will start printing debug output until the indentation level returns to the level it was at when this function was called. 
function Log.DebugNext()
    Log._DebugStartSuppression = Log._SuppressOutput
    Log.ShouldSuppress( false )
    Log._DebugStartIndentLevel = Log._IndentLevel
    Log._IsDebugging = true

    Log._LastPrintWasDone = false

    Log._InternalPrint( "----------------------" )
    Log._InternalPrint( "Beginning Debug..." )
    Log._InternalPrint( "----------------------" )
end

---@private
function Log.EndDebug()
    Log._InternalPrint( "----------------------" )
    Log._InternalPrint( "Finished Debugging" )
    Log._InternalPrint( "----------------------" )
    Log._InternalPrint( "" )

    Log.ShouldSuppress( Log._DebugStartSuppression )
    Log._IsDebugging = false
end

-- Determines whether future log messages should be printed.
---@param suppress boolean # `true` to prevent log printing, `false` to print log messages.
function Log.ShouldSuppress( suppress )
    Log._SuppressOutput = suppress
end

-- Sets the maximum level of indentation to print.
-- If the current level exceeds this, it will not be printed.
---@param level integer # The maximum level of indentation to allow
function Log.SetMaxIndentLevel( level )
    Log._MaxIndentLevel = level
end

---@private
-- Prints the current indentation string 
---@param indentLevel integer? # The level of indentation to print. [Default: Current Indent Level]
function Log.PrintIndent( indentLevel )
    Msg( string.rep( "    ", indentLevel or Log._IndentLevel ) )
end

-- Indents the output by the specified amount
---@param amount integer? # The amount to indent by. Can be Negative. [Default: 1]
function Log.Indent( amount )
    Log._IndentLevel = Log._IndentLevel + ( amount or 1 )
end

-- Unindents the output by the specified amount
---@param amount integer? # The amount to unindent by. Can be Negative. [Default: 1]
function Log.Unindent( amount )
    Log._IndentLevel = Log._IndentLevel - ( amount or 1 )

    if Log._IsDebugging and Log._IndentLevel == Log._DebugStartIndentLevel then
        Log.EndDebug()
    end
end

function Log.StartSection( name )
    if Log._SuppressOutput then return end
    if Log._IndentLevel >= Log._MaxIndentLevel then return end

    -- Ensure at least one line break between sections
    if Log._LastPrintWasDone then
        MsgN( "" )
        Log._LastPrintWasDone = false
    end

    Log._InternalPrint(  name .. "..." )
    Log.Indent()
end

function Log.EndSection( ... )
    if Log._SuppressOutput then return end
    if Log._IndentLevel >= Log._MaxIndentLevel then return end

    local endingString = "Done"
    local args = { ... }
    if #args > 0 then
        endingString = endingString .. "- " .. table.concat( args, " " )
    end

    Log.PrintIndent(  Log._IndentLevel - 1 )
    MsgN( endingString )

    Log.Unindent()

    Log._LastPrintWasDone = true
end

---@private
function Log._InternalPrint( ... )
    if Log._SuppressOutput then return end
    if Log._IndentLevel >= Log._MaxIndentLevel then return end

    Log.PrintIndent()

    local args = { ... }
    for i = 1, #args do
        Msg( tostring( args[i] ) )
        if i < #args then
            Msg( "\t" )
        end
    end
    MsgN()
end

-- Prints the specified arguments to the console
function Log.Print( ... )
    if Log._SuppressOutput then return end
    if Log._IndentLevel >= Log._MaxIndentLevel then return end

    Log._LastPrintWasDone = false

    Log._InternalPrint( ... )
end