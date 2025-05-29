{
  description = "Media server flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    agenix.url = "github:ryantm/agenix";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
  };
  outputs =
    {
      self,
      nixpkgs,
      agenix,
      nixpkgs-unstable,
      ...
    }@inputs:
    {
      packages.x86_64-linux.pg-site = import ./pg-site/packages/hugo-site/default.nix {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
      };

      packages.x86_64-linux.luke-site = import ./luke-vandermale-site/packages/hugo-site/default.nix {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
      };

      # nixos is hostname
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit nixpkgs-unstable;
          pgSitePkg = self.packages.x86_64-linux.pg-site;
          lukeSitePkg = self.packages.x86_64-linux.luke-site;
        }; # Add this line to pass unstable
        modules = [
          { environment.systemPackages = [ agenix.packages.x86_64-linux.default ]; }
          ./configuration.nix
          agenix.nixosModules.default
          ./luke-vandermale-site/configuration.nix
          ./pg-site/configuration.nix
          # this is the difference from the matoking tutorial. I'm importing
          # this configuration.nix from the flake, not within my nixos/configuration.nix.
        ];
      };
    };
}
