{
  services.cockpit = {
    enable = true;
    port = 9090;
    openFirewall = false; # nginx is the only way in now
    allowed-origins = [
      "https://cockpit.cartonofdoom.win"
      "wss://cockpit.cartonofdoom.win"
    ];
    settings = {
      WebService = {
        AllowUnencrypted = true; # nginx terminates TLS
        ProtocolHeader = "X-Forwarded-Proto";
      };
    };
  };

  services.nginx.virtualHosts."cockpit.cartonofdoom.win" = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://127.0.0.1:9090";
      proxyWebsockets = true;
      extraConfig = ''
        # LAN only (adjust to your subnet; add 100.64.0.0/10 for Tailscale)
        allow 192.168.0.0/16;
        deny all;

        gzip off;
        proxy_buffering off;
      '';
    };
  };
}
