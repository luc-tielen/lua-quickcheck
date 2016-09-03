local ThreadPool = require 'lqc.threading.thread_pool'
local filter = require 'lqc.helpers.filter'


local function contains(t, v)
  return #filter(t, function(val) return v == val end) ~= 0
end

describe('thread pool', function()
  it('requires a number of threads > 0 to create a pool', function()
    local pool = ThreadPool.new(1)
    pool:join()
    assert.is_false(pcall(function() ThreadPool.new() end))
    assert.is_false(pcall(function() ThreadPool.new('invalid') end))
    assert.is_false(pcall(function() ThreadPool.new(false) end))
    assert.is_false(pcall(function() ThreadPool.new({}) end))
    assert.is_false(pcall(function() ThreadPool.new(function() end) end))
  end)

  it('is possible to schedule work items onto threads of thread pool', function()
    -- NOTE: can't check if functions are called since deep copies are made
    -- across threads
    local pool = ThreadPool.new(2)
    pool:schedule(function() end)
    pool:schedule(function() end)
    pool:join()
  end)

  it('can properly clean itself up regardless of amount of work', function()
    -- same number of items as threads
    local pool1 = ThreadPool.new(2)
    pool1:schedule(function() end)
    pool1:schedule(function() end)
    pool1:join()

    -- less number of items than threads
    local pool2 = ThreadPool.new(2)
    pool2:schedule(function() end)
    pool2:join()

    -- more number of items than threads
    local pool3 = ThreadPool.new(2)
    pool3:schedule(function() end)
    pool3:schedule(function() end)
    pool3:schedule(function() end)
    pool3:schedule(function() end)
    pool3:schedule(function() end)
    pool3:join()
  end)

  it('should be possible to get a result back to the thread that started the pool', function()
    local pool1 = ThreadPool.new(1)
    pool1:schedule(function() return 123456789 end)
    local results1 = pool1:join()
    assert.same({ 123456789 }, results1)

    local pool2 = ThreadPool.new(2)
    pool2:schedule(function() return 123456789 end)
    pool2:schedule(function() return 'test' end)
    local results2 = pool2:join()
    assert.is_true(contains(results2, 123456789) 
               and contains(results2, 'test'))
  end)
end)

