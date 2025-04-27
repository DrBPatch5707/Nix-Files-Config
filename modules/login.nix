
{config, pkgs, ...}:
{
    users.users.bpatch = {
        isNormalUser = true;
        description = "Briar Alexander Johnson";
        extraGroups = [ "networkmanager" "wheel" ];
        password = "$y$j9T$YoLwIiX7vsFWUQ76xsmH.1$FbR/q17wQSqyWaFyr/OSeeFUbPeVuS/HQFzgl3alhN3";
        initialPassword = "$y$j9T$YoLwIiX7vsFWUQ76xsmH.1$FbR/q17wQSqyWaFyr/OSeeFUbPeVuS/HQFzgl3alhN3";
        hashedPassword = "$y$j9T$YoLwIiX7vsFWUQ76xsmH.1$FbR/q17wQSqyWaFyr/OSeeFUbPeVuS/HQFzgl3alhN3";
        initialHashedPassword = "$y$j9T$YoLwIiX7vsFWUQ76xsmH.1$FbR/q17wQSqyWaFyr/OSeeFUbPeVuS/HQFzgl3alhN3";
        packages = with pkgs; [
        #  thunderbird
        ];
    };









}
