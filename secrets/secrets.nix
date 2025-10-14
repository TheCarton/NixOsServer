let
  # from desktop's ~/.ssh/id_ed25519.pub
  desktop = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDNTAsCObLLjfTr8o3JORZOdKjDf2Q3Lr0qgqssEvLfZ luke@nixos";
  # users are humans that create/modify keys.
  users = [ desktop ];

  # from the server's /etc/ssh/ssh_host_ed25519_key.pub
  server = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIEjC121MutcPSiqfH3iTKLb96x89CTbU+gOqlkODdNHb root@nixos";
  # systems are machines that need to decrypt keys at runtime.
  systems = [ server ];
in
{
  "factorio-token.age".publicKeys = systems ++ users;
  "factorio-server.age".publicKeys = systems ++ users;
  "factorio-password.age".publicKeys = systems ++ users;
  "copyparty.age".publicKeys = systems ++ users;
  "aaron-copyparty.age".publicKeys = systems ++ users;
  "rye-copyparty.age".publicKeys = systems ++ users;
  "pg-copyparty.age".publicKeys = systems ++ users;
}
