local app = require 'src.cli.app'
local lqc = require 'src.quickcheck'
local random = require 'src.random'
local r = require 'src.report'


local function do_setup()
  random.seed()
  lqc.properties = {}
  r.report = function() end
  app.exit = function() end
end


describe('CLI application', function()
  before_each(do_setup)

  describe('main', function()
    it('is the starting point of the application', function()
      app.exit = spy.new(app.exit)
      r.report_success = spy.new(r.report_success)
      
      app.main({ 'spec/fixtures/script.lua' })
      assert.spy(app.exit).was.called()
      assert.spy(r.report_success).was.called(lqc.numtests)
      lqc.properties = {}

      app.main({ 'spec/fixtures/script.lua' })
      assert.spy(app.exit).was.called(2)
      assert.spy(r.report_success).was.called(2 * lqc.numtests)
      lqc.properties = {}

      app.main({ 'spec/fixtures/examples/' })
      assert.spy(app.exit).was.called(3)
      assert.spy(r.report_success).was.called(4 * lqc.numtests)
    end)
  end)
end)

