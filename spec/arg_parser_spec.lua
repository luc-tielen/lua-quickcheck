local p = require 'src.arg_parser'


describe("Basic argument parser:", function()
    local config = {
        switches = {help={"-h", "--help"}}, 
        options = {seed={"--seed", "-s"}}
    }
    describe("Parsing of command line switches", function()
        it("should mark switches as true if found in arg list", function() 
            assert.same({help = true}, p.parse_args({"--help"}, config))
            assert.same({help = true}, p.parse_args({"-h"}, config))
            assert.same({help = true}, p.parse_args({"--help", "-h"}, config))
        end)
        it("should ignore switches not found in arg list", function()
            assert.same({}, p.parse_args({"-v"}, config))
        end)
    end)

    describe("Parsing of command line options", function()
        it("should parse provided options properly", function()
            assert.same({seed = "123456789"}, p.parse_args({"--seed", "123456789"}, config))
            assert.same({seed = "123456789"}, p.parse_args({"-s", "123456789"}, config))
        end)
        it("should ignore unsupported options", function()
            assert.same({}, p.parse_args({"--invalid", "abcdef"}, config))
        end)
        it("should ignore invalid options ", function()
            assert.same({}, p.parse_args({"--seed", "-s"}, config))
            assert.same({}, p.parse_args({"--seed"}, config))
        end)
        it("should parse remaining args after an error was found", function()
            assert.same({seed = "abcdef"}, p.parse_args({"--invalid", "-s", "abcdef"}, config))
        end)

        it("should do nothing when no args are supplied", function()
            assert.same({}, p.parse_args({}, config))
        end)
    end)
end)

