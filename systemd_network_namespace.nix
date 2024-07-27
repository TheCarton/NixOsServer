{
  config,
  pkgs,
  lib,
  ...
}:
{
  systemd.services."netns@" = {
    description = "%I network namespace";
    before = [ "network.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      PrivateNetwork = true;
      ExecStart = "${pkgs.iproute}/bin/ip netns add %I";
      ExecStop = "${pkgs.iproute}/bin/ip netns del %I";
    };
  };

  systemd.services.transmission = {
    bindsTo = [ "netns@wg.service" ];
    after = [ "netns@wg.service" ];
    unitConfig.JoinsNamespaceOf = "netns@wg.service";
    serviceConfig.PrivateNetwork = true;
  };
}
