local p = require('src/arg_parser')

local function print_table(table)
    print "{"
    for k, v in pairs(table) do
        print("  key = " .. tostring(k) .. ", value = " .. tostring(v))
    end
    print "}"
end

local function table_eq(t1, t2)
    local type1, type2 = type(t1), type(t2)
    if type1 ~= type2 then return false end
    if type1 ~= "table" then return false end

    local key_set = {}
    for key1, val1 in pairs(t1) do
        local val2 = t2[key1]
        if val1 ~= val2 then return false end
        key_set[key1] = true
    end
    for key2, _ in pairs(t2) do
        -- Check if key2 is not in keys from t1
        if not key_set[key2] then return false end
    end

    return true
end

do
    local config = {
        switches = {help={"-h", "--help"}}, 
        options = {seed={"--seed", "-s"}}
    }

    arg = {"--help"}
    local x = p.parse_args(config)
    assert(table_eq(x, {help = true}))

    arg = {}
    x = p.parse_args(config)
    assert(table_eq(x, {}))

    arg = {"-h"}
    x = p.parse_args(config)
    assert(table_eq(x, {help = true}))

    arg = {"-v"}  -- unsupported
    x = p.parse_args(config)
    assert(table_eq(x, {}))

    arg = {"--seed", "123456789"}
    x = p.parse_args(config)
    assert(table_eq(x, {seed = "123456789"}))

    arg = {"-s", "123456789"}
    x = p.parse_args(config)
    assert(table_eq(x, {seed = "123456789"}))

    arg = {"--invalid", "-v"}  -- unsupported
    x = p.parse_args(config)
    assert(table_eq(x, {}))

    arg = {"--seed"}  -- invalid
    x = p.parse_args(config)
    assert(table_eq(x, {}))

    arg = {"--invalid", "-s", "abcdef"}  -- invalid
    x = p.parse_args(config)
    print_table(x)
    assert(table_eq(x, {seed = "abcdef"}))
end

