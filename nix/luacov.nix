{ buildLuarocksPackage, fetchurl, lua }:

buildLuarocksPackage rec {
  pname = "luacov";
  version = "0.13.0-1";

  src = fetchurl {
    url    = "https://luarocks.org/${pname}-${version}.src.rock";
    sha256 = "16am0adzr4y64n94f64d4yrz65in8rwa8mmjz1p0k8afm5p5759i";
  };
  propagatedBuildInputs = [ lua ];

  meta = {
    homepage = "http://keplerproject.github.io/luacov/";
    description = "Simple coverage analysis tool for Lua scripts.";
    license = { fullName = "MIT <http://opensource.org/licenses/MIT>"; };
  };
}
