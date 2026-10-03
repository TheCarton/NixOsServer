{
  description = "Media server flake";
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    agenix.url = "github:ryantm/agenix";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    # add copyparty flake to your inputs
    copyparty.url = "github:9001/copyparty";
  };
  outputs =
    {
      self,
      nixpkgs,
      agenix,
      nixpkgs-unstable,
      copyparty,
      ...
    }@inputs:
    {

      # nixos is hostname
      nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit nixpkgs-unstable;
        }; # Add this line to pass unstable

        modules = [

          # load the copyparty NixOS module
          copyparty.nixosModules.default
          (
            { pkgs, ... }:
            {
              # add the copyparty overlay to expose the package to the module
              nixpkgs.overlays = [ copyparty.overlays.default ];
              # (optional) install the package globally
              environment.systemPackages = [ pkgs.copyparty ];
              # configure the copyparty module
              services.copyparty.enable = true;
            }
          )

          { environment.systemPackages = [ agenix.packages.x86_64-linux.default ]; }
          ./configuration.nix
          agenix.nixosModules.default
          # this is the difference from the matoking tutorial. I'm importing
          # this configuration.nix from the flake, not within my nixos/configuration.nix.
        ];
      };
    };
}
