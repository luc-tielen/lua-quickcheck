{ buildLuarocksPackage, fetchurl, lua }:

buildLuarocksPackage rec {
  pname = "luacov-coveralls";
  version = "0.2.2-1";

  src = fetchurl {
    url    = "https://luarocks.org/${pname}-${version}.src.rock";
    sha256 = "1kqv1s3ih1wgcanp6zh9yxzzdmrz5zx3xsr9x73j5w5fpq3jczqp";
  };
  propagatedBuildInputs = [ lua ];

  meta = {
    homepage = "http://github.com/moteus/luacov-coveralls";
    description = "Coveralls.io support for Lua projects using luacov";
    license = { fullName = "MIT/X11 <https://github.com/moteus/luacov-coveralls/blob/master/LICENSE>"; };
  };
}
