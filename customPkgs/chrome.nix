{ config, lib, pkgs, ... }:
{
environment.systemPackages = with pkgs; [
(pkgs.writeShellScriptBin "chrome" ''
    #!/bin/bash

    profile="Default" # Default profile
    url="www.google.com"   # Default URL

    # Check if the first argument (potential profile or URL) exists
    if [ -n "$1" ]; then
      case "$1" in
        "ace")
          profile="Profile 1"
          ;;
        "patch")
          profile="Default"
          ;;
        "school")
          profile="Profile 2"
          ;;
        "canva")
          profile="Profile 2"
          url="https://jcjc.instructure.com"
          ;;
         "git")
          url="https://github.com"
          ;;
        *)
          # If the first argument doesnt match a profile keyword, assume it's the URL
          url="$1"
          ;;
      esac
    fi

    # Check if the second argument exists and treat it as the URL (overriding if necessary)
    if [ -n "$2" ]; then
      url="$2"
    fi

    # Construct the command to run Chrome with the specified profile
    chrome_command="nohup google-chrome-stable --profile-directory=\"$profile\" \"$url\""

    # Execute the command
    eval "$chrome_command" > /dev/null 2>&1 &

    exit 0
     '')
    ];
}