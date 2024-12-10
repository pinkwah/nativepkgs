{
  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";

      lib = import <nixpkgs/lib> {};
      localSystem = { inherit system; };
      stdenvStages = import ./stdenv.nix;
      pkgs = import <nixpkgs/pkgs/top-level> { inherit localSystem stdenvStages; };

    in {
      packages.${system}.default = pkgs.hello;
  };
}
