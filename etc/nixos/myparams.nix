# myparams.nix

{ config, lib, ... }:
with lib;
{
  options = {
    myParams = mkOption {
      type = types.attrs; # Should probably be `submodule?
      description = "My config attrs";
    };
  };
  config = {
    myParams = {
      myhostname = "server";
      myhostid = "12345678";
      mysshkey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIdpgo44mvndFIGZnanZK8xzjvlWCkVJsvCliB0GT2YV Sirchia on Termius";
    };
  };
}

