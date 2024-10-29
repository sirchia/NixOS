# configuration.nix

{ config, pkgs, lib, inputs, pkgs-unstable, ... }:

let
  isUnstable = config.boot.zfs.package == pkgs.zfsUnstable;
  zfsCompatibleKernelPackages = lib.filterAttrs (
    name: kernelPackages:
    (builtins.match "linux_[0-9]+_[0-9]+" name) != null
    && (builtins.tryEval kernelPackages).success
    && (
      (!isUnstable && !kernelPackages.zfs.meta.broken)
      || (isUnstable && !kernelPackages.zfs_unstable.meta.broken)
    )
  ) pkgs.linuxKernel.packages;
  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );
in
{
  imports =
    [
      ./hardware-configuration.nix
      ./impermanence.nix
      ./virtualization.nix
      ./users.nix
      ./myparams.nix
      (import ./disko-config.nix {
        poolName = "rootpool";
        disks = [ "/dev/disk/by-id/nvme-WD_BLACK_SN770_1TB_2334H2404956" ];
      })

      ./container-services
    ];
  
  ### Nix options
  ###############
  # Re-use nixpkgs from flake for nix commands
  nix.registry.nixpkgs.flake = inputs.nixpkgs;

  # Enable flakes & new syntax
  nix.extraOptions = ''
    experimental-features = nix-command
    extra-experimental-features = flakes
  '';

  boot.consoleLogLevel = 7;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.generationsDir.copyKernels = true;
  boot.loader.systemd-boot.enable = true;
  boot.loader.timeout = 3;
  boot.kernelModules = [ 
    "r8169"
    "igc"
    "netconsole"
  ];
  boot.extraModprobeConfig = "options netconsole netconsole=@192.168.1.2/eth1,6666@192.168.1.7/";
  boot.kernelPackages = latestKernelPackage;
  boot.kernelParams = [ 
    "panic=5"
  ];
  boot.supportedFilesystems = [ "zfs" ];
  boot.zfs.devNodes ="/dev/disk/by-label";
  boot.zfs.extraPools =[ 
    "backuppool" 
    "disk1pool"
    "disk2pool"
    "disk3pool"
    "disk4pool"
    "nvmebackuppool"
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

    # Disable dhcpcd as we use systemd-networkd
    dhcpcd.enable = false;
    useDHCP = false;
    useNetworkd = true;

    # Open ports in firewall.
    firewall = {
      #TODO
      enable = false;
      allowedTCPPorts = [ 22 53 80 443 ];
      allowedUDPPorts = [ 53 ];
    };
  };

  systemd.network = {
    enable = true;

    netdevs = {
      "20-vlan40" = {
        netdevConfig = {
          Kind = "vlan";
          Name = "vlan40";
        };
        vlanConfig.Id = 40;
      };
      # bridge access to macvlan containers on localhost
      "20-br-macvlan" = {
         netdevConfig = {
           Kind = "macvlan";
           Name = "br-macvlan";
         };
         macvlanConfig.Mode = "bridge";
      };
    };

    networks = {
      "40-enp2s0" = {
        matchConfig.Name = "enp2s0";
        networkConfig = {
          DHCP = "ipv4";
          IPv6AcceptRA = true;

          # LinkLocalAddressing = "no";
        };

        vlan = [
          "vlan40"
        ];

        macvlan = [
          "br-macvlan"
        ];

        linkConfig.RequiredForOnline = "routable";
      };

      "40-vlan40" = {
        matchConfig.Name = "vlan40";
        networkConfig = {
          DHCP = "ipv4";
        };
        linkConfig.RequiredForOnline = "no";
      };

      "40-br-macvlan" = {
        matchConfig.Name = "br-macvlan";

        address = [
          "192.168.1.225/27"
        ];
        linkConfig.RequiredForOnline = "no";
      };
    };
    wait-online.anyInterface = true;
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
  #don't optimize on every build, instead schedule automatic optimize
  #nix.settings.auto-optimise-store = true;
  nix.optimise.automatic = true;
  # Garbage Collection 
  nix.gc = {
    automatic = true;
    dates = "daily";
    randomizedDelaySec = "45min";
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

  programs.nano.enable=false;

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
    apprise
    inputs.compose2nix.packages.x86_64-linux.default
    file
    sanoid
    smartmontools
    snapraid
    quickemu
    unzip
    _7zz
  ];

  ############
  # Services #
  ############
  services.zfs.autoScrub.enable = true;
  services.zfs.autoScrub.interval = "monthly";
  
  services.smartd.enable = true;
  services.avahi = {
    enable = true;
    allowInterfaces = [ "enp2s0" "vlan40" ];
    nssmdns4 = true;
    openFirewall = true;
    publish = {
      enable = true;
      userServices = true;
    };
    reflector = true;
    extraServiceFiles = {
      smb = ''
        <?xml version="1.0" standalone='no'?><!--*-nxml-*-->
        <!DOCTYPE service-group SYSTEM "avahi-service.dtd">
        <service-group>
          <name replace-wildcards="yes">%h</name>
          <service>
            <type>_smb._tcp</type>
            <port>445</port>
          </service>
        </service-group>
      '';
    };
  };

  services.locate.enable = true;
 
  services.resolved = {
    domains = [
      "lan"
    ];
    extraConfig = ''
      MulticastDNS=false
    '';
    llmnr = "false";
  };

  ### SSH ###
  services.openssh = {
    enable = true;
    settings.PermitRootLogin = "no";
  };
  
  services.snapraid = {
    enable = true;
    contentFiles = [
      "/mnt/disk1/snapraid/content"
      "/mnt/disk2/snapraid/content"
      "/mnt/disk3/snapraid/content"
      "/mnt/disk4/snapraid/content"
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
      "/Sync/"
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
    sync.interval = "*-*-* 01:15:00";
  };

  fileSystems."/mnt/bootbackup" = { 
    device = "/dev/disk/by-uuid/5E03-342F";
    fsType = "vfat";
  };

  fileSystems."/mnt/storage" = {
    device = "/mnt/disk1:/mnt/disk2:/mnt/disk3:/mnt/disk4";
    fsType = "fuse.mergerfs";
    noCheck = true;
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

  services.samba-wsdd = {
    enable = true; # make shares visible for windows 10 clients
    interface = "enp2s0"; # make shares visible for windows 10 clients
    openFirewall = true;
  };

  services.samba = {
    enable = true;
    enableNmbd = false;
    enableWinbindd = false;
    openFirewall = true;
    securityType = "user";
    extraConfig = ''
      workgroup = Home
      server string = NixOS
      netbios name = NixOS
      security = user
      guest ok = no
      guest account = nobody
      map to guest = bad user
      load printers = no
      passdb backend = tdbsam:/persist/etc/samba/passdb.tdb
      fruit:aapl = yes
      fruit:advertise_fullsync = true
      fruit:metadata = stream
      fruit:model = MacPro7,1
      vfs objects = catia fruit streams_xattr acl_xattr
      min protocol = SMB2
      use sendfile = yes
      allow insecure wide links = yes
    '';
    shares = {
      storage = {
        path = "/mnt/storage";
        browseable = "yes";
        "read only" = "no";
        "create mask" = "0644";
        "directory mask" = "0755";
        "follow symlinks" = "yes";
        "wide links" = "yes";
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
        "create mask" = "0644";
        "directory mask" = "0755";
        "force user" = "timemachine";
        "force group" = "timemachine";
        "fruit:time machine" = "yes";
        "aio read size" = "1";
        "aio write size" = "1";
      };
    };
  };

  services.sanoid = {
    enable = true;

    #extraArgs = [ "--verbose" "--debug" ];

    datasets = {
      "disk1pool/disk1".useTemplate = [ "temporary" ];
      "disk2pool/disk2".useTemplate = [ "temporary" ];
      "disk3pool/disk3".useTemplate = [ "temporary" ];
      "disk4pool/disk4".useTemplate = [ "temporary" ];
      "disk4pool/disk4/Sync".useTemplate = [ "temporary" ];
      "rootpool" = {
        useTemplate = [ "none" ];
        recursive = true;
      };
      "rootpool/home" = {
        useTemplate = [ "backup" ];
        recursive = true;
        process_children_only = true;
      };
      "rootpool/home/sirchia/quickemu".useTemplate = [ "temporary" ];
      "rootpool/local/root".useTemplate = [ "temporary" ];
      "rootpool/local/var/lib/nixos".useTemplate = [ "temporary" ];
      "rootpool/persist".useTemplate = [ "backup" ];
      "rootpool/workload" = {
        useTemplate = [ "temporary" ];
        recursive = true;
      };
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

  services.syncoid = {
    enable = true;
    interval = "*-*-* 03:10:00";

    commands."local-backup" = {
      source = "rootpool";
      target = "nvmebackuppool";
      extraArgs = [
        "--recursive"
        "--skip-parent"
        "--delete-target-snapshots"
        "--preserve-properties"
        "--exclude=home/sirchia/quickemu"
      ];
      localSourceAllow = [
        "bookmark"
        "destroy"
        "hold"
        "mount"
        "release"
        "send"
        "snapshot"
      ];
      localTargetAllow = [
        "canmount"
        "change-key"
        "compression"
        "create"
        "destroy"
        "hold"
        "mount"
        "mountpoint"
        "receive"
        "release"
        "rollback"
      ];
      recvOptions = "u";  # don't auto-mount any new data sets
      sendOptions = "w";  # raw send
      service = { 
        unitConfig = {
          OnFailure = "notify-service-failure@%i.service";
          OnSuccess = "notify-service-success@%i.service";
        };
        serviceConfig = {
          Type = "oneshot";
        };
      };
    };

    commands."local-quickemu-backup" = {
      source = "rootpool/home/sirchia/quickemu";
      target = "backuppool/backup/quickemu";
      extraArgs = [
        "--recursive"
        "--delete-target-snapshots"
        "--preserve-properties"
      ];
      localSourceAllow = [
        "bookmark"
        "destroy"
        "hold"
        "mount"
        "release"
        "send"
        "snapshot"
      ];
      localTargetAllow = [
        "canmount"
        "change-key"
        "compression"
        "create"
        "destroy"
        "hold"
        "mount"
        "mountpoint"
        "receive"
        "release"
        "rollback"
      ];
      recvOptions = "u";  # don't auto-mount any new data sets
      sendOptions = "w";  # raw send
      service = { 
        unitConfig = {
          OnFailure = "notify-service-failure@%i.service";
          OnSuccess = "notify-service-success@%i.service";
        };
        serviceConfig = {
          Type = "oneshot";
        };
      };
    };

    commands."local-sync-backup" = {
      source = "disk4pool/disk4/Sync";
      target = "backuppool/backup/Sync";
      extraArgs = [
        "--recursive"
        "--delete-target-snapshots"
        "--preserve-properties"
      ];
      localSourceAllow = [
        "bookmark"
        "destroy"
        "hold"
        "mount"
        "release"
        "send"
        "snapshot"
      ];
      localTargetAllow = [
        "canmount"
        "change-key"
        "compression"
        "create"
        "destroy"
        "hold"
        "mount"
        "mountpoint"
        "receive"
        "release"
        "rollback"
      ];
      recvOptions = "u";  # don't auto-mount any new data sets
      sendOptions = "w";  # raw send
      service = { 
        unitConfig = {
          OnFailure = "notify-service-failure@%i.service";
          OnSuccess = "notify-service-success@%i.service";
        };
        serviceConfig = {
          Type = "oneshot";
        };
      };
    };
  };

  system.autoUpgrade = {
    enable = true;
    flake = "/etc/nixos";
    flags = [
      "-L" # print build logs
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
      wants = [ "podman-uptime.service" ];
      after = [ "podman-uptime.service" ];
    };

    "notify-service-success@" = {
      enable = true;
      description = "Send notifications when %i returns a success";
      serviceConfig = {
        Type = "oneshot";
        ExecStart = "/persist/scripts/notify-service success %i";
      };
      wants = [ "podman-uptime.service" ];
      after = [ "podman-uptime.service" ];
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


    zfs-import-nvmebackuppool.serviceConfig.Environment = "\"ZFS_FORCE=-R /mnt/nvmebackuppool\"";

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

    podman.environment.LOGGING = "--log-level=warning";
  };

  # Prevent mount failure from falling back to emergency console
  systemd.targets.local-fs.unitConfig.OnFailure = "";
  systemd.ctrlAltDelUnit = "";
    
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
  };

  # Read the doc before updating
  system.stateVersion = "23.11";

}

