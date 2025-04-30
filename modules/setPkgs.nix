{config, lib, pkgs, ...}:
{
 environment.systemPackages = with pkgs; [
     # Place packages here
     wget
     google-chrome
     vscode
     kdevelop
     gnome-tweaks
     dconf
     git
     cmake
     ninja
     indent
     discord
     gdb
     curl
     blackbox-terminal
     nautilus
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
     nixos.nix-mode
   ];

}  
