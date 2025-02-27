{ config, pkgs, ... }:

let
  webDomain = "lukevandermale.com";
in
{
  # this is stolen from https://matoking.com/blog/2023/07/08/deploying-hugo-site-using-nixos-and-nginx/#end
  services.nginx = {
    enable = true;

    virtualHosts."${webDomain}" = {
      serverAliases = [ "www.${webDomain}" ];

      locations = {
        "/" = {
          alias = "${pkgs.hugo-site}/";
        };
      };
    };
  };
}
