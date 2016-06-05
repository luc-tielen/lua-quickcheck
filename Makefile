HELPER_SCRIPT=spec/fixtures/helper.lua

all:
	luarocks make rockspecs/lua-quickcheck-0.0-1.rockspec

fixtures:
	$(MAKE) -C spec/fixtures build

tests: fixtures
	luacheck --std=max+busted src spec --exclude-files=$(HELPER_SCRIPT) --globals ffi
	LD_LIBRARY_PATH=spec/fixtures/ busted --coverage --verbose \
										  --shuffle-files --shuffle-tests \
										  --helper=$(HELPER_SCRIPT)

coverage:
	luacov-coveralls --dryrun

clean:
	$(MAKE) -C spec/fixtures clean

.PHONY: clean

