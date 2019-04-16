{ luaVersion ? "luajit_2_1", pkgs ? import ./packages.nix {} }:

with pkgs;
with luaPackages;

let
  moonscript = buildLuarocksPackage rec {
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
  };
  luacov = buildLuarocksPackage rec {
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
  };
  luacov-coveralls = buildLuarocksPackage rec {
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
  };
  lanes = buildLuarocksPackage rec {
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
  };
  ffi = if isLuaJIT then [] else [ luaffi ];
in
  stdenv.mkDerivation rec {
    name = "lua-quickcheck";
    env = buildEnv { name = name; paths = buildInputs; };
    buildInputs = [
      lua
      argparse
      luafilesystem
      lanes
      moonscript
      busted
      luacheck
      luacov
      luacov-coveralls
    ] ++ ffi;
  }
