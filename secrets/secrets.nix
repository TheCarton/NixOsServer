let
  user1 = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIGk4QnB3Xmfx6AsWSXC3Om5UxTIctH+jlo9UMi/hrBZ1 theukearchy@gmail.com";
  users = [ user1 ];
  server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAID54vJ/M/lKi6qCLIfxKQ8P6bo4SdSvJKWQ3D6V8eEMF root@nixos";

  systems = [ server ];
in
{
  "mullvad_vpn.age".publicKeys = systems ++ users;
}
