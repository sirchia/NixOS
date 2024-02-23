# Auto-generated using compose2nix v0.1.5.
{ pkgs, lib, ... }:

{
  # Containers
  virtualisation.oci-containers.containers."jellyfin" = {
    image = "lscr.io/linuxserver/jellyfin:latest";
    environment = {
      JELLYFIN_PublishedServerUrl = "https://jellyfin.sirchia.nl:443";
      PGID = "1003";
      PUID = "1003";
      TZ = "Europe/Amsterdam";
      UMASK = "002";
      DOCKER_MODS = "linuxserver/mods:jellyfin-opencl-intel";
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
      "io.containers.autoupdate" = "registry";
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
      "zfs.target"
    ];
    requires = [
      "podman-network-macvlan_lan.service"
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "zfs.target"
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
      "io.containers.autoupdate" = "registry";
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
      "zfs.target"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "zfs.target"
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
      "io.containers.autoupdate" = "registry";
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
      "zfs.target"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "zfs.target"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."lidarr" = {
    image = "ghcr.io/hotio/lidarr:latest";
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
      "io.containers.autoupdate" = "registry";
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
      "zfs.target"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "zfs.target"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."listenarr" = {
    image = "ghcr.io/hotio/readarr:latest";
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
      "io.containers.autoupdate" = "registry";
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
      "zfs.target"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "zfs.target"
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
      "io.containers.autoupdate" = "registry";
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
      "zfs.target"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "zfs.target"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."overseerr" = {
    image = "ghcr.io/hotio/overseerr:latest";
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
      "io.containers.autoupdate" = "registry";
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
      "zfs.target"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "zfs.target"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."plex" = {
    image = "ghcr.io/hotio/plex:latest";
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
      "io.containers.autoupdate" = "registry";
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
      "zfs.target"
    ];
    requires = [
      "podman-network-macvlan_lan.service"
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "zfs.target"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."plextraktwatch" = {
    image = "ghcr.io/taxel/plextraktsync:latest";
    environment = {
      TZ = "Europe/Amsterdam";
    };
    volumes = [
      "/workload/appdata/plextraktwatch:/app/config:rw"
    ];
    labels = {
      "diun.enable" = "true";
      "io.containers.autoupdate" = "registry";
    };
    cmd = [
      "watch"
    ];
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
      "zfs.target"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "zfs.target"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."prowlarr" = {
    image = "ghcr.io/hotio/prowlarr:testing";
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
      "io.containers.autoupdate" = "registry";
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
      "zfs.target"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "zfs.target"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."qbittorrent" = {
    image = "ghcr.io/hotio/qbittorrent:latest";
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
      "io.containers.autoupdate" = "registry";
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
      "zfs.target"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "zfs.target"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."radarr" = {
    image = "ghcr.io/hotio/radarr:latest";
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
      "io.containers.autoupdate" = "registry";
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
      "zfs.target"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "zfs.target"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."readarr" = {
    image = "ghcr.io/hotio/readarr:latest";
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
      "io.containers.autoupdate" = "registry";
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
      "zfs.target"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "zfs.target"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."sabnzbd" = {
    image = "ghcr.io/hotio/sabnzbd:latest";
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
      "io.containers.autoupdate" = "registry";
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
      "zfs.target"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "zfs.target"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."sonarr" = {
    image = "ghcr.io/hotio/sonarr:latest";
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
      "io.containers.autoupdate" = "registry";
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
      "zfs.target"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "mnt-storage.mount"
      "zfs.target"
    ];
    partOf = [
      "podman-compose-media-root.target"
    ];
    wantedBy = [
      "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."makemkv" = {
    image = "docker.io/jlesage/makemkv:latest";
    environment = {
      GROUP_ID = "1003";
      USER_ID = "1003";
      TZ = "Europe/Amsterdam";
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
    partOf = [
    #  "podman-compose-media-root.target"
    ];
    wantedBy = [
    #  "podman-compose-media-root.target"
    ];
  };
  virtualisation.oci-containers.containers."tautulli" = {
    image = "ghcr.io/hotio/tautulli:latest";
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
      "io.containers.autoupdate" = "registry";
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
      "zfs.target"
    ];
    requires = [
      "podman-network-reverse-proxy.service"
      "zfs.target"
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
      "multi-user.target"
    ];
  };
}
