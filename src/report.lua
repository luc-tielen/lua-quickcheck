
local lib = {}

local function do_report(str) io.write(str) end

function lib.report_success() do_report '.' end
function lib.report_skipped() do_report 'x' end
function lib.report_failed()  do_report 'F' end -- TODO print prop info

return lib

