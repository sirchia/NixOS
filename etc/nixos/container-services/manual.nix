# Auto-generated using compose2nix v0.1.8.
{ pkgs, lib, ... }:

{
  # Containers
  virtualisation.oci-containers.containers."makemkv" = {
    image = "docker.io/jlesage/makemkv:latest";
    autoStart = false;
    environment = {
      GROUP_ID = "1003";
      USER_ID = "1003";
      TZ = "Europe/Amsterdam";
      KEEP_APP_RUNNING = "1";
      APP_NICENESS = "5"; #slightly lower priority
      DARK_MODE = "1";
    };
    volumes = [
      "/mnt/storage:/storage:ro"
      "/mnt/storage/Downloads/MakeMKV:/output:rw"
      "/workload/appdata/makemkv:/config:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "io.containers.autoupdate" = "registry";
      "traefik.enable" = "true";
      "traefik.http.services.makemkv.loadbalancer.server.port" = "5800";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=makemkv"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-makemkv" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "zfs.target"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "zfs.target"
    ];
  };
  virtualisation.oci-containers.containers."resilio" = {
    image = "lscr.io/linuxserver/resilio-sync:latest";
    autoStart = false;
    environment = {
      PGID = "1000";
      PUID = "1000";
      TZ = "Europe/Amsterdam";
    };
    volumes = [
      "/mnt/disk4/Downloads:/downloads:rw"
      "/mnt/disk4/Sync:/sync:rw"
      "/workload/appdata/resilio:/config:rw"
    ];
    ports = [
      "8888:8888/tcp"
      "55555:55555/tcp"
    ];
    labels = {
      "diun.enable" = "true";
      "io.containers.autoupdate" = "registry";
      "traefik.enable" = "true";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=resilio"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-resilio" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-reverse-proxy.service"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
    ];
  };
}
