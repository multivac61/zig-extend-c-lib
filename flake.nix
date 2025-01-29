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
          config,
          self',
          pkgs,
          system,
          ...
        }:
        {
          packages = {
            i32math = pkgs.stdenv.mkDerivation (finalAttrs: {
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

          devShells.default = pkgs.mkShell {
            inputsFrom = [ self'.packages.i32math ];
            packages =
              with pkgs;
              [
                git
                zig_0_13
                zls
              ]
              ++ lib.optionals stdenv.isLinux [ inotify-tools ];

            shellHook = ''
              echo "Welcome to i32math development environment!"
            '';
          };
          checks = {
            # Check that the main package builds
            inherit (self'.packages) i32math;

            # Check that the development shell builds
            devShell = self'.devShells.default;
          };
        };
    };
}
