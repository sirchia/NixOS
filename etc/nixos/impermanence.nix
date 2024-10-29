# btrfs/impermanence.nix

{ config, pkgs, impermanence, ... }:

{
  # filesystem modifications needed for impermanence
  fileSystems."/persist".neededForBoot = true;

  # reset / at each boot
  # Note `lib.mkBefore` is used instead of `lib.mkAfter` here.
  boot.initrd.postDeviceCommands = pkgs.lib.mkAfter ''
    zfs rollback -r rootpool/local/root@blank
  '';

  # configure impermanence
  environment.persistence."/persist" = {
    directories = [
      "/etc/nixos"
    ];
    files = [
      "/etc/apprise"
      "/etc/machine-id"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
    ];
  };

  security.sudo.extraConfig = ''
    # rollback results in sudo lectures after each reboot
    Defaults lecture = never
  '';

  environment.sessionVariables = {
    PATH = [ 
      "/persist/scripts"
    ];
  };

}

