{
  config,
  pkgs,
  lukeSitePkg,
  ...
}:

let
  webDomain = "lukevandermale.com";
in
{
  # this is stolen from https://matoking.com/blog/2023/07/08/deploying-hugo-site-using-nixos-and-nginx/#end
  services.nginx.virtualHosts."${webDomain}" = {
    forceSSL = true;
    enableACME = true;
    serverAliases = [ "www.${webDomain}" ];

    locations = {
      "/" = {
        alias = "${lukeSitePkg}/";
      };
    };
  };
}
