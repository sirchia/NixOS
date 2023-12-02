# Auto-generated using compose2nix v0.1.5.
{ pkgs, lib, ... }:

{
  # Containers
  virtualisation.oci-containers.containers."spotweb" = {
    image = "docker.io/jgeusebroek/spotweb:latest";
    environmentFiles = [
      "/etc/nixos/container-services/spotweb.env"
    ];
    volumes = [
      "/workload/appdata/spotweb:/config:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "traefik.enable" = "true";
      "traefik.http.middlewares.spotweb-ssl.headers.customrequestheaders.X-SSL" = "on";
      "traefik.http.routers.spotweb.middlewares" = "spotweb-ssl";
    };
    dependsOn = [
      "spotweb_db"
    ];
    log-driver = "journald";
    extraOptions = [
      "--network-alias=spotweb"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-spotweb" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-reverse-proxy.service"
      "workload.mount"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "workload.mount"
    ];
    partOf = [
      "podman-compose-apps-root.target"
    ];
    wantedBy = [
      "podman-compose-apps-root.target"
    ];
  };
  virtualisation.oci-containers.containers."spotweb_db" = {
    image = "lscr.io/linuxserver/mariadb";
    environmentFiles = [
      "/etc/nixos/container-services/spotweb.env"
    ];
    volumes = [
      "/workload/appdata/spotweb_db:/config:rw"
    ];
    labels = {
      "backup" = "mysql";
      "diun.enable" = "true";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=spotweb_db"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-spotweb_db" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "workload.mount"
      "podman-network-reverse-proxy.service"
    ];
    requires = [
      "workload.mount"
      "podman-network-reverse-proxy.service"
    ];
    partOf = [
      "podman-compose-apps-root.target"
    ];
    wantedBy = [
      "podman-compose-apps-root.target"
    ];
  };
  virtualisation.oci-containers.containers."vault" = {
    image = "docker.io/vaultwarden/server:latest";
    environment = {
      PGID = "1003";
      PUID = "1003";
      SIGNUPS_ALLOWED = "false";
      TZ = "Europe/Amsterdam";
    };
    volumes = [
      "/workload/appdata/vault:/data:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "traefik.enable" = "true";
      "traefik.http.routers.vault.middlewares" = "geoblock-ch@file";
      "traefik.http.routers.vault.rule" = "Host(`vault.sirchia.nl`)";
      "traefik.http.services.vault.loadbalancer.server.port" = "80";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=vault"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-vault" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "workload.mount"
      "podman-network-reverse-proxy.service"
    ];
    requires = [
      "workload.mount"
      "podman-network-reverse-proxy.service"
    ];
    partOf = [
      "podman-compose-apps-root.target"
    ];
    wantedBy = [
      "podman-compose-apps-root.target"
    ];
  };
  virtualisation.oci-containers.containers."wiki" = {
    image = "lscr.io/linuxserver/dokuwiki";
    environment = {
      PGID = "1003";
      PUID = "1003";
      TZ = "Europe/Amsterdam";
    };
    volumes = [
      "/workload/appdata/wiki:/config:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "traefik.enable" = "true";
      "traefik.http.routers.wiki.middlewares" = "geoblock-ch@file";
      "traefik.http.routers.wiki.rule" = "Host(`wiki.sirchia.nl`)";
      "traefik.http.services.wiki.loadbalancer.server.port" = "80";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=wiki"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-wiki" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "workload.mount"
      "podman-network-reverse-proxy.service"
    ];
    requires = [
      "workload.mount"
      "podman-network-reverse-proxy.service"
    ];
    partOf = [
      "podman-compose-apps-root.target"
    ];
    wantedBy = [
      "podman-compose-apps-root.target"
    ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-apps-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    partOf = [
      "podman-compose-root.target"
    ];
    wantedBy = [
      "podman-compose-root.target"
      "multi-user.target"
    ];
  };
}