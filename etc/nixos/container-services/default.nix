# configuration.nix

{ config, pkgs, pkgs-unstable, lib, inputs, ... }:

{
  imports =
    [
      ./networks.nix
      ./infra.nix
      ./traefik.nix
      ./hass.nix
      ./media.nix
      ./apps.nix
    ];

  # System Packages
  environment.systemPackages = with pkgs; [
    pkgs-unstable.podman
    podman-compose
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
  }; 

  virtualisation.oci-containers.backend = "podman"; 

  systemd = {
    services.podman-prune.unitConfig.OnFailure = "notify-service-failure@%i.service";
    services.podman-prune.unitConfig.OnSuccess = "notify-service-success@%i.service";

    services.podman-auto-update = {
      serviceConfig = {
        ExecStartPre = "/persist/scripts/pcmanage.sh preUpdate";
        ExecStartPost = pkgs.writeShellScript "reportUpdates" ''
          ${pkgs.apprise}/bin/apprise -t "Podman update report" -b "$(journalctl -u podman-auto-update.service --since 0:00 -o cat | grep "registry.*true" | ${pkgs.gawk}/bin/awk -F'[()]' '{print $2}')."
'';
      };

      path = [ pkgs.podman ];
      unitConfig = {
        OnFailure = "notify-service-failure@%i.service";
        OnSuccess = "notify-service-success@%i.service";
      };
    };

    # Needed to activate podman-auto-update timer provided by podman upstream
    timers.podman-auto-update.wantedBy = [ "timers.target" ];
  };

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
