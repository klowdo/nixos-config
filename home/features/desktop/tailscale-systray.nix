# Tailscale is a VPN service that works on top of WireGuard.
# It allows me to access my servers and devices from anywhere.
{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.features.desktop.tailscale-systray;
in {
  options.features.desktop.tailscale-systray.enable = mkEnableOption "enable tailscale-systray";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [tailscale tailscale-systray];

    wayland.windowManager.hyprland.settings.exec-once = ["${pkgs.tailscale-systray}/bin/tailscale-systray"];
  };
}
