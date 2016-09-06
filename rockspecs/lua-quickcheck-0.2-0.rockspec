package = 'lua-quickcheck'
version = '0.2-0'
source = {
  url = 'git://github.com/Primordus/lua-quickcheck',
  tag = 'v0.2-0'
}
description = {
  summary = 'Property based testing library for Lua',
  detailed = [[
    QuickCheck is a way to do property based testing using randomly generated input. 
    Lua-QuickCheck comes with the ability to randomly generate and shrink integers, 
    doubles, booleans, strings, tables, custom datatypes, ... 
    All QuickCheck needs is a property function -- it will then randomly generate 
    inputs to that function and call the property for each set of inputs. If the 
    property fails (whether by an error or not satisfying your property), 
    the inputs are "shrunk" to find a smaller counter-example.
  ]],
  homepage = 'https://github.com/Primordus/lua-quickcheck',
  license = 'MIT <http://opensource.org/licenses/MIT>'
}
dependencies = {
  'lua >= 5.1, < 5.3',
  'luafilesystem >= 1.5.0',
  'argparse >= 0.5.0'
  -- NOTE: luaffi, moonscript, ... are all optional dependencies
}
build = {
  type = 'builtin',
  modules = {
    ['lqc.property_result'] = 'lqc/property_result.lua',
    ['lqc.generators.byte'] = 'lqc/generators/byte.lua',
    ['lqc.generators.bool'] = 'lqc/generators/bool.lua',
    ['lqc.generators.char'] = 'lqc/generators/char.lua',
    ['lqc.generators.float'] = 'lqc/generators/float.lua',
    ['lqc.generators.any'] = 'lqc/generators/any.lua',
    ['lqc.generators.int'] = 'lqc/generators/int.lua',
    ['lqc.generators.str'] = 'lqc/generators/string.lua',
    ['lqc.generators.tbl'] = 'lqc/generators/table.lua',
    ['lqc.generator'] = 'lqc/generator.lua',
    ['lqc.random'] = 'lqc/random.lua',
    ['lqc.helpers.deep_equals'] = 'lqc/helpers/deep_equals.lua',
    ['lqc.helpers.filter'] = 'lqc/helpers/filter.lua',
    ['lqc.helpers.map'] = 'lqc/helpers/map.lua',
    ['lqc.helpers.reduce'] = 'lqc/helpers/reduce.lua',
    ['lqc.helpers.deep_copy'] = 'lqc/helpers/deep_copy.lua',
    ['lqc.helpers.vector'] = 'lqc/helpers/vector.lua',
    ['lqc.helpers.fs'] = 'lqc/helpers/fs.lua',
    ['lqc.fsm.var'] = 'lqc/fsm/var.lua',
    ['lqc.fsm.state'] = 'lqc/fsm/state.lua',
    ['lqc.fsm.action'] = 'lqc/fsm/action.lua',
    ['lqc.fsm.command'] = 'lqc/fsm/command.lua',
    ['lqc.fsm.algorithm'] = 'lqc/fsm/algorithm.lua',
    ['lqc.report'] = 'lqc/report.lua',
    ['lqc.lqc_gen'] = 'lqc/lqc_gen.lua',
    ['lqc.cli.arg_parser'] = 'lqc/cli/arg_parser.lua',
    ['lqc.cli.app'] = 'lqc/cli/app.lua',
    ['lqc.cli.loader'] = 'lqc/cli/loader.lua',
    ['lqc.quickcheck'] = 'lqc/quickcheck.lua',
    ['lqc.config'] = 'lqc/config.lua',
    ['lqc.property'] = 'lqc/property.lua',
    ['lqc.fsm'] = 'lqc/fsm.lua',
    ['lqc.threading.thread_pool'] = 'lqc/threading/thread_pool.lua'
  },
  install = {
    bin = {
      ['lqc'] = 'bin/lqc'
    }
  }
}

