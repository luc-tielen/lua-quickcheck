HELPER_SCRIPT=spec/fixtures/helper.lua
BUSTED_FLAGS= \
		--coverage --verbose \
		--shuffle-files --shuffle-tests \
		--helper=$(HELPER_SCRIPT)
ifeq ("$(shell echo $(LUA) | grep -o "jit")", "")
BUSTED_FLAGS += --exclude-tags=jit_only
endif


all:
	luarocks make rockspecs/lua-quickcheck-0.0-1.rockspec

fixtures:
	$(MAKE) -C spec/fixtures build

tests: fixtures
	luacheck --std=max+busted src spec --exclude-files=$(HELPER_SCRIPT) --globals ffi
	LD_LIBRARY_PATH=spec/fixtures/ busted $(BUSTED_FLAGS)

coverage:
	luacov-coveralls --dryrun

clean:
	$(MAKE) -C spec/fixtures clean

.PHONY: clean

