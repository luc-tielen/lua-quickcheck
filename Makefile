
all:
	luarocks make rockspecs/lua-quickcheck-0.0-1.rockspec

tests:
	luacheck --std=max+busted src spec
	busted --coverage --verbose
	luacov-coveralls --dryrun

