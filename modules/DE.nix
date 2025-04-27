{config, pkgs, ...}:
{
    # Enable the X11 windowing system.
    services.xserver.enable = true;

    # Enable the GNOME Desktop Environment.
    services.xserver.displayManager.gdm.enable = true;
    services.xserver.desktopManager.gnome.enable = true;
    services.gnome.core-utilities.enable = false;
    environment.sessionVariables = {
        "GSETTINGS_OVERRIDE" = ''
        [org/gnome/settings-daemon/plugins/media-keys/custom-keybindings]
        custom-keybindings=['/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/']

        [org/gnome/settings-daemon/plugins/media-keys/custom-keybinding/custom0]
        name='Launch Console'
        command='console'
        binding='<Super>l'
        '';
    };
        
        services.dconf = {
            enable = true;
            settings = {
                "org/gnome/desktop/background" = {
                    picture-uri = "../resources/WYD-background.jpg";
                    picture-options = "scaled"; # Or "stretched", "centered", "tiled", etc.
                };
            };

        };
}