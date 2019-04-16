{ buildLuarocksPackage, fetchurl, lua }:

buildLuarocksPackage rec {
  pname = "moonscript";
  version = "0.5.0-1";

  src = fetchurl {
      url    = "https://luarocks.org/${pname}-${version}.src.rock";
      sha256 = "09vv3ayzg94bjnzv5fw50r683ma0x3lb7sym297145zig9aqb9q9";
  };
  propagatedBuildInputs = [ lua ];

  meta = {
    homepage = "https://moonscript.org";
    description = "A programmer friendly language that compiles to Lua.";
    license = { fullName = "MIT <http://opensource.org/licenses/MIT>"; };
  };
}
