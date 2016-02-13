
all:
	luarocks make rockspecs/lua-quickcheck-0.0-1.rockspec

tests:
	busted -c 
	luacov-coveralls --dryrun
