{ config, lib, pkgs, ... }:
{
environment.systemPackages = with pkgs; [
(pkgs.writeShellScriptBin "config" ''

#!/run/current-system/sw/bin/bash

origin=$(pwd)
extensions_dir="$HOME/.vscode/extensions"
user_data_dir="$HOME/.bpatch-root"
destination="/etc/nixos/configuration.nix"
config_dir=" "

if [ -n "$1" ]; then
  case "$1" in
    "home")
      destination="$HOME/.config/home-manager/home.nix"
      config_dir="$HOME/.config/home-manager" 
      echo "accessing home-manager..."
      ;;
    *)
      echo "accessing main configuration..."
      config_dir="/etc/nixos" 
      ;;
  esac
else
  echo "accessing main configuration..."
  config_dir="/etc/nixos" 
fi

command="sudo code -w --no-sandbox --user-data-dir \"$user_data_dir\" --extensions-dir \"$extensions_dir\" \"$destination\""
      eval "$command"
      
cd "$config_dir" # Change to the correct directory before applying changes

echo "Saving changes from $(pwd)..."

if [ -n "$1" ]; then
  case "$1" in
    "home")
      eval "home-manager switch"
      ;;
    *)
      echo "building in test mode..."
      eval "sudo nixos-rebuild test"
      ;;
  esac
else
  eval "sudo nixos-rebuild switch"
fi

cd "$origin"
  '')
    ];
}