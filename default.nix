{ luaVersion ? "luajit", pkgs ? import ./nix/packages.nix {} }:

with pkgs;
with pkgs."${luaVersion}Packages";

let
  buildArgs = { inherit buildLuarocksPackage fetchurl lua; };
  moonscript = import ./nix/moonscript.nix buildArgs;
  luacov = import ./nix/luacov.nix buildArgs;
  luacov-coveralls = import ./nix/luacov-coveralls.nix (buildArgs // { inherit lua-path; });
  lanes = import ./nix/lanes.nix buildArgs;
  ldoc = import ./nix/ldoc.nix buildArgs;
  lua-path = import ./nix/lua-path.nix buildArgs;
  ffi = if isLuaJIT then [] else [ luaffi ];
  runTimeDeps = [ lua argparse luafilesystem ];
  testDeps = ffi ++ [
    lanes
    moonscript
    busted
    luacheck
    luacov
    luacov-coveralls
    ldoc
    lua-path
  ];
in
  {
    lua-quickcheck = stdenv.mkDerivation rec {
      name = "lua-quickcheck";
      env = buildEnv { name = name; paths = buildInputs; };
      buildInputs = runTimeDeps;
      src = ./.;
    };
    shell = mkShell {
      inputsFrom = testDeps;
      buildInputs = runTimeDeps ++ testDeps;
    };
  }
