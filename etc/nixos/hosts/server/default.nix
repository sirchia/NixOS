# configuration.nix

{ config, pkgs, lib, ... }:

{
  # set scheduler for disks with zfs partitions
  services.udev.extraRules = ''
    KERNEL=="sd[a-z]*[0-9]*|mmcblk[0-9]*p[0-9]*|nvme[0-9]*n[0-9]*p[0-9]*", ENV{ID_FS_TYPE}=="zfs_member", ATTR{../queue/scheduler}="none"
  '';

  boot.kernelParams = [
    "i915.enable_guc=2"
  ];

  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  
  boot.initrd.kernelModules = [ "i915" ];

  environment.variables = {
    VDPAU_DRIVER = lib.mkIf config.hardware.opengl.enable (lib.mkDefault "va_gl");
  };

  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver # LIBVA_DRIVER_NAME=iHD
      vaapiVdpau
      libvdpau-va-gl
    ];
  };

  services.fstrim.enable = lib.mkDefault true;

  environment.systemPackages = with pkgs; [
    mesa

    #libva-utils     # HW video codec debugging utils
    #vdpauinfo       # HW video codec debugging utils
    #mpv             # HW video codec debugging utils
    #intel-gpu-tools # HW video codec debugging utils
    #nvtop-intel     # HW video codec debugging utils
  ];
}

