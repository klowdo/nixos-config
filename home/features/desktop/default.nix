{pkgs, ...}: {
  imports = [
    ./fonts.nix
    ./wayland.nix
    ./hyprland.nix
    ./notification.nix
    ./clipboard.nix
  ];

  home.packages = with pkgs; [
  ];
}
