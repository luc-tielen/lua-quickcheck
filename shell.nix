# Possible versions for luaVersion: luajit (latest), lua51, lua52, lua53
# Change version with following command:
# $ nix-shell --argstr luaVersion luajit
{ luaVersion ? "luajit", pkgs ? import ./nix/packages.nix {} }:

(import ./. { inherit luaVersion pkgs; }).shell
