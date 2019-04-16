{ luaVersion ? "luajit_2_1", pkgs ? import ./nix/packages.nix {} }:

(import ./. { inherit luaVersion pkgs; }).shell
