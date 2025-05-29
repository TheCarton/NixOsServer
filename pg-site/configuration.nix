{ nixpkgs, ... }:

{
  imports = [
    ./modules/hugo-site/default.nix
  ];

  nixpkgs.overlays = [
    (self: super: rec {
      hugo-site = super.callPackage ./packages/hugo-site { };
    })
  ];
}
