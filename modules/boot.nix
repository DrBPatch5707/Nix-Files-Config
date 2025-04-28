{config, pkgs, ...}:
{
# Bootloader.
    boot= {
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
        kernelPackages = pkgs.linuxPackages;
        extraModulePackages = [ pkgs.virtualbox ];
        kernelModules = [ "vboxdrv" "vboxnetflt" "vboxnetadp" "vboxpci" ];
    };
    
}

