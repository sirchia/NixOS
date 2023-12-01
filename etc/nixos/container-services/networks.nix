# Auto-generated using compose2nix v0.1.5.
{ pkgs, lib, ... }:

{
  # Networks
  systemd.services."podman-networks-macvlan_lan" = {
    path = [ pkgs.podman ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStop = "${pkgs.podman}/bin/podman network rm -f macvlan_lan";
    };
    script = ''
      podman network exists macvlan_lan || podman network create --driver macvlan --opt parent=enp2s0 --subnet 192.168.1.0/24 --ip-range 192.168.1.224/27 --gateway 192.168.1.1 macvlan_lan 
    '';
    partOf = [ "podman-compose-root.target" ];
    wantedBy = [ "podman-compose-root.target" ];
  };
}
