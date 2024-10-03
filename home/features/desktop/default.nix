{ pkgs, ... }: {
  imports = [
    ./wayland.nix
  ];

  home.packages = with pkgs; [
  ];
}
