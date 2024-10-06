{
  description = "shell implementation of comma";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/release-23.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { nixpkgs, flake-utils, ... }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = nixpkgs.legacyPackages.${system};

        comma-drv = pkgs.stdenv.mkDerivation {
          pname = "comma";
          version = "1.1.0";

          src = ./.;

          buildPhase = with pkgs; ''
            substituteInPlace comma.bash \
              --replace @bash@ "${bash}" \
              --replace @nix-index@ "${nix-index}" \
              --replace @toybox@ "${toybox}" \
              --replace @nix@ "${nix}" \
              --replace @fzy@ "${fzy}"

            chmod +x comma.bash
          '';
          preferLocalBuilds = true;
          allowSubstitutes = false;

          installPhase = ''
            mkdir -p $out/bin
            mv comma.bash $out/bin/comma
            ln -s $out/bin/comma $out/bin/,
          '';
        };
      in
      {
        packages = rec {
          comma = comma-drv;
          default = comma;
        };
      }
    );
  }
