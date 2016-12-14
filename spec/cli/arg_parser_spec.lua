local p = require 'lqc.cli.arg_parser'


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
    assert.same(args1.colors, false)
    assert.same(args1.check, false)
    assert.same(args1.threads, 1)

    local args2 = p.parse({ 'a' })
    assert.same(args2.files_or_dirs, { 'a' })
    assert.same(args2.numtests, 100)
    assert.same(args2.numshrinks, 100)
    assert.is_true(is_expected_seed(args2.seed))
    assert.same(args2.colors, false)
    assert.same(args2.check, false)
    assert.same(args2.threads, 1)

    local args3 = p.parse({ 'a', 'b' })
    assert.same(args3.files_or_dirs, { 'a', 'b' })
    assert.same(args3.numtests, 100)
    assert.same(args3.numshrinks, 100)
    assert.is_true(is_expected_seed(args3.seed))
    assert.same(args3.colors, false)
    assert.same(args3.check, false)
    assert.same(args3.threads, 1)

    local args4 = p.parse({ 'a', 'b', '-s', '123' })
    assert.same(args4.files_or_dirs, { 'a', 'b' })
    assert.same(args4.numtests, 100)
    assert.same(args4.numshrinks, 100)
    assert.same(args4.seed, 123)
    assert.same(args4.colors, false)
    assert.same(args4.check, false)
    assert.same(args4.threads, 1)

    local args5 = p.parse({ 'a', 'b', '--seed', '123' })
    assert.same(args5.files_or_dirs, { 'a', 'b' })
    assert.same(args5.numtests, 100)
    assert.same(args5.numshrinks, 100)
    assert.same(args5.seed, 123)
    assert.same(args5.colors, false)
    assert.same(args5.check, false)
    assert.same(args5.threads, 1)

    local args6 = p.parse({ 'a', 'b', '--seed', '123', '--numtests', '5' })
    assert.same(args6.files_or_dirs, { 'a', 'b' })
    assert.same(args6.numtests, 5)
    assert.same(args6.numshrinks, 100)
    assert.same(args6.seed, 123)
    assert.same(args6.colors, false)
    assert.same(args6.check, false)
    assert.same(args6.threads, 1)

    local args7 = p.parse({ 'a', 'b', '--seed', '123',
                            '--numtests', '5', '--numshrinks', '3' })
    assert.same(args7.files_or_dirs, { 'a', 'b' })
    assert.same(args7.numtests, 5)
    assert.same(args7.numshrinks, 3)
    assert.same(args7.seed, 123)
    assert.same(args7.colors, false)
    assert.same(args7.check, false)
    assert.same(args7.threads, 1)

    local args8 = p.parse({ 'a', 'b', '--seed', '123',
                            '--numtests', '5', '--numshrinks', '3',
                            '-c' })
    assert.same(args8.files_or_dirs, { 'a', 'b' })
    assert.same(args8.numtests, 5)
    assert.same(args8.numshrinks, 3)
    assert.same(args8.seed, 123)
    assert.same(args8.colors, true)
    assert.same(args8.check, false)
    assert.same(args8.threads, 1)

    local args9 = p.parse({ 'a', 'b', '--seed', '123',
                            '--numtests', '5', '--numshrinks', '3',
                            '--colors' })
    assert.same(args9.files_or_dirs, { 'a', 'b' })
    assert.same(args9.numtests, 5)
    assert.same(args9.numshrinks, 3)
    assert.same(args9.seed, 123)
    assert.same(args9.colors, true)
    assert.same(args9.check, false)
    assert.same(args9.threads, 1)

    local args10 = p.parse({ 'a', 'b', '--numtests', '5', '--numshrinks', '3',
                             '--colors', '--check' })
    assert.same(args10.files_or_dirs, { 'a', 'b' })
    assert.same(args10.numtests, 5)
    assert.same(args10.numshrinks, 3)
    assert.same(args10.colors, true)
    assert.same(args10.check, true)
    assert.same(args10.threads, 1)

    local args11 = p.parse({ 'a', 'b', '--numtests', '5', '--numshrinks', '3',
                             '--colors', '--check', '--threads', '3'})
    assert.same(args11.files_or_dirs, { 'a', 'b' })
    assert.same(args11.numtests, 5)
    assert.same(args11.numshrinks, 3)
    assert.same(args11.colors, true)
    assert.same(args11.check, true)
    assert.same(args11.threads, 3)

    local args12 = p.parse({ 'a', 'b', '--numtests', '5', '--numshrinks', '3',
                             '--colors', '--check', '-t', '3'})
    assert.same(args12.files_or_dirs, { 'a', 'b' })
    assert.same(args12.numtests, 5)
    assert.same(args12.numshrinks, 3)
    assert.same(args12.colors, true)
    assert.same(args12.check, true)
    assert.same(args12.threads, 3)

    assert.is_false(pcall(function()
      -- --check and --seed or mutual exclusive!
      p.parse({ 'a', 'b', '--seed', '123',
                '--numtests', '5', '--numshrinks', '3',
                '--colors', '--check', '--threads', '5' })
    end))
  end)

  it('raises an error if invalid options are specified', function()
    assert.is_false(pcall(function() p.parse({ '.', '--invalid', 'value' }) end))
    assert.is_false(pcall(function() p.parse({ '.', '--seed', 'abc' }) end))
    assert.is_false(pcall(function() p.parse({ '--numtests', '-1' }) end))
    assert.is_false(pcall(function() p.parse({ '--numshrinks', '-1' }) end))
  end)
end)

