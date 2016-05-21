
all:
	luarocks make rockspecs/lua-quickcheck-0.0-1.rockspec

fixtures:
	$(MAKE) -C spec/fixtures build

tests: fixtures
	luacheck --std=max+busted src spec
	LD_LIBRARY_PATH=spec/fixtures/ busted --coverage --verbose \
										  --shuffle-files --shuffle-tests

coverage:
	luacov-coveralls --dryrun

clean:
	$(MAKE) -C spec/fixtures clean

.PHONY: clean

