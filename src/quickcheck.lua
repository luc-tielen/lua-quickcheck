
local lib = {}
lib.properties = {}  -- list of all properties

function lib.check()
  -- TODO finish state machine
  for _, prop in pairs(lib.properties) do
    prop()
  end
end

return lib

