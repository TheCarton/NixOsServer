{
  lib,
  stdenv,
  pkgs,
  fetchFromGitHub,
  baseURL ? "http://localhost",
}:

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
  # i thought but pushing to this github I'd be able to show my first
  # post but it didn't work. There was no update to the public site.

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
    hugo -b ${baseURL} -t ananke -d $out;
  '';

  meta = {
    description = "Hugo project for ${pname}";
    homepage = "https://www.test-site.com";
  };
}
