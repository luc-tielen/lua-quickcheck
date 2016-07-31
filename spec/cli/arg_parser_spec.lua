local p = require 'src.cli.arg_parser'


-- Checks if the seed used is within a 1 second margin compared to now
-- Returns true if seed is as expected; otherwise false.
local function is_expected_seed(seed)
  local now = os.time()
  return seed == now or seed == now - 1
end


describe('arg parser', function()
  it('should parse correct arguments and return the resulting values', function()
    local args1 = p.parse({})
    assert.same(args1.files_or_dirs, { '.' })
    assert.same(args1.numtests, 100)
    assert.same(args1.numshrinks, 100)
    assert.is_true(is_expected_seed(args1.seed))

    local args2 = p.parse({ 'a' })
    assert.same(args2.files_or_dirs, { 'a' })
    assert.same(args2.numtests, 100)
    assert.same(args2.numshrinks, 100)
    assert.is_true(is_expected_seed(args2.seed))

    local args3 = p.parse({ 'a', 'b' })
    assert.same(args3.files_or_dirs, { 'a', 'b' })
    assert.same(args3.numtests, 100)
    assert.same(args3.numshrinks, 100)
    assert.is_true(is_expected_seed(args3.seed))


    local args4 = p.parse({ 'a', 'b', '-s', '123' })
    assert.same(args4.files_or_dirs, { 'a', 'b' })
    assert.same(args4.numtests, 100)
    assert.same(args4.numshrinks, 100)
    assert.same(args4.seed, 123)

    local args5 = p.parse({ 'a', 'b', '--seed', '123' })
    assert.same(args5.files_or_dirs, { 'a', 'b' })
    assert.same(args5.numtests, 100)
    assert.same(args5.numshrinks, 100)
    assert.same(args5.seed, 123)

    local args6 = p.parse({ 'a', 'b', '--seed', '123', '--numtests', '5' })
    assert.same(args6.files_or_dirs, { 'a', 'b' })
    assert.same(args6.numtests, 5)
    assert.same(args6.numshrinks, 100)
    assert.same(args6.seed, 123)

    local args7 = p.parse({ 'a', 'b', '--seed', '123', 
                            '--numtests', '5', '--numshrinks', '3' })
    assert.same(args7.files_or_dirs, { 'a', 'b' })
    assert.same(args7.numtests, 5)
    assert.same(args7.numshrinks, 3)
    assert.same(args7.seed, 123)
  end)

  it('raises an error if invalid options are specified', function()
    assert.is_false(pcall(function() p.parse({ '.', '--invalid', 'value' }) end))
    assert.is_false(pcall(function() p.parse({ '.', '--seed', 'abc' }) end))
    assert.is_false(pcall(function() p.parse({ '--numtests', '-1' }) end))
    assert.is_false(pcall(function() p.parse({ '--numshrinks', '-1' }) end))
  end)
end)

