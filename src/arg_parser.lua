
-- Module for easily parsing list of command line arguments

local lib = {}

-- Helper function to check if table t contains a value v
local function contains(t, v)
    for _, val in ipairs(t) do
        if v == val then return true end
    end
    return false
end

local function parse_switches(switches)
    if not switches then return {} end

    local result = {}
    for switch_name, variants in pairs(switches) do
        for _, arg_val in ipairs(arg) do
            if contains(variants, arg_val) then
                result[switch_name] = true
                break
            end
        end
    end
    return result
end

local function parse_options(options)
    if not options then return {} end
    local result = {}
    for opt_name, variants in pairs(options) do
        for idx, arg1 in ipairs(arg) do
            local arg2 = arg[idx + 1]
            if not arg2 then break end  -- end of arg list
            -- check if arg2 isn't an option or switch
            if string.find(arg2, "-") ~= 1 
                and contains(variants, arg1)  then
                result[opt_name] = arg2
                break
            end
        end
    end
    return result
end

local function merge_tables(t1, t2)
    for k, v in pairs(t1) do
        t2[k] = v
    end
    return t2
end

-- INPUT = ARRAY (TABLE) = ARGV, CONFIG SUPPLIED BY USER
-- OUTPUT = TABLE WITH KEY, VALUE PAIRS
function lib.parse_args(opts)
    local result1 = parse_switches(opts.switches)
    local result2 = parse_options(opts.options)
    return merge_tables(result1, result2)
end

return lib

