{ config, pkgs, ... }:

{
  #programs.dconf.enable = true;
  programs.virt-manager.enable = true;
  
  users.users.sirchia.extraGroups = [ "libvirtd" ];
  
  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice 
    # spice-gtk
    spice-protocol
    virtio-win
    win-spice
  ];
  
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        package = (pkgs.qemu_kvm.override { smbdSupport = true; }); # qemu with samba support
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };
  services.spice-vdagentd.enable = true;
}

