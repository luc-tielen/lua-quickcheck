local Vector = require 'lqc.helpers.vector'
local reduce = require 'lqc.helpers.reduce'
local filter = require 'lqc.helpers.filter'
local fs = require 'lqc.helpers.fs'
local random = require 'lqc.random'
local lqc = require 'lqc.quickcheck'
local loader = require 'lqc.cli.loader'
local arg_parser = require 'lqc.cli.arg_parser'
local report = require 'lqc.report'


-- File used for remembering last used seed for generating test cases.
local check_file = '.lqc'


-- Tries to read the last quickcheck seed.
-- Returns the last used seed (or nil on error).
local function read_from_check_file()
  return fs.read_file(check_file)
end
 

-- Writes the seed to the check file (.lqc.lua).
local function write_to_check_file(seed)
  fs.write_file(check_file, seed)
end


-- Initializes the random seed; either with last used value (--check) or a
-- specific seed (-s, --seed) or default (current timestamp)
local function initialize_random_seed(config)
  local seed = config.seed
  if config.check then  -- redo last generated test run (if --check specified)
    seed = read_from_check_file()  
  end
  local actual_used_seed = random.seed(seed)
  write_to_check_file(actual_used_seed)
  report.report_seed(actual_used_seed)
end


-- Depending on the config, return a list of files that should be executed.
local function find_files(files_or_dirs)
  return reduce(files_or_dirs, Vector.new(), function(file_or_dir, acc)
    if fs.is_file(file_or_dir) then
      return acc:push_back(file_or_dir)
    end

    -- directory
    return acc:append(Vector.new(fs.find_files(file_or_dir)))
  end):to_table()
end


-- Checks if a file is a file ending in .lua or .moon (if moonscript available)
-- Returns true if it has the correct extension; otherwise false.
local function is_script_file(file)
  return fs.is_lua_file(file) or fs.is_moonscript_file(file)
end


-- Filters out all files not ending in .lua or .moon
local function find_script_files(files)
  return filter(files, is_script_file)
end


-- Executes all scripts, specified by a table of file paths.
local function execute_scripts(files)
  for _, file in pairs(files) do
    -- TODO clear environment each time?
    local script = loader.load_script(file)
    script()
  end
end


-- Verifies all properties, with the work divided over X number of threads.
local function verify_properties(numthreads)
  if numthreads == 1 then
    lqc.check()
    return
  end

  lqc.check_mt(numthreads)
end


-- Shows the test output (statistics)
local function show_output() 
  report.report_errors()
  report.report_summary()
end


local app = {}


-- Exits the application
function app.exit() os.exit(0) end


-- Main function of the CLI application
-- 1. parse arguments
-- 2. find all files needed to run
-- 3. initialize random seed
-- 4. run 1 file, or all files in a directory (depending on args)
-- 5. execute properties (lqc.check)
-- 6. show output
function app.main(cli_args)
  local config = arg_parser.parse(cli_args or {})
  local files = find_files(config.files_or_dirs)
  local script_files = find_script_files(files)

  initialize_random_seed(config)
  lqc.init(config.numtests, config.numshrinks)
  report.configure(config.colors)
  execute_scripts(script_files)  
  verify_properties(config.threads)
  show_output()
 
  app.exit()
end


return app

