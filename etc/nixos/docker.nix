{ config, pkgs, lib, inputs, ... }: {

  # System Packages
  environment.systemPackages = with pkgs; [
    docker
    docker-compose
  ];

  virtualisation = {
    docker = {
      enable = true;
      enableOnBoot = true;
    };
  };

}

