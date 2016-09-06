local ThreadPool = require 'lqc.threading.thread_pool'
local filter = require 'lqc.helpers.filter'
local lqc = require 'lqc.quickcheck'
local r = require 'lqc.report'
local random = require 'lqc.random'
local property = require 'lqc.property'
local int = require 'lqc.generators.int'
local fsm = require 'lqc.fsm'
local state = require 'lqc.fsm.state'
local frequency = require('lqc.lqc_gen').frequency
local command = require 'lqc.fsm.command'
local app = require 'lqc.cli.app'


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


local function do_setup()
  random.seed()
  lqc.properties = {}
  lqc.init(100, 100)
  r.report = function() end
  app.exit = function() end
end


describe('multi threaded check', function()
  -- NOTE: this test should be put in quickcheck_spec but then a bug in busted/lualanes
  -- is triggered.
  before_each(do_setup)

  it('raises an error if init is not called before', function()
    lqc.init(nil, nil)
    assert.is_false(pcall(function() lqc.check_mt(1) end))
    lqc.init(1, 1)
    assert.is_true(pcall(function() lqc.check_mt(1) end))
  end)

  it('works with successful properties', function()
    r.report_failed_property = spy.new(r.report_failed_property)
    for _ = 1, 5 do
      property '+ is commutative' {
        generators = { int(), int() },
        check = function(x, y)
          return x + y == y + x
        end
      }
    end
    lqc.check_mt(5)
    assert.spy(r.report_failed_property).was.not_called()
  end)

  it('works with successful properties', function()
    r.report_failed_fsm = spy.new(r.report_failed_fsm)
    for _ = 1, 5 do
      fsm 'successful fsm' {
        commands = function() return frequency {
          { 1, command { 'stop', function() end, {} } },
          { 10, command { '1', function() end, {} } }
        } end,
        initial_state = function() return 0 end,
        states = {
          state '1' {
            precondition = function() return true end,
            next_state = function() end,
            postcondition = function() return true end
          }
        }
      }
    end
    lqc.check_mt(5)
    assert.spy(r.report_failed_fsm).was.not_called()
  end)

  it('works with failing properties', function()
    r.report_failed_property = spy.new(r.report_failed_property)
    for _ = 1, 5 do
      property '+ is commutative' {
        generators = { int() },
        check = function()
          return false  -- always fails!
        end
      }
    end
    lqc.check_mt(5)
    assert.spy(r.report_failed_property).was.called(5)
  end)

  it('works with failing FSMs', function()
    r.report_failed_fsm = spy.new(r.report_failed_fsm)
    for _ = 1, 5 do
      fsm 'failing fsm' {
        commands = function() return frequency {
          { 1, command { 'stop', function() end, {} } },
          { 10, command { '1', function() end, {} } }
        } end,
        initial_state = function() return 0 end,
        states = {
          state '1' {
            precondition = function() return true end,
            next_state = function() end,
            postcondition = function() return false end
          }
        }
      }
    end
    lqc.check_mt(5)
    assert.spy(r.report_failed_fsm).was.called(5)
  end)
end)


-- NOTE: this test should be put in app_spec but then a bug in busted/lualanes
-- is triggered. 
describe('multi-threaded checking of tests', function()
  it('should save last seed to .lqc.lua', function()
    -- Can't use spy across threads (r.report_success)
    app.exit = spy.new(app.exit)
    
    app.main({ 'spec/fixtures/script.lua', '--threads', '2' })
    assert.spy(app.exit).was.called()
    lqc.properties = {}

    app.main({ 'spec/fixtures/script.lua', '-t', '2' })
    assert.spy(app.exit).was.called(2)
    lqc.properties = {}

    app.main({ 'spec/fixtures/examples/', '-t', '2' })
    assert.spy(app.exit).was.called(3)
  end)
end)


