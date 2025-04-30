{ config, lib, pkgs, ... }:
{
environment.systemPackages = with pkgs; [
(pkgs.writeShellScriptBin "config" ''
#!/run/current-system/sw/bin/bash
#<---Global--->#
origin=$(pwd)
extensions_dir="$HOME/.vscode/extensions"
user_data_dir="$HOME/.bpatch-root"
destination="/etc/nixos/configuration.nix"
config_dir="/etc/nixos"
is_push=""
#<---Global--->#



testArgs(){
for arg in "$@"; do
      if [ "$arg" = "-np" ]; then
      is_push="-np"
      fi
      done
}

# Function to update the configuration version and return the new version
update_config_version() {
  local version_file="$1"

  # Initialize if the file doesn't exist
  if [ ! -f "$version_file" ]; then
    echo "0.2.2" > "$version_file"
    echo "v0.2.3" # Return the initial incremented version with 'v'
    return
  fi

  local current_version=$(cat "$version_file")
  IFS='.' read -r major minor patch <<< "$current_version"

  # Provide default values using if conditions (Nix-friendly)
  if [ -z "$major" ]; then
    major="0"
  fi
  if [ -z "$minor" ]; then
    minor="0"
  fi
  if [ -z "$patch" ]; then
    patch="0"
  fi

  local new_patch=$((patch + 1))
  if [ "$new_patch" -gt 9 ]; then
    new_patch=0
    minor=$((minor + 1))
  fi
  if [ "$minor" -gt 9 ]; then
    minor=0
    major=$((major + 1))
  fi
  local new_version="v$major.$minor.$new_patch"
  echo "$major.$minor.$new_patch" > "$version_file" # Write without the leading 'v'
  echo "$new_version" # Return with the leading 'v'
}


openEditor(){
if [ -n "$1" ]; then
  case "$1" in
    "home")
      destination="$HOME/.config/home-manager/home.nix"
      config_dir="$HOME/.config/home-manager" 
      echo "accessing home-manager..."
      ;;
      "pkgs" | "pkg")
      echo "accessing pkgs configuration..."
      destination="/etc/nixos/modules/setPkgs.nix"
      ;;
       "im" | "imports")
      echo "accessing import configuration..."
      destination="/etc/nixos/imports.nix"
      ;;
       "login")
      echo "accessing login configuration..."
      destination="/etc/nixos/modules/login.nix"
      ;;
      "boot")
      echo "accessing boot configuration..."
      destination="/etc/nixos/modules/boot.nix"
      ;;
       "dsk" | "DE")
      echo "accessing Desktop Environment configuration..."
      destination="/etc/nixos/modules/DE.nix"
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
}









publish() {
if [ "$is_push" = "-np" ]; then
  echo "no push made..."
  else
  version_file="$config_dir/version.txt"
  eval "$(ssh-agent -s)"
  eval "ssh-add ~/.ssh/key.txt"
  new_version=$(update_config_version "$version_file")
  eval "git add ."
  git commit -m "version $new_version"
  case "$1" in
    "home")
    eval "git push origin home"
    ;;
    "system")
    eval "git push origin system"
    ;;
    *)
    echo "error: invalid argument past to publish function..."
    ;;
  esac
  fi
}



processChanges(){
echo "Saving changes from $(pwd)..."
if [ -n "$1" ]; then
  case "$1" in
    "home")
      eval "home-manager switch"
      publish "$1"
      ;;
    "test")
      echo "building in test mode..."
      eval "sudo nixos-rebuild test"
      ;;
    *)
       if [ -n "$2" ]; then
      case "$1" in #room for future args
       "test")
        echo "building in test mode..."
        eval "sudo nixos-rebuild test"
        ;;
        *)
        echo "invalid option..."
        ;;
      esac
      else
       eval "sudo nixos-rebuild switch"
      publish "system"
      fi
    ;;
  esac
else
  eval "sudo nixos-rebuild switch"
 publish "system"
fi
}

main(){
testArgs "$@"
openEditor "$@"
cd "$config_dir" # Change to the correct directory before applying changes
processChanges "$@"
cd "$origin"
}

main "$@"
  '')
    ];
}