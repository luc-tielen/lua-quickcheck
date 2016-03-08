
local lib = {}

function lib.report_success()
  io.write '.'
end

function lib.report_skipped()
  io.write 'x'
end

function lib.report_failed()
  io.write 'F'  -- TODO print prop info
end

return lib

