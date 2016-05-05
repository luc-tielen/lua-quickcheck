
local lib = {}

local function format_table(t)
  local result = '{ '
  for _, v in ipairs(t) do 
    local type_v = type(v)
    if type_v == 'table' then
      result = result .. format_table(v) .. ' '
    elseif type_v == 'boolean' then
      result = result .. (v and 'true ' or 'false ')
    else
      result = result .. v .. ' '
    end
  end
  return result .. '}'
end

function lib.report(s) io.write(s) end

function lib.report_success() lib.report '.' end
function lib.report_skipped() lib.report 'x' end
function lib.report_failed(prop, generated_values, shrunk_values)
  lib.report 'F\n\n'
  lib.report('Property "' .. prop.description .. '" failed!\n')
  lib.report('Generated values = ' .. format_table(generated_values) .. '\n')
  lib.report('Shrank to = ' .. format_table(shrunk_values) .. '\n')
end -- TODO print prop info

return lib

