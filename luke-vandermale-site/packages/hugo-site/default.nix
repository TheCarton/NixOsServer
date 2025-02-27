{
  lib,
  stdenv,
  pkgs,
  fetchFromGitHub,
}:
# The issue with this is my server is a flake-based system, and this is
# a nix channel / og nix approach. It runs into the 'impure evaluation'
# shit which is a dumb error message that I don't understand.
#
# My new idea is to try to combine these tutorials:
# https://prodlog.xyz/posts/hugo-nix/ flake version but incomplete
# and also the full deploy-to-the-web tutorial
# https://matoking.com/blog/2023/07/08/deploying-hugo-site-using-nixos-and-nginx/#end

let
  hugoTheme = builtins.fetchTarball {
    # why do i need this if it's in the github for the website?
    name = "hugo-theme-ananke";
    url = "https://github.com/theNewDynamic/gohugo-theme-ananke/archive/a1a99cf12681ad95b006e648a28139e6b9b75f09.tar.gz";
    sha256 = "07y6mr0ybw0cx37lldqi7hqafxghpi623gj8i21w23yg1yhxid8h";
  };
in
stdenv.mkDerivation rec {
  pname = "hugo-site";
  version = "0.1";

  src = fetchFromGitHub {
    owner = "TheCarton";
    repo = "luke-vandermale-site";
    rev = "main"; # Use git branch or tag here

    # SHA256 hash is required for reproducibility. When you try to build
    # the package the hash will cause a failure. You can then copy the correct
    # hash here and build the package again.
    sha256 = "I24UEtLZyxWfBZBIkyC5l3N4+nwKMBgWTgLWvHZNBcU=";
  };
  nativeBuildInputs = [ pkgs.hugo ];

  installPhase = ''
    mkdir -p themes/ananke;
    cp -r ${hugoTheme}/* themes/ananke/;
    hugo -b http://localhost -t ananke -d $out;
  '';

  meta = {
    description = "Hugo project for ${pname}";
    homepage = "https://www.test-site.com";
  };
}
