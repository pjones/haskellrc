{
  description = "Peter's Haskell Config Files and Scripts";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
  };

  outputs = { self, nixpkgs }:
    let
      supportedSystems = [
        "armv7l-linux"
        "aarch64-darwin"
        "aarch64-linux"
        "x86_64-darwin"
        "x86_64-linux"
      ];

      # Function to generate a set based on supported systems:
      forAllSystems = f:
        nixpkgs.lib.genAttrs supportedSystems (system: f system);

      # Attribute set of nixpkgs for each system:
      nixpkgsFor = forAllSystems (system:
        import nixpkgs { inherit system; });
    in
    {
      packages = forAllSystems (system: {
        default = nixpkgsFor.${system}.stdenvNoCC.mkDerivation {
          name = "haskellrc";
          src = ./.;
          phases = [ "unpackPhase" "installPhase" "fixupPhase" ];

          installPhase = ''
            mkdir -p "$out/bin" "$out/etc"

            for file in bin/*; do
              install -m 0555 "$file" "$out/bin"
            done

            for file in etc/*; do
              install -m 0444 "$file" "$out/etc"
            done
          '';
        };
      });

      homeManagerModules.default = { config, pkgs, lib, ... }: {
        options.programs.pjones.haskellrc = {
          enable = lib.mkEnableOption "Install Haskell configuration files.";
        };

        config = lib.mkIf config.programs.pjones.haskellrc.enable {
          home.file = {
            ".ghci".source =
              "${self.packages.${pkgs.system}.default}/etc/dot.ghci";

            ".stack/config.yaml".source =
              "${self.packages.${pkgs.system}.default}/etc/dot.stack.config.yaml";
          };
        };
      };
    };
}
