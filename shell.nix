{ luaVersion ? "luajit_2_1", pkgs ? import ./nix/packages.nix {} }:

with pkgs;
with luaPackages;

let
  pkgInfo = import ./nix/lua-quickcheck.nix { inherit lua pkgs; };
in
  with pkgInfo; mkShell {
    buildInputs = buildDeps;
    inputsFrom = testDeps;
  }
