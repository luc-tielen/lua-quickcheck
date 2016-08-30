local app = require 'lqc.cli.app'
local lqc = require 'lqc.quickcheck'
local random = require 'lqc.random'
local r = require 'lqc.report'
local fs = require 'lqc.helpers.fs'


local function do_setup()
  random.seed()
  lqc.properties = {}
  r.report = function() end
  app.exit = function() end
end

local check_file = '.lqc'


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

  describe('re-checking tests', function()
    it('should save last seed to .lqc.lua', function()
      random.seed = spy.new(random.seed)
      fs.remove_file(check_file)
      assert.is_false(fs.file_exists(check_file))
      -- if no file exists yet, use current timestamp:
      app.main({ '--check', 'spec/fixtures/examples/' })
      assert.is_true(fs.file_exists(check_file))
      
      local last_seed = fs.read_file(check_file)
      assert.spy(random.seed).was.called_with(nil)
      app.main({ '--check', 'spec/fixtures/examples/' })
      assert.spy(random.seed).was.called_with(last_seed)

      random.seed = spy.new(random.seed)
      app.main({ '--check', 'spec/fixtures/examples/' })
      assert.spy(random.seed).was.called_with(last_seed)
    end)
  end)
end)

