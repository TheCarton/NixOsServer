{ nixpkgs, ... }:

{
  imports = [
    ./modules/hugo-site/default.nix
  ];

  # stolen from https://matoking.com/blog/2023/07/08/deploying-hugo-site-using-nixos-and-nginx/#end
  # also stolen from https://prodlog.xyz/posts/hugo-nix/
  #
  # TODO section
  # Bafflingly, the static site is available at lukevandermale.com.
  # (1) HTTPS isn't working, I need to fix the certificate.
  # (2) I don't know what it's using the default site and not the weird theme stolen from prodlog.

  nixpkgs.overlays = [
    (self: super: rec {
      hugo-site = super.callPackage ./packages/hugo-site { };
    })
  ];
}
