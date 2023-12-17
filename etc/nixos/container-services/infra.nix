# Auto-generated using compose2nix v0.1.5.
{ pkgs, lib, ... }:

{
  # Containers
  virtualisation.oci-containers.containers."dockerproxy" = {
    image = "docker.io/tecnativa/docker-socket-proxy:latest";
    environment = {
      CONTAINERS = "1";
      IMAGES = "1";
      LOG_LEVEL = "warning";
    };
    volumes = [
      "/run/podman/podman.sock:/var/run/docker.sock:rw"
    ];
    ports = [
      "2375:2375/tcp"
    ];
    labels = {
      "diun.enable" = "true";
      "io.containers.autoupdate" = "registry";
    };
    log-driver = "journald";
    extraOptions = [
      "--healthcheck-interval=10s"
      "--healthcheck-timeout=5s"
      "--healthcheck-retries=10"
      "--healthcheck-command=/bin/sh -c 'wget --no-verbose --spider --no-check-certificate http://127.0.0.1:2375/version || exit 1'"
      "--sdnotify=healthy"
      "--network-alias=dockerproxy"
      "--network=socket-proxy"
    ];
  };
  systemd.services."podman-dockerproxy" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-socket-proxy.service"
      "podman.socket"
    ];
    requires = [
      "podman-network-socket-proxy.service"
      "podman.socket"
    ];
    partOf = [
      "podman-compose-infra-root.target"
    ];
    wantedBy = [
      "podman-compose-infra-root.target"
    ];
  };
  virtualisation.oci-containers.containers."diun" = {
    image = "docker.io/crazymax/diun:latest";
    environmentFiles = [
      "/etc/nixos/container-services/diun.env"
    ];
    volumes = [
      "/workload/appdata/diun:/data:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "io.containers.autoupdate" = "registry";
      "diun.watch_repo" = "false";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=diun"
      "--network=socket-proxy"
    ];
  };
  systemd.services."podman-diun" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "zfs.target"
      "podman-network-socket-proxy.service"
      "podman-dockerproxy.service"
    ];
    requires = [
      "zfs.target"
      "podman-network-socket-proxy.service"
      "podman-dockerproxy.service"
    ];
    partOf = [
      "podman-compose-infra-root.target"
    ];
    wantedBy = [
      "podman-compose-infra-root.target"
    ];
  };
  virtualisation.oci-containers.containers."dozzle" = {
    image = "docker.io/amir20/dozzle:latest";
    environment = {
      DOZZLE_NO_ANALYTICS = "true";
      DOZZLE_REMOTE_HOST = "tcp://dockerproxy:2375|sirchia.nl";
    };
    labels = {
      "diun.enable" = "true";
      "io.containers.autoupdate" = "registry";
      "traefik.enable" = "true";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=dozzle"
      "--network=reverse-proxy"
      "--network=socket-proxy"
    ];
  };
  systemd.services."podman-dozzle" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-socket-proxy.service"
      "podman-network-reverse-proxy.service"
      "podman-dockerproxy.service"
    ];
    requires = [
      "podman-network-socket-proxy.service"
      "podman-network-reverse-proxy.service"
      "podman-dockerproxy.service"
    ];
    partOf = [
      "podman-compose-infra-root.target"
    ];
    wantedBy = [
      "podman-compose-infra-root.target"
    ];
  };
  virtualisation.oci-containers.containers."hdidle" = {
    image = "docker.io/tekgator/docker-hd-idle:latest";
    environment = {
      PGID = "1003";
      PUID = "1003";
      TZ = "Europe/Amsterdam";
      UMASK = "002";
    };
    volumes = [
      "/dev/disk:/dev/disk:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "io.containers.autoupdate" = "registry";
    };
    log-driver = "journald";
    extraOptions = [
      "--cap-add=SYS_ADMIN"
      "--cap-add=SYS_RAWIO"
      "--device=/dev/sda:/dev/sda"
      "--device=/dev/sdb:/dev/sdb"
      "--device=/dev/sdc:/dev/sdc"
      "--device=/dev/sdd:/dev/sdd"
      "--device=/dev/sde:/dev/sde"
      "--device=/dev/sdf:/dev/sdf"
      "--device=/dev/sdg:/dev/sdg"
      "--device=/dev/sdh:/dev/sdh"
      "--network-alias=hdidle"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-hdidle" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-reverse-proxy.service"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
    ];
    partOf = [
      "podman-compose-infra-root.target"
    ];
    wantedBy = [
      "podman-compose-infra-root.target"
    ];
  };
  virtualisation.oci-containers.containers."omada" = {
    image = "docker.io/mbentley/omada-controller:latest";
    environment = {
      MANAGE_HTTPS_PORT = "8043";
      MANAGE_HTTP_PORT = "8088";
      PORTAL_HTTPS_PORT = "8843";
      PORTAL_HTTP_PORT = "8088";
      SHOW_MONGODB_LOGS = "false";
      SHOW_SERVER_LOGS = "true";
      SSL_CERT_NAME = "cert.pem";
      SSL_KEY_NAME = "key.pem";
      TZ = "Europe/Amsterdam";
    };
    volumes = [
      "/workload/appdata/traefik-certs-dumper/sirchia.nl:/cert:ro"
      "/workload/appdata/omada/data:/opt/tplink/EAPController/data:rw"
      "/workload/appdata/omada/logs:/opt/tplink/EAPController/logs:rw"
      "/workload/appdata/omada/work:/opt/tplink/EAPController/work:rw"
    ];
    ports = [
      "8043:8043/tcp"
      "29810:29810/udp"
      "29811:29811/tcp"
      "29812:29812/tcp"
      "29813:29813/tcp"
      "29814:29814/tcp"
    ];
    labels = {
      "diun.enable" = "true";
      "io.containers.autoupdate" = "registry";
      "traefik.enable" = "true";
      "traefik.http.middlewares.omada-headers.headers.customrequestheaders.Host" = "omada.sirchia.nl:8043";
      "traefik.http.middlewares.omada-headers.headers.customresponseheaders.Host" = "omada.sirchia.nl";
      "traefik.http.middlewares.omada-middlewares.chain.middlewares" = "omada-redirect,omada-headers";
      "traefik.http.middlewares.omada-redirect.redirectregex.regex" = "^https:\\/\\/([^\\/]+)\\/?$";
      "traefik.http.middlewares.omada-redirect.redirectregex.replacement" = "https://$1/login";
      "traefik.http.routers.omada.middlewares" = "omada-middlewares";
      "traefik.http.routers.omada.service" = "omada-svc";
      "traefik.http.services.omada-svc.loadbalancer.passhostheader" = "true";
      "traefik.http.services.omada-svc.loadbalancer.server.port" = "8043";
      "traefik.http.services.omada-svc.loadbalancer.server.scheme" = "https";
    };
    log-driver = "journald";
    extraOptions = [
      "--healthcheck-interval=10s"
      "--healthcheck-timeout=5s"
      "--healthcheck-retries=10"
      "--healthcheck-command=/bin/sh -c 'wget --no-verbose --spider --no-check-certificate https://localhost:8043 || exit 1'"
      "--sdnotify=healthy"
      "--network-alias=omada"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-omada" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "zfs.target"
      "podman-network-reverse-proxy.service"
    ];
    requires = [
      "zfs.target"
      "podman-network-reverse-proxy.service"
    ];
    partOf = [
      "podman-compose-infra-root.target"
    ];
    wantedBy = [
      "podman-compose-infra-root.target"
    ];
  };
  virtualisation.oci-containers.containers."pihole" = {
    image = "docker.io/pihole/pihole:latest";
    environmentFiles = [
      "/etc/nixos/container-services/pihole.env"
    ];
    volumes = [
      "/workload/appdata/pihole/bin/pihole_adlist_tool:/usr/bin/pihole_adlist_tool:rw"
      "/workload/appdata/pihole/dnsmasq.d:/etc/dnsmasq.d:rw"
      "/workload/appdata/pihole/etc:/etc/pihole:rw"
    ];
    ports = [
      "192.168.1.2:53:53/tcp"
      "192.168.1.2:53:53/udp"
    ];
    labels = {
      "diun.enable" = "true";
      "io.containers.autoupdate" = "registry";
      "traefik.enable" = "true";
      "traefik.http.services.pihole.loadbalancer.server.port" = "80";
    };
    log-driver = "journald";
    extraOptions = [
      "--healthcheck-interval=10s"
      "--healthcheck-timeout=5s"
      "--healthcheck-retries=10"
      "--healthcheck-command=/bin/sh -c 'dig pihole.sirchia.nl @192.168.1.2 || exit 1'"
      "--sdnotify=healthy"
      "--cap-add=CAP_NET_BIND_SERVICE"
      "--cap-add=NET_ADMIN"
      "--network-alias=pihole"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-pihole" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "zfs.target"
      "podman-network-reverse-proxy.service"
    ];
    requires = [
      "zfs.target"
      "podman-network-reverse-proxy.service"
    ];
    partOf = [
      "podman-compose-infra-root.target"
    ];
    wantedBy = [
      "podman-compose-infra-root.target"
    ];
  };
  virtualisation.oci-containers.containers."scrutiny" = {
    image = "ghcr.io/analogj/scrutiny:master-omnibus";
    volumes = [
      "/run/udev:/run/udev:ro"
      "/workload/appdata/scrutiny/config:/opt/scrutiny/config:rw"
      "/workload/appdata/scrutiny/influxdb:/opt/scrutiny/influxdb:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "io.containers.autoupdate" = "registry";
      "traefik.enable" = "true";
    };
    log-driver = "journald";
    extraOptions = [
      "--cap-add=SYS_ADMIN"
      "--cap-add=SYS_RAWIO"
      "--device=/dev/nvme0n1:/dev/nvme0n1"
      "--device=/dev/nvme1n1:/dev/nvme1n1"
      "--device=/dev/sda:/dev/sda"
      "--device=/dev/sdb:/dev/sdb"
      "--device=/dev/sdc:/dev/sdc"
      "--device=/dev/sdd:/dev/sdd"
      "--device=/dev/sde:/dev/sde"
      "--device=/dev/sdf:/dev/sdf"
      "--network-alias=scrutiny"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-scrutiny" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "zfs.target"
      "podman-network-reverse-proxy.service"
    ];
    requires = [
      "zfs.target"
      "podman-network-reverse-proxy.service"
    ];
    partOf = [
      "podman-compose-infra-root.target"
    ];
    wantedBy = [
      "podman-compose-infra-root.target"
    ];
  };
  virtualisation.oci-containers.containers."smokeping" = {
    image = "lscr.io/linuxserver/smokeping:latest";
    environment = {
      PGID = "1003";
      PUID = "1003";
      TZ = "Europe/Amsterdam";
    };
    volumes = [
      "/workload/appdata/smokeping/config:/config:rw"
      "/workload/appdata/smokeping/data:/data:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "io.containers.autoupdate" = "registry";
      "traefik.enable" = "true";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=smokeping"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-smokeping" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "zfs.target"
      "podman-network-reverse-proxy.service"
    ];
    requires = [
      "zfs.target"
      "podman-network-reverse-proxy.service"
    ];
    partOf = [
      "podman-compose-infra-root.target"
    ];
    wantedBy = [
      "podman-compose-infra-root.target"
    ];
  };
  virtualisation.oci-containers.containers."syncthing" = {
    image = "lscr.io/linuxserver/syncthing:latest";
    environment = {
      PGID = "1000";
      PUID = "1000";
      TZ = "Europe/Amsterdam";
    };
    volumes = [
      "/mnt/disk4/Sync:/data1:rw"
      "/workload/appdata/syncthing:/config:rw"
    ];
    ports = [
      "22000:22000/tcp"
      "22000:22000/udp"
      "21027:21027/udp"
    ];
    labels = {
      "diun.enable" = "true";
      "io.containers.autoupdate" = "registry";
      "traefik.enable" = "true";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=syncthing"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-syncthing" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "zfs.target"
      "podman-network-reverse-proxy.service"
      "mnt-disk4.mount"
    ];
    requires = [
      "zfs.target"
      "podman-network-reverse-proxy.service"
      "mnt-disk4.mount"
    ];
    partOf = [
      "podman-compose-infra-root.target"
    ];
    wantedBy = [
      "podman-compose-infra-root.target"
    ];
  };
  virtualisation.oci-containers.containers."uptime" = {
    image = "docker.io/louislam/uptime-kuma:latest";
    environment = {
      PGID = "1003";
      PUID = "1003";
      TZ = "Europe/Amsterdam";
    };
    volumes = [
      "/workload/appdata/uptime:/app/data:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "io.containers.autoupdate" = "registry";
      "traefik.enable" = "true";
    };
    log-driver = "journald";
    extraOptions = [
      "--healthcheck-interval=10s"
      "--healthcheck-timeout=5s"
      "--healthcheck-retries=10"
      "--healthcheck-command=/bin/sh -c 'curl http://uptime.lan:3001/api/push/pussaNWAJY?status=up&msg=OK&ping= || exit 1'"
      "--network-alias=uptime"
      "--network=reverse-proxy"
      "--network=socket-proxy"
      "--network=macvlan_lan:ip=192.168.1.231"
    ];
  };
  systemd.services."podman-uptime" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "zfs.target"
      "podman-network-socket-proxy.service"
      "podman-network-reverse-proxy.service"
      "podman-network-macvlan_lan.service"
      "podman-dockerproxy.service"
    ];
    before = [
      "notify-service-failure@.service"
      "notify-service-success@.service"
    ];
    requires = [
      "zfs.target"
      "podman-network-socket-proxy.service"
      "podman-network-reverse-proxy.service"
      "podman-network-macvlan_lan.service"
      "podman-dockerproxy.service"
    ];
    partOf = [
      "podman-compose-infra-root.target"
    ];
    wantedBy = [
      "podman-compose-infra-root.target"
      "notify-service-failure@.service"
      "notify-service-success@.service"
    ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-infra-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    partOf = [ "podman-compose-infra-root.target" ];
    wantedBy = [ 
      "podman-compose-root.target"
      "multi-user.target"
    ];
  };
}

