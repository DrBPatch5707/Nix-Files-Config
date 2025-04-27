{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
      ./setPkgs.nix
      ./customPkgs/chrome.nix
     ./customPkgs/configScript.nix
  ];
}
