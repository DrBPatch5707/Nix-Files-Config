{config, lib, pkgs, ...}:
{
 environment.systemPackages = with pkgs; [
     # Place packages here
     vim
     wget
     google-chrome
     vscode
     gnome.gnome-tweaks
     dconf
     git
     cmake
     discord
     gcc
     curl
     blackbox-terminal
     gnome.nautilus
     sdl3
     SDL2
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
     #gnome-shell-extensions
   ];

}  
