{ buildLuarocksPackage, fetchurl, lua }:

buildLuarocksPackage rec {
  pname = "lua-path";
  version = "0.3.1-1";

  src = fetchurl {
      url    = "https://luarocks.org/${pname}-${version}.src.rock";
      sha256 = "058igc1qx4sc54kcznzhvd0c44c7vjsihfwvsrgp5wiaax77syvq";
  };
  propagatedBuildInputs = [ lua ];

  meta = {
    homepage = "github.com/moteus/lua-path";
    description = "File system path manipulation library";

    license = { fullName = "MIT/X11 https://github.com/moteus/lua-path/blob/master/LICENCE.txt"; };
  };
}
