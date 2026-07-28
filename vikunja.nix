# https://wiki.nixos.org/wiki/Vikunja
# Following nixos wiki Tue Jul 28 11:05:28 AM EDT 2026
{
  hostname,
  unstable,
  port ? 3456,
  ...
}:
{ ... }:

{
  services.vikunja = {
    package = unstable.vikunja;
    enable = true;
    # Nginx proxy will handle SSL encryption for us
    frontendScheme = "http";
    frontendHostname = hostname;
    port = port;
    settings = {
      service = {
        # If enabled, Vikunja will send an email to everyone who is either
        # assigned to a task or created it when a task reminder is due.
        enableemailreminders = false;
        # Whether to let new users registering themselves or not
        enableregistration = false;
        # The maximum size clients will be able to request for user avatars.
        # If clients request a size bigger than this, it will be changed on the fly.
        maxavatarsize = 4096;
        # The duration of the issued JWT tokens in seconds.
        jwtttl = 2592000;
        # The duration of the "remember me" time in seconds. When the login request is
        # made with the long param set, the token returned will be valid for this period.
        jwtttllong = 25920000;
        maxitemsperpage = 100;
        publicurl = "https://vikunja.cartonofdoom.win";
      };
    };
  };
  services.nginx.virtualHosts.${hostname} = {
    enableACME = true;
    forceSSL = true;
    locations."/" = {
      proxyPass = "http://[::1]:${toString port}";
      proxyWebsockets = true;
      recommendedProxySettings = true;
      extraConfig = ''
        client_max_body_size 5000M;
        proxy_read_timeout   600s;
        proxy_send_timeout   600s;
        send_timeout         600s;
      '';
    };
  };
}
