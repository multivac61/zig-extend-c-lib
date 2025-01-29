{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      perSystem =
        {
          self',
          pkgs,
          system,
          ...
        }:
        {
          packages = {
            i32math = pkgs.stdenv.mkDerivation {
              pname = "i32math";
              version = "0.1.0";
              src = ./.;

              nativeBuildInputs = [
                pkgs.gnumake
                (pkgs.zig_0_13.hook.overrideAttrs {
                  zig_default_flags = "-Doptimize=ReleaseFast --color off";
                })
              ];

              preBuildPhase = ''mkdir -p zig-out/lib'';

              buildPhase = ''make ZIGOUT=zig-out/lib'';

              checkPhase = "make test";
              doCheck = true;

              installPhase = ''
                mkdir -p $out/{lib,bin}
                cp libi32math.a $out/lib/
                cp main $out/bin/i32math
              '';

              meta = with pkgs.lib; {
                description = "i32math library implementation";
                license = licenses.mit;
                platforms = platforms.all;
              };
            };

            default = self'.packages.i32math;
          };

          devShells.default = pkgs.mkShell { inputsFrom = [ self'.packages.i32math ]; };

          checks = self'.packages // self'.devShells;
        };
    };
}
