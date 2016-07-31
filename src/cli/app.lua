local Vector = require 'src.helpers.vector'
local reduce = require 'src.helpers.reduce'
local filter = require 'src.helpers.filter'
local fs = require 'src.helpers.fs'
local random = require 'src.random'
local lqc = require 'src.quickcheck'
local loader = require 'src.cli.loader'
local arg_parser = require 'src.cli.arg_parser'


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


-- Shows the test output (statistics)
-- TODO statistics etc
local function show_output() end


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

  random.seed(config.seed)
  lqc.init(config.numtests, config.numshrinks)
  execute_scripts(script_files)  
  lqc.check()
  show_output()
 
  app.exit()
end


return app

