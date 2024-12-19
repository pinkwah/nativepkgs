{
  inputs.nixpkgs.url = "github:nixos/nixpkgs";

  outputs = { nixpkgs, ... }:
    let
      system = "x86_64-linux";

      lib = import <nixpkgs/lib> {};
      localSystem = { inherit system; };
      stdenvStages = import ./stdenv.nix;

      mkNativeProgram = pkgs: pkg: path: pkgs.stdenv.mkDerivation {
        inherit (pkg) pname version meta passthru pkgs;

        dontUnpack = true;

        installPhase = ''
          mkdir -p $(dirname $out/${path})
          ln -s /usr/${path} $out/${path}
        '';
      };


      overlays = [
        (final: prev:
          let
            passthruFun = import <nixpkgs/pkgs/development/interpreters/python/passthrufun.nix> {
              inherit (prev) __splicedPackages callPackage config darwin db lib libffiBoot makeScopeWithSplicing' pythonPackagesExtensions stdenv;
            };

          in rec {
            python311 = prev.stdenv.mkDerivation {
              inherit (prev.python311) pname meta;
              version = "3.11-system";

              dontUnpack = true;

              installPhase = ''
                mkdir -p $out/bin

                ln -s /usr/bin/python3.11 $out/bin/python3.11
                ln -s python3.11 $out/bin/python3
                ln -s python3 $out/bin/python
              '';

              passthru = passthruFun rec {
                self = prev.__splicedPackages.python311;
                packageOverrides = (self: super: {});
                sourceVersion = {
                  major = "3";
                  minor = "11";
                  rev = "";
                };
                hasDistutilsCxxPatch = false;
                pythonOnBuildForBuild = null;
                pythonOnBuildForHost = null;
                pythonOnBuildForTarget = null;
                pythonOnHostForHost = null;
                pythonOnTargetForTarget = null;
                implementation = "cpython";
                libPrefix = "libpython3.11";
                executable = "python3.11";
                pythonVersion = "3.11";
                sitePackages = "lib/${libPrefix}/site-packages";
              };
            };
        })
      ];

      pkgs = import <nixpkgs/pkgs/top-level> { inherit localSystem stdenvStages overlays; };

    in {
      packages.${system} = {
        default = pkgs.hello;
        python311 = pkgs.python311;
      };
  };
}
