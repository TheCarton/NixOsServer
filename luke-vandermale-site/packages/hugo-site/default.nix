{
  pkgs ? import <nixpkgs> { },
  baseURL ? "https://lukevandermale.com",
}:

pkgs.stdenv.mkDerivation rec {
  pname = "luke-site";
  version = "0.1";

  src = pkgs.fetchFromGitHub {
    owner = "TheCarton";
    repo = "luke-vandermale-site";
    rev = "316b9f7cac36bfc19c8384b1f246e65620e7a0a0";
    hash = "sha256-YHioiYZqFsyikxwEW4jq8qk78nASv0ZjORToErCHm5c="; # fill after first build error
  };

  theme = pkgs.fetchurl {
    url = "https://github.com/mirus-ua/hugo-theme-re-terminal/archive/refs/tags/v2.3.4.tar.gz";
    sha256 = "sha256-r3jKcv8I5cpUWZWQFMh+aEUJfBQcaRDORFDcHrZlrjc="; # fill after first build error
  };

  nativeBuildInputs = [ pkgs.hugo ];

  installPhase = ''
    mkdir -p themes/re-terminal
    tar -xzf $theme --strip-components=1 -C themes/re-terminal
    hugo -b ${baseURL} -t re-terminal -d $out
  '';

  meta = {
    description = "Luke Vandermale Hugo site";
    homepage = baseURL;
  };
}
