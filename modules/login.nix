
{config, pkgs, ...}:
{
    users.users.bpatch = {
        isNormalUser = true;
        description = "Briar Alexander Johnson";
        extraGroups = [ "networkmanager" "wheel" ];
        hashedPasswordFile = "/etc/passwdConfig";
        password = null;
        initialPassword = null;
        hashedPassword = null;
        initialHashedPassword = null;
        packages = with pkgs; [
        #  thunderbird
        ];
    };









}
