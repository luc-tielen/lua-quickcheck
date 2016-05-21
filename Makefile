
all:
	luarocks make rockspecs/lua-quickcheck-0.0-1.rockspec

fixtures:
	$(MAKE) -C spec/fixtures build

tests: fixtures
	luacheck --std=max+busted src spec
	busted --coverage --verbose
	luacov-coveralls --dryrun

clean:
	$(MAKE) -C spec/fixtures clean

.PHONY: clean

