{config, lib, pkgs, ...}:
{
 environment.systemPackages = with pkgs; [
     # Place packages here
     wget
     google-chrome
     vscode
     gnome-tweaks
     dconf
     git
     cmake
     discord
     gdb
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
     coreutils
     gh
     pandoc
     shellcheck
     qemu
     gnome-shell-extensions
     mpc
     nasm
     gcc_multi
     binutils
   ];

}  
