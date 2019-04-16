{ buildLuarocksPackage, fetchurl, lua }:

buildLuarocksPackage rec {
  pname = "ldoc";
  version = "1.4.2-1";

  src = fetchurl {
    url    = "https://luarocks.org/${pname}-${version}.src.rock";
    sha256 = "0g6q1a3m45bx49i2bsb1z0yfjgz0wqzmw047v87nqanvb6sz8hll";
  };
  propagatedBuildInputs = [ lua ];

  meta = {
    homepage = "http://stevedonovan.github.com/ldoc";
    description = "LDoc is a LuaDoc-compatible documentation generator";
    license = { fullName = "MIT/X11 https://github.com/stevedonovan/LDoc/blob/master/COPYRIGHT"; };
  };
}
