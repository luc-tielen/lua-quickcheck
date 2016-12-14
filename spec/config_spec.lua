local config = require 'lqc.config'
local sort = table.sort


-- Checks if the seed used is within a 1 second margin compared to now
-- Returns true if seed is as expected; otherwise false.
local function is_expected_seed(seed)
  local now = os.time()
  return seed == now or seed == now - 1
end


describe('config handling', function()
  it('should use the default config if no specific value is specified', function()
    local result0 = config.resolve {}
    local result1 = config.resolve { numtests = 100000 }
    local result2 = config.resolve { numshrinks = 100000 }
    local result3 = config.resolve { seed = 123 }
    local result4 = config.resolve { seed = 12345, numtests = 20, numshrinks = 30 }
    local result5 = config.resolve { seed = 12345, numtests = 20, numshrinks = 30,
                                     files_or_dirs = { 'file1', 'file2' } }
    local result6 = config.resolve { seed = 12345, numtests = 20, numshrinks = 30,
                                     files_or_dirs = { 'file1', 'file2' }, colors = true }
    local result7 = config.resolve { check = true, numtests = 20, numshrinks = 30,
                                     files_or_dirs = { 'file1', 'file2' }, colors = true }
    local result8 = config.resolve { check = true, numtests = 20, numshrinks = 30,
                                     files_or_dirs = { 'file1', 'file2' }, colors = true,
                                     threads = 3 }

    local expected0 = { files_or_dirs = { '.' }, seed = os.time(),
                        numtests = 100, numshrinks = 100 }
    local expected1 = { files_or_dirs = { '.' }, seed = os.time(),
                        numtests = 100000, numshrinks = 100 }
    local expected2 = { files_or_dirs = { '.' }, seed = os.time(),
                        numtests = 100, numshrinks = 100000 }
    local expected3 = { files_or_dirs = { '.' }, seed = 123,
                        numtests = 100, numshrinks = 100, colors = false, check = false,
                        threads = 1  }
    local expected4 = { files_or_dirs = { '.' }, seed = 12345,
                        numtests = 20, numshrinks = 30, colors = false, check = false,
                        threads = 1  }
    local expected5 = { seed = 12345, numtests = 20, numshrinks = 30,
                        files_or_dirs = { 'file1', 'file2' }, colors = false, check = false,
                        threads = 1  }
    local expected6 = { seed = 12345, numtests = 20, numshrinks = 30,
                        files_or_dirs = { 'file1', 'file2' }, colors = true, check = false,
                        threads = 1  }
    local expected7 = { seed = os.time(), check = true, numtests = 20, numshrinks = 30,
                        files_or_dirs = { 'file1', 'file2' }, colors = true,
                        threads = 1  }
    local expected8 = { seed = os.time(), check = true, numtests = 20, numshrinks = 30,
                        files_or_dirs = { 'file1', 'file2' }, colors = true,
                        threads = 3 }


    -- 0 -> 2 have to be checked in a more difficult way because the seed
    -- depends on current timestamp

    assert.same(expected0.files_or_dirs, result0.files_or_dirs)
    assert.equal(expected0.numtests, result0.numtests)
    assert.equal(expected0.numshrinks, result0.numshrinks)
    assert.is_true(is_expected_seed(result0.seed))

    assert.same(expected1.files_or_dirs, result1.files_or_dirs)
    assert.equal(expected1.numtests, result1.numtests)
    assert.equal(expected1.numshrinks, result1.numshrinks)
    assert.is_true(is_expected_seed(result1.seed))

    assert.same(expected2.files_or_dirs, result2.files_or_dirs)
    assert.equal(expected2.numtests, result2.numtests)
    assert.equal(expected2.numshrinks, result2.numshrinks)
    assert.is_true(is_expected_seed(result2.seed))

    -- 3 -> 5 are easier to check since seed is not based on time here

    sort(result3)
    sort(result4)
    sort(result5)
    sort(result6)
    sort(result7)
    sort(result8)
    sort(expected3)
    sort(expected4)
    sort(expected5)
    sort(expected6)
    sort(expected7)
    sort(expected8)

    assert.same(expected3, result3)
    assert.same(expected4, result4)
    assert.same(expected5, result5)
    assert.same(expected6, result6)
    assert.same(expected7, result7)
  end)
end)

