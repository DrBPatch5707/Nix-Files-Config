{ config, pkgs, ... }:

{
  imports = [
    ./inports/hardware-configuration.nix
    ./inports/login.nix
    ./inports/setPkgs.nix
    ./inports/boot.nix
    #Custom pkgs---------------------
    ./customPkgs/chrome.nix
    ./customPkgs/configScript.nix
    ./customPkgs/doom.nix
  ];
}
#If you add an import don't forget to edit the configScript.nix as necessary.