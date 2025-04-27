{ config, lib, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    (pkgs.writeShellScriptBin "doom" ''
      #!/usr/bin/env bash 
      set -euo pipefail 

      if [ "$#" -ge 1 ]; then
       sudo /home/bpatch/.config/emacs/bin/doom "$@"
      else
        echo "doom must be provided with at least one argument" >&2
        exit 1 
      fi
    '')
  ];
}
