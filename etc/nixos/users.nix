# users.nix

{ config, pkgs, ... }:
let 
  # Read params file for SSH key
  mysshkey = config.myParams.mysshkey;
in 
{
  users.mutableUsers = false;

  users.users.root = {
    passwordFile = "/persist/passwords/root";
  };
 
  # User account
  users.users.sirchia = {
    isNormalUser = true;
    uid = 1000;
    extraGroups = [ "wheel" "video" "audio" "docker" "sirchia" ];
    shell = pkgs.fish;
    # This gives a default empty password
    # initialHashedPassword = "";
    # Have moved below line to impermanence.nix
    passwordFile = "/persist/passwords/sirchia";
    openssh.authorizedKeys.keys = [ "${mysshkey}" ];
    # Per user packages
    # packages = with pkgs; [ nix-prefetch-docker ];
  };

  # User account
  users.users.functionary = {
    isNormalUser = true;
    uid = 1003;
    extraGroups = [ "functionary" ];
    shell = pkgs.fish;
    # This gives a default empty password
    # initialHashedPassword = "";
    # Have moved below line to impermanence.nix
    passwordFile = "/persist/passwords/functionary";
  };
  # User account
  users.users.timemachine = {
    isSystemUser = true;
    group = "timemachine";
    # This gives a default empty password
    # initialHashedPassword = "";
    # Have moved below line to impermanence.nix
    passwordFile = "/persist/passwords/timemachine";
  };

  users.groups.sirchia.gid = 1000;
  users.groups.functionary.gid = 1003;
  users.groups.timemachine = { };
 
  # doas rules
  security.doas.extraRules = [
    # { groups = [ "wheel" ]; keepEnv = true; noPass = true; cmd = "nix-channel"; args = [ "--list" ]; }
    { users = [ "sirchia" ]; keepEnv = true; persist = true; }
    { users = [ "sirchia" ]; keepEnv = true; noPass = true; cmd = "nixos-rebuild"; }
    { users = [ "sirchia" ]; keepEnv = true; noPass = true; cmd = "reboot"; }
  ];
}
