{ luaVersion ? "luajit_2_1", pkgs ? import ./packages.nix {} }:

with pkgs;
with luaPackages;

let
  buildArgs = { inherit buildLuarocksPackage fetchurl lua; };
  moonscript = import ./nix/moonscript.nix buildArgs;
  luacov = import ./nix/luacov.nix buildArgs;
  luacov-coveralls = import ./nix/luacov-coveralls.nix buildArgs;
  lanes = import ./nix/lanes.nix buildArgs;
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
