# Script to install nixos in an 
# Erase my darlings -style configuration
# Root is erased on boot.

function prompt {
	read -n 1 -srp $'Is this correct? (Y/n) ' key
	echo
	if [ "$key" == 'n' ]; then 
        exit
    fi
}

function init {
    nix-env -iA nixos.gitMinimal
}

function build_file_system {
    echo "Making File system"
    DCONFIG="$NIXDIR/disko-config.nix"
    DISK=$(grep -oP '(?<=disks \? \[ ")[^"]*' $DCONFIG)
    echo
    echo "Drive to erase and install nixos on is: $DISK"
    read -n 1 -srp $'Is this ok? (Y/n) ' key
    echo
    if [ "$key" == 'n' ]; then                                                                                             
        lsblk
        read -rp "Enter New Disk: " DISK
        echo "Nixos will be installed on: $DISK"  
        prompt
    fi

    echo "WARNING - About to erase $DISK and install NixOS."
    prompt

    NIX="nix --extra-experimental-features 'nix-command flakes'"
    disko="$NIX run github:nix-community/disko --"
    #disko="$NIX run /media/disko --"
    DISKO_CMD="$disko --mode zap_create_mount $DCONFIG --arg disks '[ ""\"""$DISK""\""" ]'"
    #DISKO_CMD="$disko --mode disko $DCONFIG --arg disks '[ ""\"""$DISK""\""" ]'"
    eval "$DISKO_CMD"

    echo "Disk configuration complete!"
    echo
}

function generate_config {
    ln -s /mnt/persist /persist
    $SCRIPTDIR/changepass.sh
    rm /persist
        
    # create configuration
    echo "Generating Config"
    # nixos-generate-config --root /mnt
    # For disko we generate a config with the --no-filesystems option
    nixos-generate-config --no-filesystems --root /mnt
    echo

    # Copy over our nixos config
    echo "Copying over our nixos configs"
    # Copy config files to new install

    cp -r "$NIXDIR"/* /mnt/etc/nixos
    # Copy these files into persist volume (we copy from destination to include the hardware.nix)
    mkdir -p /mnt/persist/etc/nixos
    cp -r /mnt/etc/nixos/* /mnt/persist/etc/nixos/

    echo "Copying over script files"
    mkdir -p /mnt/persist/scripts
    cp "$SCRIPTDIR"/* /mnt/persist/scripts
    
    # echo "Creating persist git path"
    # mkdir -p /mnt/persist/git
    # sudo chown 1000:users /mnt/persist/git
    
    # echo "Creating trash folder for user 1000 in /persist"
    # mkdir -p /mnt/persist/.Trash-1000
    # sudo chown 1000:users /mnt/persist/.Trash-1000
    # sudo chmod 700 /mnt/persist/.Trash-1000

    echo "Config generation complete!"   
}

function install_nix {
    echo
    read -n 1 -srp $'Would you like to install nixos now? (Y/n) ' key
    echo
    if [ "$key" == 'n' ]; then                                                                                      
        exit
    else 
        zfs mount rootpool/home/functionary
        zfs mount rootpool/home/sirchia
        zfs mount rootpool/home/root
        nixos-install --flake /mnt/etc/nixos#server --root /mnt/
    fi
}

# Make script independent of which dir it was run from
SCRIPTDIR=$(dirname "$0")
NIXDIR="$SCRIPTDIR/../etc/nixos"

init
build_file_system
generate_config
install_nix
echo "Install completed!"
echo "Reboot to use NixOS"


