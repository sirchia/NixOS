# Auto-generated using compose2nix v0.1.5.
{ pkgs, lib, ... }:

{
  # Containers
  virtualisation.oci-containers.containers."jellyfin" = {
    image = "cr.hotio.dev/hotio/jellyfin";
    environment = {
      JELLYFIN_PublishedServerUrl = "https://jellyfin.sirchia.nl:443";
      PGID = "1003";
      PUID = "1003";
      TZ = "Europe/Amsterdam";
      UMASK = "002";
    };
    volumes = [
      "/mnt/storage/Audiobooks:/data/Audiobooks:rw"
      "/mnt/storage/Books:/data/Books:rw"
      "/mnt/storage/Disney:/data/Disney:rw"
      "/mnt/storage/Movies:/data/Movies:rw"
      "/mnt/storage/MoviesKids:/data/MoviesKids:rw"
      "/mnt/storage/TV:/data/TV:rw"
      "/mnt/storage/TVKids:/data/TVKids:rw"
      "/var/cache/jellyfin:/config/cache:rw"
      "/workload/appdata/jellyfin:/config:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "traefik.enable" = "true";
      "traefik.http.routers.jellyfin.entrypoints" = "web,websecure";
      "traefik.http.routers.jellyfin.middlewares" = "geoblock-ch@file";
      "traefik.http.routers.jellyfin.rule" = "Host(`jellyfin.sirchia.nl`)";
      "traefik.http.services.jellyfin.loadbalancer.server.port" = "8096";
    };
    log-driver = "journald";
    extraOptions = [
      "--device=/dev/dri:/dev/dri"
      "--network-alias=jellyfin"
      "--network=macvlan_lan:ip=192.168.1.230"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-jellyfin" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-macvlan_lan.service"
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "workload.mount"
    ];
    requires = [
      "podman-network-macvlan_lan.service"
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "workload.mount"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."jellyseerr" = {
    image = "docker.io/fallenbagel/jellyseerr:latest";
    environment = {
      LOG_LEVEL = "info";
      PGID = "1003";
      PUID = "1003";
      TZ = "Europe/Amsterdam";
      UMASK = "002";
    };
    volumes = [
      "/workload/appdata/jellyseerr:/app/config:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "traefik.enable" = "true";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=jellyseerr"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-jellyseerr" = {
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
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."kavita" = {
    image = "docker.io/kizaing/kavita:latest";
    environment = {
      TZ = "Europe/Amsterdam";
    };
    volumes = [
      "/mnt/storage/Books:/books:rw"
      "/workload/appdata/kavita:/kavita/config:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "traefik.enable" = "true";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=kavita"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-kavita" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "workload.mount"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "workload.mount"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."lidarr" = {
    image = "cr.hotio.dev/hotio/lidarr";
    environment = {
      PGID = "1003";
      PUID = "1003";
      TZ = "Europe/Amsterdam";
    };
    volumes = [
      "/mnt/storage:/data:rw"
      "/workload/appdata/lidarr:/config:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "traefik.enable" = "true";
      "traefik.http.services.lidarr.loadbalancer.server.port" = "8686";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=lidarr"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-lidarr" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "workload.mount"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "workload.mount"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."listenarr" = {
    image = "cr.hotio.dev/hotio/readarr:latest";
    environment = {
      PGID = "1003";
      PUID = "1003";
      TZ = "Europe/Amsterdam";
    };
    volumes = [
      "/mnt/storage:/data:rw"
      "/workload/appdata/listenarr:/config:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "traefik.enable" = "true";
      "traefik.http.services.listenarr.loadbalancer.server.port" = "8787";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=listenarr"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-listenarr" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "workload.mount"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "workload.mount"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."openbooks" = {
    image = "docker.io/evanbuss/openbooks:latest";
    environment = {
      PGID = "1003";
      PUID = "1003";
      TZ = "Europe/Amsterdam";
    };
    volumes = [
      "/mnt/storage/Books/import:/books/books:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "traefik.enable" = "true";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=openbooks"
      "--network=reverse-proxy"
    ];
    cmd = [
      "--name"
      "Moustaggio"
      "--persist"
      "--no-browser-downloads"
    ];
  };
  systemd.services."podman-openbooks" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "workload.mount"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "workload.mount"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."overseerr" = {
    image = "cr.hotio.dev/hotio/overseerr";
    environment = {
      PGID = "1003";
      PUID = "1003";
      TZ = "Europe/Amsterdam";
      UMASK = "002";
    };
    volumes = [
      "/workload/appdata/overseerr:/config:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "traefik.enable" = "true";
      "traefik.http.services.overseerr.loadbalancer.server.port" = "5055";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=overseerr"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-overseerr" = {
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
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."plex" = {
    image = "cr.hotio.dev/hotio/plex";
    environmentFiles = [
      "/etc/nixos/container-services/plex.env"
    ];
    volumes = [
      "/mnt/storage/Disney:/data/Disney:rw"
      "/mnt/storage/Movies:/data/Movies:rw"
      "/mnt/storage/MoviesKids:/data/MoviesKids:rw"
      "/mnt/storage/TV:/data/TV:rw"
      "/mnt/storage/TVKids:/data/TVKids:rw"
      "/var/cache/plex:/config/Cache:rw"
      "/workload/appdata/plex/config:/config:rw"
      "/workload/appdata/plex/transcode:/transcode:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "traefik.enable" = "true";
      "traefik.http.routers.plex.entrypoints" = "web,websecure";
      "traefik.http.routers.plex.middlewares" = "geoblock-ch@file";
      "traefik.http.routers.plex.rule" = "Host(`plex.sirchia.nl`)";
      "traefik.http.services.plex.loadbalancer.server.port" = "32400";
    };
    log-driver = "journald";
    extraOptions = [
      "--device=/dev/dri:/dev/dri"
      "--network-alias=plex"
      "--network=macvlan_lan:ip=192.168.1.228"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-plex" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-macvlan_lan.service"
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "workload.mount"
    ];
    requires = [
      "podman-network-macvlan_lan.service"
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "workload.mount"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."plextraktwatch" = {
    image = "ghcr.io/taxel/plextraktsync";
    environment = {
      TZ = "Europe/Amsterdam";
    };
    volumes = [
      "/workload/appdata/plextraktwatch:/app/config:rw"
    ];
    labels = {
      "diun.enable" = "true";
    };
    log-driver = "journald";
    extraOptions = [
      "--init"
      "--network-alias=plextraktwatch"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-plextraktwatch" = {
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
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."prowlarr" = {
    image = "cr.hotio.dev/hotio/prowlarr:testing";
    environment = {
      PGID = "1003";
      PUID = "1003";
      TZ = "Europe/Amsterdam";
    };
    volumes = [
      "/workload/appdata/prowlarr:/config:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "traefik.enable" = "true";
      "traefik.http.services.prowlarr.loadbalancer.server.port" = "9696";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=prowlarr"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-prowlarr" = {
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
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."qbittorrent" = {
    image = "cr.hotio.dev/hotio/qbittorrent";
    environment = {
      PGID = "1003";
      PUID = "1003";
      TZ = "Europe/Amsterdam";
    };
    volumes = [
      "/mnt/storage/Downloads:/data/Downloads:rw"
      "/workload/appdata/qbittorrent:/config:rw"
    ];
    ports = [
      "18888:18888/tcp"
      "18888:18888/udp"
    ];
    labels = {
      "diun.enable" = "true";
      "traefik.enable" = "true";
      "traefik.http.services.qbittorrent.loadbalancer.server.port" = "8080";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=qbittorrent"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-qbittorrent" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "workload.mount"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "workload.mount"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."radarr" = {
    image = "cr.hotio.dev/hotio/radarr";
    environment = {
      PGID = "1003";
      PUID = "1003";
      TZ = "Europe/Amsterdam";
    };
    volumes = [
      "/mnt/storage:/data:rw"
      "/workload/appdata/radarr:/config:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "traefik.enable" = "true";
      "traefik.http.services.radarr.loadbalancer.server.port" = "7878";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=radarr"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-radarr" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "workload.mount"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "workload.mount"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."readarr" = {
    image = "cr.hotio.dev/hotio/readarr:latest";
    environment = {
      PGID = "1003";
      PUID = "1003";
      TZ = "Europe/Amsterdam";
    };
    volumes = [
      "/mnt/storage:/data:rw"
      "/workload/appdata/readarr:/config:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "traefik.enable" = "true";
      "traefik.http.services.readarr.loadbalancer.server.port" = "8787";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=readarr"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-readarr" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "workload.mount"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "workload.mount"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."sabnzbd" = {
    image = "cr.hotio.dev/hotio/sabnzbd";
    environment = {
      PGID = "1003";
      PUID = "1003";
      TZ = "Europe/Amsterdam";
    };
    volumes = [
      "/mnt/storage/Downloads:/data/Downloads:rw"
      "/workload/appdata/sabnzbd:/config:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "traefik.enable" = "true";
      "traefik.http.services.sabnzbd.loadbalancer.server.port" = "8080";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=sabnzbd"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-sabnzbd" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "workload.mount"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "workload.mount"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."sonarr" = {
    image = "cr.hotio.dev/hotio/sonarr";
    environment = {
      PGID = "1003";
      PUID = "1003";
      TZ = "Europe/Amsterdam";
    };
    volumes = [
      "/mnt/storage:/data:rw"
      "/workload/appdata/sonarr:/config:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "traefik.enable" = "true";
      "traefik.http.services.sonarr.loadbalancer.server.port" = "8989";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=sonarr"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-sonarr" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "workload.mount"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "workload.mount"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."tautulli" = {
    image = "cr.hotio.dev/hotio/tautulli";
    environment = {
      PGID = "1003";
      PUID = "1003";
      TZ = "Europe/Amsterdam";
      UMASK = "002";
    };
    volumes = [
      "/workload/appdata/tautulli:/config:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "traefik.enable" = "true";
      "traefik.http.services.tautulli.loadbalancer.server.port" = "8181";
    };
    log-driver = "journald";
    extraOptions = [
      "--network-alias=tautulli"
      "--network=reverse-proxy"
    ];
  };
  systemd.services."podman-tautulli" = {
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
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-media-root" = {
    unitConfig = {
      Description = "Root target generated by compose2nix.";
    };
    partOf = [ "podman-compose-root.target" ];
    wantedBy = [ 
      "podman-compose-root.target"
      "default.target"
    ];
  };
}
