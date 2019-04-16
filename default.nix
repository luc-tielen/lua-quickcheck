{ luaVersion ? "luajit_2_1", pkgs ? import ./nix/packages.nix {} }:

with pkgs;
with luaPackages;

let
  pkgInfo = import ./nix/lua-quickcheck.nix { inherit lua pkgs; };
in
  with pkgInfo;
  stdenv.mkDerivation {
    inherit name;
    buildInputs = buildDeps;
    src = ./.;
    env = buildEnv {
      inherit name;
      paths = buildDeps;
    };
  }
