{config, lib, pkgs, ...}:
{
 environment.systemPackages = with pkgs; [
     # Place packages here
     vim
     wget
     google-chrome
     vscode
     gnome-tweaks
     dconf
     git
     cmake
     discord
     gcc
     curl
     blackbox-terminal
     nautilus
     sdl3
     SDL2
     gnumake
     git-credential-manager
     emacs
     ripgrep
     findutils
     coreutils
     hackgen-nf-font
     gh
     fd
     pandoc
     shellcheck
     virtualbox
     gnome-shell-extensions
   ];

}  
