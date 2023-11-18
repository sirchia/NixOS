{ config, pkgs, lib, inputs, ... }: {

  # System Packages
  environment.systemPackages = with pkgs; [
    podman-compose
    docker-compose
  ];

  boot.kernel.sysctl = {
    "net.ipv4.ip_unprivileged_port_start" = 53;
  };

  virtualisation = {
    podman = {
      enable = true;

      # Create a `docker` alias for podman, to use it as a drop-in replacement
      dockerCompat = true;
      dockerSocket.enable = true;

      # security.unprivilegedUsernsClone = true;
      # Required for containers under podman-compose to be able to talk to each other.
      defaultNetwork.settings.dns_enabled = true;
      # For Nixos version > 22.11
    };
  };

#  {
#    virtualisation.oci-containers.backend = "podman";
#    virtualisation.oci-containers.containers = {
#      container-name = {
#        image = "container-image";
#        autoStart = true;
#        ports = [ "127.0.0.1:1234:1234" ];
#      };
#    };
#  }

}

