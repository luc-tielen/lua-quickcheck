{ lua, pkgs }:

with pkgs;
with luaPackages;

let
  buildArgs = { inherit buildLuarocksPackage fetchurl lua; };
  deps = builtins.mapAttrs (dep: path: import path buildArgs) {
    moonscript = ./moonscript.nix;
    luacov = ./luacov.nix;
    luacov-coveralls = ./luacov-coveralls.nix;
    lanes = ./lanes.nix;
  };
  ffi = if isLuaJIT then [] else [ luaffi ];
  buildDeps = [ luarocks lua argparse luafilesystem ];
  testDeps = with deps; ffi ++ [
    lanes
    moonscript
    busted
    luacheck
    luacov
    luacov-coveralls
  ];
in
  {
    name = "lua-quickcheck";
    inherit buildDeps testDeps;
  }
