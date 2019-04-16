{ buildLuarocksPackage, fetchurl, lua }:

buildLuarocksPackage rec {
  pname = "lanes";
  version = "3.13.0-0";

  knownRockspec = (fetchurl {
    url    = "https://luarocks.org/${pname}-${version}.rockspec";
    sha256 = "1l6vcj8102cy2nawfvwmlmfxsl0b12cqlfx10rb886rv6h2nqd3l";
  }).outPath;

  src = fetchurl {
    url    = https://github.com/LuaLanes/lanes/archive/v3.13.0.tar.gz;
    sha256 = "1wcg5khzlm848pmd1832g39n5jwd410acnmf8c2wl5qzw5z7v8ak";
  };
  propagatedBuildInputs = [ lua ];

  meta = {
    homepage = "https://github.com/LuaLanes/lanes";
    description = "Lua Lanes is a portable, message passing multithreading library providing the possibility to run multiple Lua states in parallel.";

    license = { fullName = "MIT/X11 https://github.com/LuaLanes/lanes/blob/master/COPYRIGHT"; };
  };
}
