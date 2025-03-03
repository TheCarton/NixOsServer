{ nixpkgs, ... }:

{
  imports = [
    ./modules/hugo-site/default.nix
  ];

  # luke-vandermale-site TODO section
  # (1) Create a new post workflow
  # (2) Switch to the resume theme

  nixpkgs.overlays = [
    (self: super: rec {
      hugo-site = super.callPackage ./packages/hugo-site { };
    })
  ];
}
