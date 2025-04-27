
{config, pkgs, ...}:
{
users.users.bpatch = {
    isNormalUser = true;
    description = "Briar Alexander Johnson";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
    #  thunderbird
    ];
   };









}
