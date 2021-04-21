
# Lua-QuickCheck

[![Build Status](https://github.com/luc-tielen/lua-quickcheck/actions/workflows/test.yml/badge.svg)](https://github.com/luc-tielen/lua-quickcheck/actions/workflows/test.yml)
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


## Usage

There are two ways to use Lua QuickCheck library: using its own test-runner
`lqc` or using external test-runner.

### Using the LQC test runner

Lua QuickCheck exposes a test-runner as a command-line interface for running
all property-based tests in your codebase. Assuming `lqc` is installed and
located in your path, you can run the following command to get a help prompt
for more information about possible command line arguments:

```bash
$ lqc --help
```

By default, `lqc` will look for all `*.lua` and `*.moon` files in the current
directory for .lua and .moon files and execute all of them; but it is also
possible to specify a specific set of files or directories to execute.

### Using an external test runner

In mature projects tests already exist and run using test-runner
provided by test framework. For example `busted`, `luatest` have their own
test-runners.  In such cases it is still possible to use Lua QuickCheck.
All you need to do is import required modules and run `lqc.check()` in
each testcase.

Below is an example of test `test/sum_test.lua` for use with the `luatest` library:
and its test-runner:

```lua
local lqc = require 'lqc.quickcheck'
local property = require 'lqc.property'
local random = require 'lqc.random'
local int = require 'lqc.generators.int'
local t = require('luatest')

local g = t.group()

-- {{{ Setup / teardown

g.before_all(function()
  -- Setup.
  -- lqc initialization
  random.seed()
  lqc.init(100, 100)
  lqc.properties = {}
end)

g.after_all(function()
  -- Tear down.
end)

-- {{{ sum of numbers

g.test_sum_up_to = function()
  property 'sum of numbers is equal to (n + 1) * n / 2' {
    generators = { int(100) },
    check = function(n)
      return sum_up_to(n) == (n + 1) * n / 2
  end
  }
  lqc.check()
end

-- }}} sum of numbers
```

To run test execute `luatest ./test/test_sum.lua`:
```
$ luatest ./test/sum_test.lua
.
Ran 1 tests in 0.017 seconds, 1 success, 0 failures
```

And here's an example with test library `busted`:

```lua
local random = require 'lqc.random'
local lqc = require 'lqc.quickcheck'
local property = require 'lqc.property'
local int = require 'lqc.generators.int'

local function do_setup()
  random.seed()
  lqc.init(100, 100)
  lqc.properties = {}
end

describe('arithmetic functions', function()
  before_each(do_setup)

  it('sum of numbers', function()
    property 'sum of numbers is equal to (n + 1) * n / 2' {
      generators = { int(100) },
      check = function(n)
        return sum_up_to(n) == (n + 1) * n / 2
      end
    }
    lqc.check()
  end)
end)
```

To run the tests, execute the following command: `busted spec/sum_spec.lua`

```
$ busted spec/sum_spec.lua
●
1 success / 0 failures / 0 errors / 0 pending : 0.001857 seconds
```

### Defining simple properties

Properties can be written directly in Lua or Moonscript (the latter
requires the optional moonscript dependency). For this, it makes use of Lua's
syntax to provide a simple "DSL" for specifying your properties.


```lua
-- Actual code to be tested,
-- in a real codebase this would be required from a different file.
local function sum_up_to(n)
  local sum = 0
  for i = 1, n do
    sum = sum + i
  end
  return sum
end

-- The next block of code registers the property to be tested
-- with the LQC test runner.
property 'sum of numbers is equal to (n + 1) * n / 2' {
  generators = { int(100) },
  check = function(n)
    return sum_up_to(n) == (n + 1) * n / 2
  end
}
```

The `property` function is a global function that the `lqc` binary recognizes
and knows how to execute. The function expects 2 arguments:

1. A human readable string description for test output / debugging,
2. a table containing various options:
  - `generators` should contain an array of generators, used as input for
    the check function. The working of generators is specified below.
    This argument is required.
  - `check` can be a function with N arguments (which should match the number
    of generators specified), this is the function that will be called many
    times by the test runner with different generated inputs each iteration.
    The check function should always return a boolean value
    (true = success; false = failure). This argument is required.
  - `implies`: optional argument for filtering out generated values that should
    not be checked by the property. This should be a function that accepts all
    generators used in the property as input arguments and should return a
    boolean value based on if it should skip the generated input values.
    true = don't skip this testcase; false = skip testcase.
  - `when_fail`: optional argument, callback that is called when the property
    fails. Receives all generated arguments for which the property failed.
  - `numtests`: optional argument for overriding how many times this specific
    property should be executed. Defaults to the global amount passed in via
    the commandline (or 100 if not if specified).
  - `numshrinks`: optional argument for overriding how many times this
    property should try to shrink failing testcases. Defaults to the global
    amount passed in via the commandline (or 100 if not specified).

Assuming the snippet above is stored in a file `simple_property.lua`, we can
check the property by running the following command:

```bash
$ lqc simple_property.lua
```

When executing properties, LQC will start generating testcases and try to
find a counter-example for which the stated property does not hold.
In case it does find a failing testcase, it will try to reduce the generated
output to a simpler 'minimal' failing counter example:

```lua
local function sum_up_to(n)
  local sum = 0
  for i = 1, n do
    sum = sum + i * 2  -- <== bug introduced here!
  end
  return sum
end

property 'sum of numbers is equal to (n + 1) * n / 2' {
  generators = { int(100) },
  check = function(n)
    return sum_up_to(n) == (n + 1) * n / 2
  end
}
```

Running the modified code like mentioned above will give output similar
to the snippet below:

```bash
$ lqc simple_property.lua
Random seed = 1555348276
F
Property "sum of numbers is equal to (n + 1) * n / 2" failed!
Generated values = { 87 }
Simplified solution to = { 1 }

1 tests, 1 failures, 0 skipped.
```

For more examples of some properties, take a look
[here](https://github.com/luc-tielen/lua-quickcheck/tree/master/spec/fixtures/examples)
and [here](https://github.com/luc-tielen/lua-quickcheck/blob/master/spec/fixtures/script.lua).


### Defining stateful properties

So far, the properties have been "pure" (meaning they don't modify state).
In an ideal case, most code would be written this way. However,
in real life code it is often the case that there is a lot of state
which changes over time. Lua Quickcheck also provides support for this by
allowing you to model a piece of code as a finite state machine (FSM).
For more in-depth information of how this could work, please take a look
[here](https://www.youtube.com/watch?v=zi0rHwfiX1Q).
(Note: slides are in Erlang but ideas are the same.)

FSM properties are in general much more involved since they require specifying
what the state of a system looks like at each state. Below is a heavily
annotated example of what a FSM-based property could look like when checking
if a counter object is implemented correctly.


```lua
-- Necessary imports for working with stateful properties
local fsm = require 'lqc.fsm'
local command = require 'lqc.fsm.command'
local state = require 'lqc.fsm.state'

-- Predefined generators by lua quickcheck:
local lqc_gen = require 'lqc.lqc_gen'
local frequency = lqc_gen.frequency
local oneof = lqc_gen.oneof
local elements = lqc_gen.elements


-- Actual example code to be tested; in a real situation
-- this would be required from another file:
local function new_counter()
  local Counter = { x = 0 }

  function Counter:add(y)
    self.x = self.x + y
  end

  function Counter:value()
    return self.x
  end

  function Counter:reset()
    self.x = 0
  end

  return Counter
end

-- State which is modified over time
local ctr = new_counter()

-- A command expects a function to invoke during the test,
-- the following are 3 wrapper functions:

local function counter_add(x)
  ctr:add(x)
end

local function counter_reset()
  ctr:reset()
end

local function counter_value()
  return ctr:value()
end


-- A possible way of testing complex systems is by modelling it against a much
-- simpler system. Here however, the system to be tested and the actual system
-- look very much alike since it is a simple system. This is done mainly to
-- keep the complexity down and make it more clear what parts a FSM consists of:

-- 'fsm' is just like 'property' a function available in global namespace
fsm 'counter' {
  commands = function(s)  -- parameters: s (symbolic state during generation)
    -- NOTE: conditional commands can be added with an if, ... (based on state)
    -- before returning list
    return frequency {
      { 1, command.stop },  -- if this special command is selected, it will end the sequence
      { 1, command { 'get value', counter_value, {} } },
      { 10, oneof {
          command { 'increment', counter_add, { elements { 1, 2, 3 } } },
          command { 'reset', counter_reset, {} }
        }
      }
    }
  end,
  -- The 'initial_state' and 'states' keywords define our simpler model
  -- consisting of various states, each with their own pre- and post-conditions
  -- that need to be checked and are also used during generation
  -- of possible command sequences.
  -- Note that these are all wrapped in a functions to they don't evaluate straight away.
  initial_state = function() return 0 end,
  states = {
    -- NOTE: the names of the states should match the commands defined previously!
    state 'increment' {
      precondition = function(s, args)  -- parameters: s (state), args (in a table)
        -- NOTE: this function is called during testcase generation to generate
        -- random sequence of events and during shrinking to check if the shrunk
        -- sequence is still valid
        -- Return value is a boolean:
        --   true = this state is allowed in this part of the sequence,
        --   false = this state is not allowed in this part of the sequence.
        return true  -- always allowed
      end,
      next_state = function(s, r, args)   -- parameters: s (state),
        --                                   v (value = (symbolic or real) result,
        --                                   args (table)
        -- NOTE: this function is called both during testcase generation
        -- (to update symbolic state of the model) and during FSM execution
        -- (to update real state of the model)
        -- Returned value is the new expected state.
        return s + args[1]
      end,
      postcondition = function(s, r, args)  -- parameters: s (state),
        --                                                 r (result),
        --                                                 args (table)
        -- NOTE: s = state *before* command was executed!
        -- r is actual value returned by command
        -- Return value should be a boolean: success == true; false == failure
        return ctr:value() == s + args[1]
      end
    },
    state 'get value' {
      precondition = function(s, args) return true end,
      next_state = function(s, r, args) return s end,
      postcondition = function(s, r, args) return ctr:value() == s end
    },
    state 'reset' {
      precondition = function(s, args) return true end,
      next_state = function(s, r, args) return 0 end,
      postcondition = function(s, r, args) return ctr:value() == 0 end
    },
  },
  cleanup = function(s)  -- takes a parameter s (end state after running X actions)
    ctr = new_counter()
  end,
  when_fail = function(history, state, result)  -- parameters: history, state, result
    -- This callback can be used for printing out the history of generated actions, ...
    print('\n')
    print('History of actions:')
    for i, action in pairs(history) do
      print(i, action:to_string())
    end
    print('Final state and result:', state, result)
  end,
  numtests = 100,
  numshrinks = 100
}
```

FSM properties can also shrink. It does this by making smart use of the
precondition callback for each of the states to check which transitions can be
left out while still reproducing a failing counter example.

If we modify the example above to fail roughly every 1/1000th of the time,
we can see this in action (higher probabilities are ofcourse also possible but
they reduce to a very simple failing sequence of actions):

```lua
-- ...
local function new_counter()
  local Counter = { x = 0 }

  function Counter:add(y)  -- <== bug introduced in this function
    if math.random() < 0.001 then
      return
    end

    self.x = self.x + y
  end

  function Counter:value()
    return self.x
  end

  function Counter:reset()
    self.x = 0
  end

  return Counter
end
-- ...
```

Then we can get the following output:

```bash
$ lqc fsm_example.lua
Random seed = 1555358541
............................................F
History of actions:
1	{ set, { var, 1 }, { call, increment, 1 } }
2	{ set, { var, 2 }, { call, increment, 3 } }
3	{ set, { var, 3 }, { call, increment, 1 } }
4	{ set, { var, 68 }, { call, stop } }
Final state and result:	5	nil

FSM counter failed!

45 tests, 1 failures, 0 skipped.
```

The history of actions represents the sequence of actions (state transitions)
that were generated to find this counter example. The result of each step is
indicated by `{var, XXX}`. From this example we can see that it managed to strip
away 65 actions out except for a few increment actions (of which the last
triggered the 1/1000th probability of error).


### Generators

Like all quickcheck implementations, this code also relies heavily on the
concept of generators. In this library, a generator is nothing more than a
combination of 2 functions: a `pick` function and a `shrink` function.

The pick function selects a randomly chosen value to be used in the property
tests. It has a single argument which is the sample size, which can be used
for an indication of how complex the generated value should be.

If a property fails, the corresponding shrink function of the generator is
called with the value that failed. The shrink function should then try and
reduce the value to a simpler value. (For example shrink towards 0 for numbers).

In the examples previously shown, some predefined generators were already used.
Lua quickcheck provides some generators for simple values (ints, bools, ...),
as well as some generators that take other generators to compose larger
generators together.

The predefined generators can be found [here](https://github.com/luc-tielen/lua-quickcheck/tree/master/lqc/generators)
and also [here](https://github.com/luc-tielen/lua-quickcheck/blob/master/lqc/lqc_gen.lua).

New generators can also be written in a similar way to the predefined generators
by making use of the [lqc.generator module](https://github.com/luc-tielen/lua-quickcheck/blob/master/lqc/generator.lua).

By default, the following helpers/generators are made available in
the global namespace to avoid having to import too many files
(though this can still be done):

- Generator
- any
    generates values of any of the following types:
    `table`, `str`, `int`, `float`, `bool` (see below)
- bool
    generates a value with Lua `boolean` type
- byte
    generates a byte sequence, where byte is an integer with value between
    0 - 255 (inclusive)
- char
    generates a random (ASCII) char (no 'special' characters such as NUL, NAK, ...)
- float
    generates float values
- int
    generates an integer value bounded by minimal and maximal values
- str
    generates a value with Lua type `string`
- tbl
    generates tables of varying sizes and types
- random
- property
- fsm
    generates states described by Finite State Machine, useful for testing programs behavior
- state
- command
- choose
- frequency
- elements
- oneof


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
