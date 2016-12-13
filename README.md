
# Lua-QuickCheck

[![Build Status](https://travis-ci.org/luc-tielen/lua-quickcheck.svg?branch=master)](https://travis-ci.org/luc-tielen/lua-quickcheck)
[![Coverage Status](https://coveralls.io/repos/github/luc-tielen/lua-quickcheck/badge.svg?branch=master)](https://coveralls.io/github/luc-tielen/lua-quickcheck?branch=master)
[![License (MIT)](https://img.shields.io/badge/License-MIT-blue.svg)](https://github.com/luc-tielen/lua-quickcheck/blob/master/LICENSE)

[![Lua 5.1 status](https://badges.herokuapp.com/travis/luc-tielen/lua-quickcheck?label=Lua5.1&env=LUA=%22lua=5.1%22)](https://travis-ci.org/luc-tielen/lua-quickcheck)
[![Lua 5.2 status](https://badges.herokuapp.com/travis/luc-tielen/lua-quickcheck?label=Lua5.2&env=LUA=%22lua=5.2%22)](https://travis-ci.org/luc-tielen/lua-quickcheck)
[![LuaJIT 2.0 status](https://badges.herokuapp.com/travis/luc-tielen/lua-quickcheck?label=LuaJIT2.0&env=LUA=%22luajit=2.0%22)](https://travis-ci.org/luc-tielen/lua-quickcheck)
[![LuaJIT 2.1 status](https://badges.herokuapp.com/travis/luc-tielen/lua-quickcheck?label=LuaJIT2.1&env=LUA=%22luajit=2.1%22)](https://travis-ci.org/luc-tielen/lua-quickcheck)


Lua-QuickCheck is a Quickcheck clone for Lua.

QuickCheck is a way to do property based testing using randomly generated 
input. Lua-QuickCheck comes with the ability to randomly generate and shrink 
integers, doubles, booleans, strings, tables, ... 

All QuickCheck needs is a property function -- it will then randomly generate 
inputs to that function and call the property for each set of inputs. 
If the property fails (whether by an error or not satisfying your property), 
the inputs are "shrunk" to find a smaller counter-example.

In short:
"Don't write tests... generate them!" - John Hughes


## Examples

Some example properties can be found [here](https://github.com/luc-tielen/lua-quickcheck/tree/master/spec/fixtures/examples).


## Contributing

For more information on how to contribute to Lua-QuickCheck, take a look at 
[CONTRIBUTING.md](https://github.com/luc-tielen/lua-quickcheck/blob/master/CONTRIBUTING.md).


## Installation

From the commandline, enter the following command:

```bash
luarocks install lua-quickcheck
```

After installation, 'lqc' will be available for usage.
The lqc command can be configured with various options (use lqc --help for a
list of commandline parameters).


## Tests

Right now lua-quickcheck uses busted for testing (which calls into the
quickcheck engine). Tests can be run with the following command 
in the root directory of this project:

```bash
make tests
```


## Dependencies

- LuaFilesystem
- argparse
- Lua(JIT) FFI (optional, for testing C / C++ / ...)
- Moonscript (optional, for testing properties written in Moonscript)


## Why another QuickCheck clone?

I wanted a quickcheck library that could also easily interface with C or C++
side-by-side with my Lua code.


