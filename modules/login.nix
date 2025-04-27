
{config, pkgs, ...}:
{
    users.users.bpatch = {
        isNormalUser = true;
        description = "Briar Alexander Johnson";
        extraGroups = [ "networkmanager" "wheel" ];
        password = null;
        initialPassword = "$y$j9T$YoLwIiX7vsFWUQ76xsmH.1$FbR/q17wQSqyWaFyr/OSeeFUbPeVuS/HQFzgl3alhN3";
        hashedPassword = null;
        initialHashedPassword = null;
        packages = with pkgs; [
        #  thunderbird
        ];
    };









}
