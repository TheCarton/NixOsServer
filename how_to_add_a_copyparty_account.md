### How To Add An Account to Copyparty


First, create an account in your password manager.


### Secrets.nix
Next, go to secrets/secrets.nix add an a line to the "in" block.

Our example will be "bob-copyparty.age" so it would be:

```nix
  bob-copyparty.age".publicKeys = systems ++ users;	
```

### Create the password file with Agenix.

Next, SSH into the server and use `agenix -e bob-copyparty.age` to create the password file. This will load the default text editor. Type Bob's password.


### Add the newly created password file to the git repo.

Because NixOS, you will get a 'file not found' error if the file isn't tracked by git. Head to Lazygit, add the `bob-copyparty.age` file.

### Add account to age.secrets in configuration.nix

In `configuration.nix`, head to the `age.secrets` block and add the account.

```nix
  age.secrets = {
  # omitted other accounts...
    copyparty-rye = {
      file = ./secrets/bob-copyparty.age;
      path = "/run/keys/copyparty/bob_password";
      owner = "copyparty";
      group = "copyparty";
    };
```

### Add account and path to password file to Copyparty's accounts block

Head to the `service.copyparty` block, and find the 'accounts' block. Specify the username and the path to the password file. The path to `bob_password` must match, obviously.

```nix
    # create users
    accounts = {
      # specify user and password file
      bob.passwordFile = "/run/keys/copyparty/bob_password";
    };
```

### Add account to rw list in Copyparty's settings

Find the `volumes` block in Copyparty, and find the `rw` list. Add the new account to the list to give it read and write permissions.

```nix  
    # create a volume
    volumes = {
     # ... other settings omitted.
          rw = [
          # ... other accounts omitted.
            "bob"
          ];
        };
```
