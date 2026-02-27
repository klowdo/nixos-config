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
    windowrulev2 = [
      "float, class:(org.hyprland.polkitagent)"
      "center, class:(org.hyprland.polkitagent)"
      "dimaround, class:(org.hyprland.polkitagent)"
    ];
  };
}
