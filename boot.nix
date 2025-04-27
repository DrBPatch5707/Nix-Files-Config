{config, pkgs, ...}:
{
# Bootloader.
    boot= {
        loader.systemd-boot.enable = true;
        loader.efi.canTouchEfiVariables = true;
    };











}

