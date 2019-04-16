let
  nixpkgs = builtins.fetchTarball {
    name = "nixos-19.03";
    url = https://github.com/nixos/nixpkgs/archive/19.03.tar.gz;
    sha256 = "0q2m2qhyga9yq29yz90ywgjbn9hdahs7i8wwlq7b55rdbyiwa5dy";
  };
  pkgs = import nixpkgs;
in
  pkgs
