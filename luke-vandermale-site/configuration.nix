{
  config,
  pkgs,
  lukeSitePkg,
  ...
}:
{
  services.nginx.virtualHosts."lukevandermale.com" = {
    forceSSL = true;
    enableACME = true;
    serverAliases = [ "www.lukevandermale.com" ];

    locations."/" = {
      alias = "${lukeSitePkg}/";
    };
  };
}
