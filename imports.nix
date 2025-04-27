{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./login.nix
    ./setPkgs.nix
    ./boot.nix
    #Custom pkgs---------------------
    ./customPkgs/chrome.nix
    ./customPkgs/configScript.nix
    ./customPkgs/doom.nix
  ];
}
#If you add an import don't forget to edit the configScript.nix as necessary.