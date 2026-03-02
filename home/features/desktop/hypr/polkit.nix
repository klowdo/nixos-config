{pkgs, ...}: {
  # Polkit authentication agent for Hyprland
  # Required for applications that need elevated privileges (like firmware-manager)

  home.packages = with pkgs; [
    hyprpolkitagent # Official Hyprland polkit agent
  ];

  # Auto-start the polkit agent with Hyprland
  wayland.windowManager.hyprland.settings = {
    exec-once = [
      "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
    ];

    # Window rules for polkit authentication dialog
    windowrule = [
      "match:class (org.hyprland.polkitagent), float on"
      "match:class (org.hyprland.polkitagent), center on"
      "match:class (org.hyprland.polkitagent), dim_around on"
    ];
  };
}
