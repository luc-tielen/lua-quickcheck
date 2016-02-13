
all:
	luarocks make rockspecs/luacheck-0.0-1.rockspec

tests:
	busted -c 
	luacov-coveralls --dryrun
