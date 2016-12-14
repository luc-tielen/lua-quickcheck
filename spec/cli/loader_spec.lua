local loader = require 'lqc.cli.loader'
local lqc = require 'lqc.quickcheck'
local random = require 'lqc.random'
local r = require 'lqc.report'


local function do_setup()
  random.seed()
  lqc.init(100, 100)
  lqc.properties = {}
  r.report = function() end
end


describe('CLI loader', function()
  before_each(do_setup)

  it('can load a script and expand the global env for testing', function()
    r.report_success = spy.new(r.report_success)
    assert.equals(0, #lqc.properties)

    local enhanced_script = loader.load_script 'spec/fixtures/script.lua'
    enhanced_script()

    assert.equals(1, #lqc.properties)
    lqc.check()
    assert.spy(r.report_success).was.called(lqc.iteration_amount)
  end)
end)

