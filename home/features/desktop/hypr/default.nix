{...}: {
  imports = [
    ./hyprland.nix
    ./hyprland-xdg-portal.nix
    ./hypridle.nix
    ./hyprland-binds.nix
    ./terminal-overlay.nix
    ./wofi.nix
    ./hyprlock.nix
    ./hyprlock-music-script.nix
    ./polkit.nix
  ];
}
