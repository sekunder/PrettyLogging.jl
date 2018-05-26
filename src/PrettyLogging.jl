"""
    PrettyLogging

A module to help simplify "verbose" output from complicated functions/scripts.

Goal for usage:
```julia
function complicatedfun(a, b; verbose=0, kwargs...)
    # do some preprocessing
    @logmsg "preprocessing complete"
    # now call a subroutine
    @logmsg foo(b)

end
```
"""
module PrettyLogging

const INDENT_WIDTH = 2
const INDENT = "  "
const START = "<<< "
const END = ">>> "
const IMPORTANT = "* "
const ERROR = "! "
const DATE_FMT = "YYYY mm dd HH:MM:SS"

"""
    Logger

Object that handles writing log messages
"""
mutable struct Logger
    io::IO
    disp::Int # display threshold; all messages get flushed to io but not necessarily printed to stdout
    hold
    indent::Int
end
Logger(filename="$(@__FILE__).$(myid()).log"; disp=0) = Logger(open(filename, "a"), disp, "", 1)

"""
    indent(L::Logger)

Returns a new `Logger` with the same IO stream and display settings and indentation
increased by 1. Makes it easy to have output from nested function calls indented, if
desired. Clears the `hold` field.

"""
indent(L::Logger) = Logger(L.io, L.disp, "", L.indent+1)

"""
    logmsg(L::logger, m, v=0; timestamp=true)

Write message `m` to the log file (i.e. `L.io`). If `L` is holding any messages, flush that
message to the log file as well and clear the hold. If `v <= L.disp`, print the output to
`STDOUT` as well.

"""
function logmsg(L::Logger, m, v=0; note=INDENT)
    flushhold(L)
    msg = "$(ts()) $note$(spaces(L.indent-1))$m"
    println(L.io, msg)
    if v <= L.disp
        println(msg)
    end
end
logerr(L::Logger, m, v=0) = logmsg(L, m, v; note=ERROR)
logspecial(L::Logger, m, v=0) = logmsg(L, m, v; note=IMPORTANT)

function loghold(L::Logger, m; extra_space=0)
    if length(L.hold) == 0
        L.hold = ts() * " " * spaces(L.indent + extra_space)
    end
    L.hold = L.hold * m
end

function flushhold(L::Logger)
    if length(L.hold) > 0
        println(L.io, L.hold)
        L.hold = ""
    end
end

"""
    ts()

Returns the current time as a formatted string for logging purposes.
"""
ts(fmt=DATE_FMT) = Dates.format(now(), fmt)

spaces(n=1) = INDENT ^ n

export Logger, indent,
       logmsg, logerr, logspecial, loghold,
       ts

end # module
