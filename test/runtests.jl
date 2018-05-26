using PrettyLogging
using Base.Test

L = Logger(STDOUT, 0, "", 1)

logspecial(L, "starting tests", 1)
logmsg(L, "butts")
loghold(L, "processing [")
for i = 1:10
    loghold(L,".")
    L2 = indent(L)
    logmsg(L2, "testing interwoven indentations $i")
end
loghold(L, "]")

logmsg(L, "Done!")
