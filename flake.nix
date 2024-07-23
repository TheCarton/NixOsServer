{
  description = "A simple NixOS flake";
  # TODO: use the wireguard namespace flake with agenix and stuff!!
  # i think i need to add the vpn to a secrets file with agenix?!?!?:!?!?!?!?!?

  inputs = {
    # NixOS official package source, using the nixos-24.05 branch here
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    agenix.url = "github:ryantm/agenix";
    wg-namespace-flake = {
      url = "github:VTimofeenko/wg-namespace-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      self,
      nixpkgs,
      agenix,
      wg-namespace-flake,
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
          wg-namespace-flake.nixosModules.default
        ];
      };
    };
}
