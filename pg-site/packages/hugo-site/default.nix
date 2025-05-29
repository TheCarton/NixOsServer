{
  pkgs ? import <nixpkgs> { },
  baseURL ? "https://parvaazgodarastudio.com",
}:

pkgs.stdenv.mkDerivation rec {
  pname = "pg-site";
  version = "0.1";

  src = pkgs.fetchFromGitHub {
    owner = "TheCarton";
    repo = "parvaaz_website";
    rev = "865b7e4e5686484385ea969e5cf3b10853726bcc";
    hash = "sha256-crBog0/MCSlgu2bIYJtOtG9QwMsqEUPbFldqivJWdvE="; # fill after first build error
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
