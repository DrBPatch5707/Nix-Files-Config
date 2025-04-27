
{config, pkgs, ...}:
{
    users.users.bpatch = {
        isNormalUser = true;
        description = "Briar Alexander Johnson";
        extraGroups = [ "networkmanager" "wheel" ];
        hashedPasswordFile = "/etc/passwdConfig";
        packages = with pkgs; [
        #  thunderbird
        ];
    };









}
