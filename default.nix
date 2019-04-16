{ luaVersion ? "luajit_2_1", pkgs ? import ./nix/packages.nix {} }:

with pkgs;
with luaPackages;

let
  buildArgs = { inherit buildLuarocksPackage fetchurl lua; };
  deps = builtins.mapAttrs (dep: path: import path buildArgs) {
    moonscript = ./nix/moonscript.nix;
    luacov = ./nix/luacov.nix;
    luacov-coveralls = ./nix/luacov-coveralls.nix;
    lanes = ./nix/lanes.nix;
  };
  ffi = if isLuaJIT then [] else [ luaffi ];
in
  stdenv.mkDerivation rec {
    name = "lua-quickcheck";
    env = buildEnv { name = name; paths = buildInputs; };
    buildInputs = with deps; [
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
