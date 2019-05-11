let
  commit = "454eea84a757ca5f733c4ec0f234eba2281c74eb";
  nixpkgs = builtins.fetchTarball {
    name = "nixpkgs-19.03";
    url = "https://github.com/nixos/nixpkgs/archive/${commit}.tar.gz";
    sha256 = "1k9jbix4w43brqlfmvwy218pf5fbmzsnc08shaww9qfdl1rdlaxy";
  };
  pkgs = import nixpkgs;
in
  pkgs
