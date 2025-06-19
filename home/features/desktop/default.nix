{pkgs, ...}: {
  imports = [
    ./fonts.nix
    ./wayland.nix
    ./hyprland.nix
    ./notification.nix
  ];

  home.packages = with pkgs; [
  ];
}
