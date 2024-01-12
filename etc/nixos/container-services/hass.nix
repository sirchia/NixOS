# Auto-generated using compose2nix v0.1.5.
{ pkgs, lib, ... }:

{
  # Containers
  virtualisation.oci-containers.containers."dsmr" = {
    image = "docker.io/xirixiz/dsmr-reader-docker:latest";
    environmentFiles = [
      "/etc/nixos/container-services/dsmr.env"
    ];
    volumes = [
      "/etc/localtime:/etc/localtime:ro"
      "/workload/appdata/dsmr/backups:/app/backups:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "io.containers.autoupdate" = "registry";
      "traefik.enable" = "true";
      "traefik.http.services.dsmr.loadbalancer.server.port" = "80";
    };
    dependsOn = [
      "dsmrdb"
    ];
    log-driver = "journald";
    extraOptions = [
      "--cap-add=NET_ADMIN"
      "--device=/dev/null:/dev/ttyUSB0"
      "--network-alias=dsmr"
      "--network=reverse-proxy"
      "--healthcheck-command=/bin/sh -c curl' '-Lsf' 'http://127.0.0.1/about' '-o' '/dev/null' '-w' ''HTTP_%{http_code}'"
      "--healthcheck-interval=10s"
      "--healthcheck-timeout=5s"
      "--healthcheck-retries=10"
      "--sdnotify=healthy"
    ];
  };
  systemd.services."podman-dsmr" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-reverse-proxy.service"
      "zfs.target"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "zfs.target"
    ];
    partOf = [
      "podman-compose-hass-root.target"
    ];
    wantedBy = [
      "podman-compose-hass-root.target"
    ];
  };
  virtualisation.oci-containers.containers."dsmrdb" = {
    image = "docker.io/postgres:15-alpine";
    environmentFiles = [
      "/etc/nixos/container-services/dsmr.env"
    ];
    volumes = [
      "/workload/appdata/dsmrdb:/var/lib/postgresql/data:rw"
    ];
    labels = {
      "backup" = "postgresql";
      "diun.enable" = "true";
      "io.containers.autoupdate" = "registry";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=dsmrdb"
      "--network=reverse-proxy"
      "--healthcheck-command=/bin/sh -c 'pg_isready -U dsmrreader'"
      "--healthcheck-interval=10s"
      "--healthcheck-timeout=5s"
      "--healthcheck-retries=10"
      "--sdnotify=healthy"
    ];
  };
  systemd.services."podman-dsmrdb" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-reverse-proxy.service"
      "zfs.target"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "zfs.target"
    ];
    partOf = [
      "podman-compose-hass-root.target"
    ];
    wantedBy = [
      "podman-compose-hass-root.target"
    ];
  };
  virtualisation.oci-containers.containers."grott" = {
    image = "docker.io/ledidobe/grott:beta";
    volumes = [
      "/workload/appdata/grott/grott.ini:/app/grott.ini:rw"
      "/workload/appdata/grott/grott_ha.py:/app/grott_ha.py:rw"
    ];
    ports = [
      "5279:5279/tcp" # Growatt API
    ];
    labels = {
      "diun.enable" = "true";
      "io.containers.autoupdate" = "registry";
    };
    log-driver = "journald";
    extraOptions = [
      "--init"
      "--network-alias=grott"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-grott" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-reverse-proxy.service"
      "zfs.target"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "zfs.target"
    ];
    partOf = [
      "podman-compose-hass-root.target"
    ];
    wantedBy = [
      "podman-compose-hass-root.target"
    ];
  };
  virtualisation.oci-containers.containers."hass" = {
    image = "docker.io/homeassistant/home-assistant:latest";
    environment = {
      TZ = "Europe/Amsterdam";
    };
    volumes = [
      "/workload/appdata/hass:/config:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "io.containers.autoupdate" = "registry";
      "traefik.enable" = "true";
      "traefik.http.routers.hass.middlewares" = "geoblock-ch@file";
      "traefik.http.routers.hass.rule" = "Host(`hass.sirchia.nl`)";
      "traefik.http.services.hass.loadbalancer.server.port" = "8123";
    };
    log-driver = "journald";
    extraOptions = [
      "--sdnotify=container"
      "--cap-add=CAP_NET_BIND_SERVICE"
      "--cap-add=CAP_NET_RAW"
      "--device=/dev/serial/by-id/usb-Arduino__www.arduino.cc__0042_854303437373513041B2-if00:/dev/serial/by-id/usb-Arduino__www.arduino.cc__0042_854303437373513041B2-if00"
      "--network-alias=hass"
      "--network=macvlan_lan:ip=192.168.1.229"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-hass" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-macvlan_lan.service"
      "podman-network-reverse-proxy.service"
      "zfs.target"
    ];
    requires = [
      "podman-network-macvlan_lan.service"
      "podman-network-reverse-proxy.service"
      "zfs.target"
    ];
    partOf = [
      "podman-compose-hass-root.target"
    ];
    wantedBy = [
      "podman-compose-hass-root.target"
    ];
  };
  virtualisation.oci-containers.containers."mosquitto" = {
    image = "docker.io/eclipse-mosquitto:latest";
    environment = {
      TZ = "Europe/Amsterdam";
    };
    volumes = [
      "/workload/appdata/mosquitto/config:/mosquitto/config:rw"
      "/workload/appdata/mosquitto/data:/mosquitto/data:rw"
      "/workload/appdata/mosquitto/log:/mosquitto/log:rw"
    ];
    ports = [
      "1883:1883/tcp" # MQTT
      "9001:9001/tcp" # Websocket
    ];
    labels = {
      "diun.enable" = "true";
      "io.containers.autoupdate" = "registry";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=mosquitto"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-mosquitto" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-reverse-proxy.service"
      "zfs.target"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "zfs.target"
    ];
    partOf = [
      "podman-compose-hass-root.target"
    ];
    wantedBy = [
      "podman-compose-hass-root.target"
    ];
  };
  virtualisation.oci-containers.containers."zwavejs" = {
    image = "docker.io/zwavejs/zwave-js-ui:latest";
    environment = {
      TZ = "Europe/Amsterdam";
      ZWAVEJS_EXTERNAL_CONFIG = "/usr/src/app/store/config-db";
    };
    volumes = [
      "/workload/appdata/zwavejs:/usr/src/app/store:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "io.containers.autoupdate" = "registry";
      "traefik.enable" = "true";
      "traefik.http.services.zwavejs.loadbalancer.server.port" = "8091";
    };
    log-driver = "journald";
    extraOptions = [
      "--device=/dev/serial/by-id/usb-0658_0200-if00:/dev/zwave"
      "--network-alias=zwavejs"
      "--network=reverse-proxy"
      "--healthcheck-command=/bin/sh -c 'wget --no-verbose --spider --no-check-certificate --header \"Accept: text/plain\" http://localhost:8091/health || exit 1'"
      "--healthcheck-interval=1m"
      "--healthcheck-timeout=10s"
      "--healthcheck-start-period=30s"
      "--healthcheck-retries=3"
      "--sdnotify=healthy"
    ];
  };
  systemd.services."podman-zwavejs" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-reverse-proxy.service"
      "zfs.target"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "zfs.target"
    ];
    partOf = [
      "podman-compose-hass-root.target"
    ];
    wantedBy = [
      "podman-compose-hass-root.target"
    ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-hass-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    partOf = [
      "podman-compose-root.target"
    ];
    wantedBy = [ 
      "multi-user.target"
      "podman-compose-root.target"
    ];
  };
}
