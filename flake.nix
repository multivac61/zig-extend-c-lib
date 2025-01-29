{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
    devenv.url = "github:cachix/devenv";
    devenv.inputs.nixpkgs.follows = "nixpkgs";
    flake-parts.url = "github:hercules-ci/flake-parts";
  };

  nixConfig = {
    extra-trusted-public-keys = "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw=";
    extra-substituters = "https://devenv.cachix.org";
  };

  outputs =
    inputs@{ flake-parts, ... }:
    inputs.flake-parts.lib.mkFlake { inherit inputs; } {
      imports = [
        inputs.devenv.flakeModule
      ];

      systems = import inputs.systems;

      perSystem =
        {
          config,
          self',
          pkgs,
          system,
          ...
        }:
        {
          packages = {
            devenv-up = config.devenv.shells.default.config.procfileScript;

            i32math = pkgs.stdenv.mkDerivation (finalAttrs: {
              pname = "i32math";
              version = "0.1.0";
              src = ./.;

              nativeBuildInputs = [
                (pkgs.zig_0_13.hook.overrideAttrs {
                  zig_default_flags = "-Doptimize=ReleaseFast --color off";
                })
              ];

              preBuildPhase = ''mkdir -p zig-out/lib'';

              buildPhase = ''make ZIGOUT=zig-out/lib'';

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
            });

            default = config.packages.i32math;
          };

          devenv.shells.default = {
            packages = with pkgs; [ git ] ++ lib.optionals stdenv.isLinux [ inotify-tools ];

            languages = {
              zig.enable = true;
              c.enable = true;
            };
          };
        };
    };
}
