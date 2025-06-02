{
  pkgs ? import <nixpkgs> { },
  baseURL ? "https://parvaazgodara.com",
}:

pkgs.stdenv.mkDerivation rec {
  pname = "pg-site";
  version = "0.1";

  src = pkgs.fetchFromGitHub {
    owner = "TheCarton";
    repo = "parvaaz_website";
    rev = "d2dc5714218e5153b72e968b4bea2e8971cc73f3";
    hash = "sha256-BdJGUAWneg6yRs9cqSnXM0m8iDhxRtw7sSiH8MTmP6s="; # fill after first build error
  };

  theme = pkgs.fetchurl {
    url = "https://github.com/Sped0n/bridget/archive/refs/tags/v2.0.5.tar.gz";
    sha256 = "sha256-S4TUroGX/S8Ko8I0bfrV8S/d5kI2TuAixHHscx34VPo="; # fill after first build error
  };

  nativeBuildInputs = [ pkgs.hugo ];

  installPhase = ''
    mkdir -p themes/bridget
    tar -xzf $theme --strip-components=1 -C themes/bridget
    hugo -b ${baseURL} -t bridget -d $out
  '';

  meta = {
    description = "Parvaaz Godara Studio Hugo site";
    homepage = baseURL;
  };
}
