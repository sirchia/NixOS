# Auto-generated using compose2nix v0.1.5.
{ pkgs, lib, ... }:

{
  # Containers
  virtualisation.oci-containers.containers."traefik" = {
    image = "docker.io/traefik:latest";
    cmd = [
      "--accesslog=false"
      "--accesslog.filepath=/var/log/traefik/access.log"
      "--api.dashboard=true"
      "--api.debug=true"
      "--log.level=INFO"
      "--log.filePath=/var/log/traefik/traefik.log"
      "--providers.docker=true"
      "--providers.docker.exposedbydefault=false"
      "--providers.docker.endpoint=tcp://dockerproxy:2375"
      "--providers.docker.network=reverse-proxy"
      "--providers.docker.defaultRule=Host(`{{ normalize .Name }}.sirchia.nl`) && ClientIP(`192.168.1.0/24`,`127.0.0.1`,`172.16.0.0/12`,`10.0.0.0/8`, `100.64.0.0/10`)"
      #"--providers.docker.defaultRule=Host(`{{ index .Labels \"com.docker.compose.service\" }}.sirchia.nl`) && ClientIP(`192.168.1.0/24`,`127.0.0.1`,`172.16.0.0/12`,`10.0.0.0/8`, `100.64.0.0/10`)"
      "--providers.file.directory=/etc/traefik/config.d"
      "--entrypoints.web.address=:80"
      "--entrypoints.web.http.redirections.entryPoint.to=websecure"
      "--entrypoints.web.http.redirections.entryPoint.scheme=https"
      "--entrypoints.websecure.address=:443"
      "--entrypoints.websocket.address=:3688"
      "--certificatesresolvers.letsencrypt.acme.dnschallenge=true"
      "--certificatesresolvers.letsencrypt.acme.dnschallenge.provider=cloudflare"
      "--certificatesresolvers.letsencrypt.acme.dnschallenge.resolvers=1.1.1.1:53,1.0.0.1:53"
      "--certificatesresolvers.letsencrypt.acme.email=sirchia.r@gmail.com"
      "--certificatesresolvers.letsencrypt.acme.storage=/etc/traefik/acme/acme.json"
      "--serversTransport.insecureSkipVerify=true"
      "--entrypoints.websecure.http.tls=true"
      "--entrypoints.websecure.http.tls.certResolver=letsencrypt"
      "--entrypoints.websecure.http.tls.domains[0].main=sirchia.nl"
      "--entrypoints.websecure.http.tls.domains[0].sans=*.sirchia.nl"
      "--experimental.plugins.geoblock.modulename=github.com/PascalMinder/geoblock"
      "--experimental.plugins.geoblock.version=v0.2.5"
    ];
    environmentFiles = [
      "/etc/nixos/container-services/traefik.env"
    ];
    volumes = [
      "/workload/appdata/traefik/etc:/etc/traefik:rw"
      "/workload/appdata/traefik/log:/var/log/traefik:rw"
      "/workload/appdata/traefik/plugins-storage:/plugins-storage:rw"
    ];
    ports = [
      "80:80/tcp"
      "443:443/tcp"
      "3688:3688/tcp"
    ];
    labels = {
      "diun.enable" = "true";
      "traefik.enable" = "true";
      "traefik.http.routers.traefik.service" = "api@internal";
    };
    dependsOn = [
      "dockerproxy"
    ];
    log-driver = "journald";
    extraOptions = [
      "--add-host=host.docker.internal:172.17.0.1"
      "--network-alias=traefik"
      "--network=reverse-proxy"
      "--network=socket-proxy"
    ];
  };
  systemd.services."podman-traefik" = {
    serviceConfig = {
      Restart = lib.mkOverride 500 "always";
    };
    after = [
      "podman-network-socket-proxy.service"
      "podman-network-reverse-proxy.service"
      "workload.mount"
    ];
    requires = [
      "podman-network-socket-proxy.service"
      "podman-network-reverse-proxy.service"
      "workload.mount"
    ];
    partOf = [
      "podman-compose-traefik-root.target"
    ];
    wantedBy = [
      "podman-compose-traefik-root.target"
    ];
  };
  virtualisation.oci-containers.containers."traefik-certs-dumper" = {
    image = "ghcr.io/kereis/traefik-certs-dumper:multi-arch-builds-alpine";
    volumes = [
      "/workload/appdata/traefik/etc/acme/acme.json:/traefik/acme.json:ro"
      "/workload/appdata/traefik-certs-dumper:/output:rw"
    ];
    log-driver = "journald";
    extraOptions = [
      "--init"
      "--network-alias=traefik-certs-dumper"
      "--network=reverse-proxy"
      "--healthcheck-command=pgrep dump"
      "--healthcheck-interval=1m"
      "--healthcheck-timeout=5s"
      "--healthcheck-retries=3"
      "--healthcheck-start-period=30s"
    ];
  };
  systemd.services."podman-traefik-certs-dumper" = {
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
      "podman-compose-traefik-root.target"
    ];
    wantedBy = [
      "podman-compose-traefik-root.target"
    ];
  };

  # Networks
  systemd.services."podman-network-reverse-proxy" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${pkgs.podman}/bin/podman network rm -f reverse-proxy";
    };
    script = ''
      podman network inspect reverse-proxy || podman network create reverse-proxy --opt isolate=true
    '';
    partOf = [ "podman-compose-traefik-root.target" ];
    wantedBy = [ "podman-compose-traefik-root.target" ];
  };
  systemd.services."podman-network-socket-proxy" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${pkgs.podman}/bin/podman network rm -f socket-proxy";
    };
    script = ''
      podman network inspect socket-proxy || podman network create socket-proxy --opt isolate=true
    '';
    partOf = [ "podman-compose-traefik-root.target" ];
    wantedBy = [ "podman-compose-traefik-root.target" ];
  };

  # Root service
  # When started, this will automatically create all resources and start
  # the containers. When stopped, this will teardown all resources.
  systemd.targets."podman-compose-traefik-root" = {
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
