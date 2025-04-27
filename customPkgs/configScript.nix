{ config, lib, pkgs, ... }:
{
environment.systemPackages = with pkgs; [
(pkgs.writeShellScriptBin "config" ''
#!/run/current-system/sw/bin/bash

origin=$(pwd)
extensions_dir="$HOME/.vscode/extensions"
user_data_dir="$HOME/.bpatch-root"
destination="/etc/nixos/configuration.nix"
config_dir="/etc/nixos"
# Function to update the configuration version and return the new version
update_config_version() {
  local version_file="$1"

  # Create the version file if it doesn't exist and initialize to v0.0.0
  if [ ! -f "$version_file" ]; then
    echo "v0.0.0" > "$version_file"
    echo "v0.2.2" # Return the initial incremented version
    return
  fi

  local current_version=$(cat "$version_file")
  IFS='.' read -r major minor patch <<< "$current_version"
  local new_patch=$((patch + 1))
  local new_version="v$major.$minor.$new_patch"
  echo "$new_version" > "$version_file"
  echo "$new_version" # Return the new version
}

if [ -n "$1" ]; then
  case "$1" in
    "home")
      destination="$HOME/.config/home-manager/home.nix"
      config_dir="$HOME/.config/home-manager" 
      echo "accessing home-manager..."
      ;;
      "pkgs")
      echo "accessing pkgs configuration..."
      destination="/etc/nixos/setPkgs.nix"
      ;;
       "im" | "imports")
      echo "accessing import configuration..."
      destination="/etc/nixos/imports.nix"
      ;;
       "login")
      echo "accessing login configuration..."
      destination="/etc/nixos/login.nix"
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

version_file="$config_dir/version.txt"

new_version=$(update_config_version "$version_file")

if [ -n "$1" ]; then
  case "$1" in
    "home")
      eval "home-manager switch"
      for arg in "$@"; do
      if [ "$arg" = "-np" ]; then
      echo "no push made"
      else
      eval "git add ."
     git commit -m "version $new_version"
      eval "git push origin home"
      fi
      done
      ;;
    "test")
      echo "building in test mode..."
      eval "sudo nixos-rebuild test"
      ;;
    *)
       if [ -n "$2" ]; then
      case "$1" in
       *)
        echo "building in test mode..."
        eval "sudo nixos-rebuild test"
        ;;
      esac
      else
       eval "sudo nixos-rebuild switch"
       for arg in "$@"; do
      if [ "$arg" = "-np" ]; then
      echo "no push made"
      else
       eval "git add ."
     git commit -m "version $new_version"
       eval "git push origin system"
       fi
       done
       fi
    ;;
  esac
else
  eval "sudo nixos-rebuild switch"
  eval "git add ."
 git commit -m "version $new_version"
  eval "git push origin system"
fi

cd "$origin"
  '')
    ];
}