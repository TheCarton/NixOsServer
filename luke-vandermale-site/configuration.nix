{ nixpkgs, ... }:

{
  imports = [
    ./modules/hugo-site/default.nix
  ];

  # stolen from https://matoking.com/blog/2023/07/08/deploying-hugo-site-using-nixos-and-nginx/#end

  nixpkgs.overlays = [
    (self: super: rec {
      hugo-site = super.callPackage ./packages/hugo-site { };
    })
  ];
}
