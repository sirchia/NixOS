{ poolName ? "rootpool", disks ? [ "/dev/disk/by-id/nvme-WD_BLACK_SN770_1TB_2334H2404956" ], ...}: {
  disko.devices = {
    disk = {
      nixos = {
        type = "disk";
        device = builtins.elemAt disks 0;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              start = "1M";
              type = "EF00";
              priority = 10000;
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            ${poolName} = {
              start = "2G";
              type = "BF00";
              content = {
                  type = "zfs";
                  pool = "${poolName}";
              };
            };
          };
        };
      };
    };
    zpool = {
      ${poolName} = {
        type = "zpool";
        options = {
          autotrim = "on";
        };
        rootFsOptions = {
          compression = "zstd";
          acltype = "posixacl";
          atime = "off";
          xattr = "sa";
          canmount = "off";
          "com.sun:auto-snapshot" = "false";
        };
        postCreateHook = "zfs set mountpoint=none ${poolName}";

        datasets = {
          "home" = {
            type = "zfs_fs";
            options.mountpoint = "/home";
            options.canmount = "off";
          };
          "home/functionary" = {
            type = "zfs_fs";
          };
          "home/root" = {
            type = "zfs_fs";
            options.mountpoint = "/root";
          };
          "home/sirchia" = {
            type = "zfs_fs";
          };
          "local" = {
            type = "zfs_fs";
            options.mountpoint = "/";
            options.canmount = "off";
          };
          "local/nix" = {
            type = "zfs_fs";
            mountpoint = "/nix";
          };
          "local/root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options.mountpoint = "/";
            postCreateHook = "zfs snapshot ${poolName}/local/root@blank";
          };
          "local/var" = {
            type = "zfs_fs";
            options.canmount = "off";
          };
          "local/var/cache" = {
            type = "zfs_fs";
          };
          "local/var/lib" = {
            type = "zfs_fs";
            options.canmount = "off";
          };
          "local/var/lib/containers" = {
            type = "zfs_fs";
          };
          "local/var/lib/docker" = {
            type = "zfs_fs";
          };
          "local/var/lib/systemd" = {
            type = "zfs_fs";
            options.canmount = "off";
          };
          "local/var/lib/systemd/timers" = {
            type = "zfs_fs";
          };
          "local/var/log" = {
            mountpoint = "/var/log";
            type = "zfs_fs";
          };
          "persist" = {
            type = "zfs_fs";
            mountpoint = "/persist";
            options.mountpoint = "/persist";
          };
          "workload" = {
            type = "zfs_fs";
            options.mountpoint = "/workload";
          };
        };
      };
    };
  };
}

