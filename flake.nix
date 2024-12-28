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
      # nixos is hostname
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";

        modules = [
          { environment.systemPackages = [ agenix.packages.x86_64-linux.default ]; }
          ./configuration.nix
          agenix.nixosModules.default
        ];
      };
    };
}
