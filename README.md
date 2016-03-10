
# Lua-QuickCheck

[![Build Status](https://travis-ci.org/Primordus/lua-quickcheck.svg?branch=master)](https://travis-ci.org/Primordus/lua-quickcheck)
[![Coverage Status](https://coveralls.io/repos/github/Primordus/lua-quickcheck/badge.svg?branch=master)](https://coveralls.io/github/Primordus/lua-quickcheck?branch=master)

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


NOTE: this is currently still in very early stages and a work in progress.

## Contributing

For more information on how to contribute to Lua-QuickCheck, take a look at 
[CONTRIBUTING.md](https://github.com/Primordus/lua-quickcheck/blob/master/CONTRIBUTING.md).


## Tests

Right now lua-quickcheck uses busted for testing. The intention is to replace
busted with lua-quickcheck itself once an initial working version has been
completed.

Tests can be run with the following commands in the root directory of this
project:

```bash
make tests
```

or

```bash
luacheck --std=max+busted src spec
busted -c -v               # -c requires LuaCov, can be run without
luacov-coveralls --dryrun  # optional, for coverage information
```


## Why another QuickCheck clone?

I wanted a quickcheck library that could also easily interface with C or C++
side-by-side with my Lua code.


## License

This project is licensed under the 
[MIT license](https://www.github.com/Primordus/lua-quickcheck/LICENSE)

