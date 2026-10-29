{...}: {
  imports = [
    ./fonts.nix
    # ./wayland.nix  # Linux-only: XDG portals, Qt6 Wayland
    # ./hypr  # Linux-only: Hyprland compositor + related tools
    # ./notification.nix  # Linux-only: libnotify
    # ./clipboard.nix  # Linux-only: wofi, cliphist, wl-clipboard
    # ./tailscale-systray.nix  # Linux-only: Hyprland settings
    # ./calculator.nix  # Linux-only: Hyprland integration
    # ./todo.nix  # Linux-only: wofi
    # ./filemanagers  # May have Linux-only deps
    ./darkman.nix
    # ./vicinae.nix  # Linux-only: uses systemd, Wayland, Hyprland
    # ./defaults.nix  # Linux-only: uses xdg.desktopEntries
    # ./bar  # Linux-only: Hyprland-related
    ./bitwarden.nix
    # ./which-key.nix  # Linux-only: depends on Hyprland defaults
    # ./solaar.nix  # Linux-only: solarized device manager
    # ./kando.nix  # Linux-only: custom keybind app
    # ./auto-claude.nix  # Linux-only: uses xdg.desktopEntries
    # ./munder-difflin.nix  # Linux-only: likely uses systemd
    # ./wayscriber.nix  # Linux-only: depends on which-key
    # ./stylix.nix  # Linux-only: Hyprland targets enabled
    # ./login-manager.nix  # Linux-only: GNOME login manager
    # ./icons.nix  # Linux-only: uses xdg.desktopEntries
    # ./monitor-webhook.nix  # Linux-only: uses systemd
    # ./go-hass-agent.nix  # Linux-only: systemd service
  ];
}
