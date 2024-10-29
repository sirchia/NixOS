# users.nix

{ config, pkgs, ... }:
let 
  # Read params file for SSH key
  mysshkey = config.myParams.mysshkey;
in 
{
  users.mutableUsers = false;

  users.users.root = {
    hashedPasswordFile = "/persist/passwords/root";
  };
 
  # User account
  users.users.sirchia = {
    isNormalUser = true;
    uid = 1000;
    group = "sirchia";
    extraGroups = [ "wheel" "video" "audio" "docker" "users" ];
    shell = pkgs.fish;
    # This gives a default empty password
    # initialHashedPassword = "";
    # Have moved below line to impermanence.nix
    hashedPasswordFile = "/persist/passwords/sirchia";
    openssh.authorizedKeys.keys = [ "${mysshkey}" ];
    # Per user packages
    # packages = with pkgs; [ nix-prefetch-docker ];
  };

  # User account
  users.users.functionary = {
    isNormalUser = true;
    uid = 1003;
    group = "functionary";
    extraGroups = [ "users" ];
    shell = pkgs.fish;
    # This gives a default empty password
    # initialHashedPassword = "";
    # Have moved below line to impermanence.nix
    hashedPasswordFile = "/persist/passwords/functionary";
  };
  # User account
  users.users.timemachine = {
    isSystemUser = true;
    group = "timemachine";
    # This gives a default empty password
    # initialHashedPassword = "";
    # Have moved below line to impermanence.nix
    hashedPasswordFile = "/persist/passwords/timemachine";
  };

  users.groups.sirchia.gid = 1000;
  users.groups.functionary.gid = 1003;
  users.groups.timemachine.gid = 991;
 
  # Definition of system/service uid/gid for persistent ID allocation across reconfigurations
  users.users.avahi.uid=999;
  users.users.nscd.uid=998;
  users.users.sshd.uid=997;
  users.users.syncoid.uid=996;
  users.users.systemd-oom.uid=995;
  users.users.timemachine.uid=994;
  
  users.groups.avahi.gid=999;
  users.groups.nscd.gid=998;
  users.groups.podman.gid=997;
  users.groups.polkituser.gid=996;
  users.groups.sshd.gid=995;
  users.groups.syncoid.gid=994;
  users.groups.systemd-coredump.gid=993;
  users.groups.systemd-oom.gid=992;


  # doas rules
  security.doas.extraRules = [
    # { groups = [ "wheel" ]; keepEnv = true; noPass = true; cmd = "nix-channel"; args = [ "--list" ]; }
    { users = [ "sirchia" ]; keepEnv = true; persist = true; }
    { users = [ "sirchia" ]; keepEnv = true; noPass = true; cmd = "nixos-rebuild"; }
    { users = [ "sirchia" ]; keepEnv = true; noPass = true; cmd = "reboot"; }
  ];
}

