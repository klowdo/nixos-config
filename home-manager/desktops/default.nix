{
  imports = [
    # Packages with custom configs go here

    ./hyprland3
    # ./waybar.nix
    # ./i3
    ./gnome
  

    ########## Utilities ##########
    #    ./services/dunst.nix # Notification daemon
    #    ./waybar.nix # infobar
    #./rofi-wayland.nix #app launcher
    #./swww.nix #wallpaper daemon

    #    ./gtk.nix # mainly in gnome
    #    ./qt.nix # mainly in kde
    #./fonts.nix
  ];
}
