# configuration.nix

{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [
      ./networks.nix
    ];

  # System Packages
  environment.systemPackages = with pkgs; [
    podman-compose
    docker-compose
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_unprivileged_port_start" = 53;
  };

  # Runtime 
  virtualisation.podman = { 
    enable = true; 
    autoPrune.enable = true; 
    dockerCompat = true; 
    dockerSocket.enable = true;
    # Required for container networking to be able to use names. 
    defaultNetwork.settings.dns_enabled = true; 
  }; 

  virtualisation.oci-containers.backend = "podman"; 

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    wantedBy = [ "multi-user.target" ];
  };
}