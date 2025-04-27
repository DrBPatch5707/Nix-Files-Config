{ config, pkgs, ... }:

{
  imports = [
    #Modules-------------------------
    ./modules/hardware-configuration.nix
    ./modules/login.nix
    ./modules/setPkgs.nix
    ./modules/boot.nix
    ./modules/DE.nix
    #Custom pkgs---------------------
    ./customPkgs/chrome.nix
    ./customPkgs/configScript.nix
  ];
}
#If you add an import don't forget to edit the configScript.nix as necessary.