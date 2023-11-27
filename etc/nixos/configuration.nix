# configuration.nix

{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [
      ./hardware-configuration.nix
      ./impermanence.nix
      ./users.nix
      ./myparams.nix
      #./podman.nix
      ./docker.nix
      (import ./disko-config.nix {
        poolName = "rootpool";
        disks = [ "/dev/disk/by-id/nvme-WD_BLACK_SN770_1TB_2334H2404956" ];
      })
    ];
  
  ### Nix options
  ###############
  # Re-use nixpkgs from flake for nix commands
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  nixpkgs.config.allowUnfree = true;
  # Enable flakes & new syntax
  nix.extraOptions = ''
    experimental-features = nix-command
    extra-experimental-features = flakes
  '';

  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.generationsDir.copyKernels = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 3;
  boot.kernelPackages = config.boot.zfs.package.latestCompatibleLinuxPackages;
  boot.kernelParams = [ "elevator=none" ];
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes ="/dev/disk/by-label";
  boot.zfs.extraPools =[ 
    "backuppool" 
    "disk1pool"
    "disk2pool"
    "disk3pool"
    "disk4pool"
    "paritypool"
  ];


  ####################
  ##  Localization  ##
  ####################
  time.timeZone = "Europe/Amsterdam";
  i18n.defaultLocale = "en_US.UTF-8";

  ################
  ##  Network  ###
  ################
  networking = {
    hostName = config.myParams.myhostname;
    hostId = config.myParams.myhostid;

    vlans.vlan40 = {
      id = 40;
      interface = "enp2s0";
    };

    # Open ports in firewall.
    firewall = {
      #TODO
      enable = false;
      allowedTCPPorts = [ 22 53 80 443 ];
      allowedUDPPorts = [ 53 ];
    };
  };


  ################
  ### Security ###
  ################

  # services.fwupd.enable = true;

  # Enable Apparmor
  # security.apparmor.enable = true;

  security.doas.enable = true;
  security.sudo.enable = false;


  ################
  ### Clean-Up ###
  ################

  # https://nixos.wiki/wiki/Storage_optimization
  nix.settings.auto-optimise-store = true;
  # Garbage Collection 
  nix.gc = {
    automatic = true;
    dates = "daily";
    options = "--delete-older-than 14d";
  };

  ################
  ### Programs ###
  ################

  # Set default editor
  environment.variables = {
    EDITOR = "vim";
  };

  environment.etc = {
    sanoid.source = "/nix/store/*/sanoid.conf";
    snapraid.source = "/nix/store/*/snapraid.conf";
  };

  # Shell
  # programs.zsh.enable = true;
  programs.fish = {
    enable = true;
    # interactiveShellInit = ''
    #   set fish_greeting "Welcome to fish shell!"
    # '';
  };

  programs.starship = {
    enable = true;
  };

  # System Packages
  environment.systemPackages = with pkgs; [
    (pkgs.writeScriptBin "sudo" ''exec doas "$@"'')
    vim
    git
    git-crypt
    tmux
    z-lua
    mergerfs
    iotop
    htop
    tree
    wget
    pkgs.unstable.apprise
    file
    sanoid
    smartmontools
    snapraid
  ];

  ############
  # Services #
  ############
  services.zfs.autoScrub.enable = true;
  
  services.smartd.enable = true;
  services.avahi = {
    enable = true;
    allowInterfaces = [ "enp2s0" "vlan40@enp2s0" ];
    # allowPointToPoint = true;
    reflector = true;
  };
 
  ### SSH ###
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };
  
  snapraid = {
    enable = true;
    contentFiles = [
      "/mnt/disk1/snapraid-content"
      "/mnt/disk2/snapraid-content"
      "/mnt/disk3/snapraid-content"
      "/mnt/disk4/snapraid-content"
    ];
    dataDisks = {
      d1 = "/mnt/disk1";
      d2 = "/mnt/disk2";
      d3 = "/mnt/disk3";
      d4 = "/mnt/disk4";
    };
    exclude = [
      "*.bak"
      "*.unrecoverable"
      "/tmp/"
      "/lost+found/"
      ".AppleDouble"
      "._AppleDouble"
      ".DS_Store"
      ".Thumbs.db"
      ".fseventsd"
      ".Spotlight-V100"
      ".TemporaryItems"
      ".Trashes"
      ".AppleDB"
    ];
    parityFiles = [
      "/mnt/parity/snapraid-parity"
    ];
  };

  fileSystems."/mnt/bootbackup" = { 
    device = "/dev/disk/by-uuid/5E03-342F";
    fsType = "vfat";
  };

  fileSystems."/mnt/storage" = {
    device = "/mnt/disk1:/mnt/disk2:/mnt/disk3:/mnt/disk4";
    fsType = "fuse.mergerfs";
    options = [ 
      "defaults"
      "nonempty"
      "allow_other"
      "use_ino"
      "cache.files=off"
      "moveonenospc=true"
      "category.create=mfs"
      "dropcacheonclose=true"
      "minfreespace=250G"
      "fsname=mergerfs"
    ];
  };

  services.samba-wsdd.enable = true; # make shares visible for windows 10 clients
  services.samba-wsdd.interface = "enp2s0"; # make shares visible for windows 10 clients
  services.samba = {
    enable = true;
    enableNmbd = false;
    securityType = "user";
    extraConfig = ''
      workgroup = Home
      server string = NixOS
      netbios name = NixOS
      security = user
      guest ok = yes
      guest account = nobody
      map to guest = bad user
      load printers = no
      passdb backend = tdbsam:/persist/etc/samba/passdb.tdb
    '';
    shares = {
      storage = {
        path = "/mnt/storage";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        #"force user" = "timemachine";
        #"force group" = "timemachine";
      };
      timemachine = {
        path = "/mnt/backup/TimeMachine";
        "valid users" = "timemachine";

        #public = "no";
        browseable = "yes";

        writable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "timemachine";
        "force group" = "timemachine";
        "fruit:aapl" = "yes";
        "fruit:time machine" = "yes";
        "vfs objects" = "catia fruit streams_xattr";
      };
    };
  };

  services.sanoid = {
    enable = true;

    #extraArgs = [ "--verbose" "--debug" ];

    datasets = {
      "rootpool" = {
        useTemplate = [ "none" ];
        recursive = true;
      };
      "rootpool/home" = {
        useTemplate = [ "backup" ];
        recursive = true;
        process_children_only = true;
      };
      "rootpool/local/root".useTemplate = [ "temporary" ];
      "rootpool/persist".useTemplate = [ "backup" ];
      "rootpool/workload".useTemplate = [ "temporary" ];
    };

    
    templates = {
      none = {
        frequently = 0;
        hourly = 0;
        daily = 0;
        monthly = 0;
        yearly = 0;
        autosnap = true;
        autoprune = true;
      };
      temporary = {
        frequently = 0;
        hourly = 24;
        daily = 7;
        monthly = 0;
        yearly = 0;
        autosnap = true;
        autoprune = true;
      };
      backup = {
        frequently = 0;
        hourly = 24;
        daily = 30;
        monthly = 12;
        yearly = 5;
        autosnap = true;
        autoprune = true;
      };
    };
  };

  system.autoUpgrade = {
    enable = true;
    flake = "/etc/nixos";
    flags = [
      #"--update-input"
      #"nixpkgs"
      "-L" # print build logs
      #"--commit-lock-file"
    ];
    dates = "Sat 02:00";
    randomizedDelaySec = "45min";
  };

  systemd.services = {
    "notify-service-failure@" = {
      enable = true;
      description = "Send notifications when %i returns a failure";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/persist/scripts/notify-service failure %i";
      };
    };

    "notify-service-success@" = {
      enable = true;
      description = "Send notifications when %i returns a success";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/persist/scripts/notify-service success %i";
      };
    };

    "sanoid-snapshot-health" = {
      enable = true;
      description = "Verify the health of Sanoid snapshots";
      unitConfig = {
        OnFailure = "notify-service-failure@%i.service";
        OnSuccess = "notify-service-success@%i.service";
      };
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/run/current-system/sw/bin/sanoid --run-dir=/var/run/sanoid-monitor --cache-dir=/var/cache/sanoid-monitor --monitor-snapshots";
      };
    };

    "boot-backup" = {
      enable = true;
      description = "Local backup of boot partition";
      unitConfig = {
        OnFailure = "notify-service-failure@%i.service";
        OnSuccess = "notify-service-success@%i.service";
      };
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/run/current-system/sw/bin/rsync -a /boot/ /mnt/bootbackup";
      };
    };

    "syncoid-local-backup" = {
      enable = true;
      description = "Local backup of main disk";
      unitConfig = {
        OnFailure = "notify-service-failure@%i.service";
        OnSuccess = "notify-service-success@%i.service";
      };
      serviceConfig = {
        Type = "oneshot";
        Environment = "HOME=%h";
        ExecStartPre = "/bin/sh -c 'if ! /run/current-system/sw/bin/zpool list nvmebackuppool &> /dev/null; then /run/current-system/sw/bin/zpool import nvmebackuppool -R /mnt/nvmebackup; fi'";
        ExecStart = "/run/current-system/sw/bin/syncoid rootpool nvmebackuppool --recursive --skip-parent --delete-target-snapshots --force-delete --preserve-properties";
      };
    };

    sanoid.unitConfig.OnFailure = "notify-service-failure@%i.service";
    sanoid.unitConfig.OnSuccess = "notify-service-success@%i.service";
    snapraid-sync.unitConfig.OnFailure = "notify-service-failure@%i.service";
    snapraid-sync.unitConfig.OnSuccess = "notify-service-success@%i.service";
    snapraid-scrub.unitConfig.OnFailure = "notify-service-failure@%i.service";
    snapraid-scrub.unitConfig.OnSuccess = "notify-service-success@%i.service";
    zfs-scrub.unitConfig.OnFailure = "notify-service-failure@%i.service";
    zfs-scrub.unitConfig.OnSuccess = "notify-service-success@%i.service";
    zpool-trim.unitConfig.OnFailure = "notify-service-failure@%i.service";
    zpool-trim.unitConfig.OnSuccess = "notify-service-success@%i.service";
    nixos-upgrade.unitConfig.OnFailure = "notify-service-failure@%i.service";
    nixos-upgrade.unitConfig.OnSuccess = "notify-service-success@%i.service";
    nixos-upgrade.serviceConfig.ExecStartPre = "/run/current-system/sw/bin/rm -f /persist/etc/nixos/flake.lock";
  };

  # Prevent mount failure from falling back to emergency console
  systemd.targets.local-fs.unitConfig.OnFailure = "";
    
  systemd.timers = {
    "boot-backup" = {
      description = "Backup boot partition after successful boot";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnBootSec = 300;
        Unit = "boot-backup.service";
      };
    };
    "sanoid-snapshot-health" = {
      description = "Hourly verification of Sanoid snapshot health";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "*:02";
        Persistent = true;
        Unit = "sanoid-snapshot-health.service";
      };
    };
    "syncoid-local-backup" = {
      description = "Daily local backup of main disk";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        Unit = "syncoid-local-backup.service";
      };
    };
  };

  # Read the doc before updating
  system.stateVersion = "23.05";

}

