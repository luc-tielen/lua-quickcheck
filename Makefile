HELPER_SCRIPT=spec/fixtures/helper.lua
BUSTED_FLAGS= \
		--coverage --verbose \
		--shuffle-files --shuffle-tests \
		--helper=$(HELPER_SCRIPT)
EXAMPLE_SCRIPTS=spec/fixtures/script.lua \
				spec/fixtures/examples/example.lua \
				spec/fixtures/examples/example.moon
ifeq ("$(shell echo $(LUA) | grep -o "jit")", "")
BUSTED_FLAGS += --exclude-tags=jit_only
endif


install:
	luarocks make rockspecs/lua-quickcheck-0.2-0.rockspec

fixtures:
	$(MAKE) -C spec/fixtures build

tests: fixtures
	luacheck --std=max+busted lqc spec \
		--exclude-files=$(HELPER_SCRIPT) $(EXAMPLE_SCRIPTS) \
		--globals ffi
	LD_LIBRARY_PATH=spec/fixtures/ busted $(BUSTED_FLAGS)

coverage:
	luacov-coveralls --dryrun

clean:
	$(MAKE) -C spec/fixtures clean

.PHONY: clean

