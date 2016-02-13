
# Lua-QuickCheck

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


## Contributing

For more information on how to contribute to Lua-QuickCheck, take a look at 
[CONTRIBUTING.md](https://www.github.com/Primordus/lua-quickcheck/CONTRIBUTING.md).


## Tests

Right now lua-quickcheck uses busted for testing. The intention is to replace
busted with lua-quick itself once an initial working version has been
completed.

Tests can be run with the following commands in the root directory:

'''bash
make tests
'''

or

'''bash
busted -c                  # -c requires LuaCov, can be run without
luacov-coveralls --dryrun  # optional, for coverage information
'''


## Why another QuickCheck clone?

I wanted a quickcheck library that could also easily interface with C or C++
side-by-side with my Lua code.


## License

This project is licensed under the 
[MIT license](https://www.github.com/Primordus/lua-quickcheck/LICENSE)

