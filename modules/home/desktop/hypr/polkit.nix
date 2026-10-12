{...}: {
  flake.modules.homeManager.polkit = {pkgs, ...}: {
    # hyprpolkitagent is required by applications that need elevated privileges (like firmware-manager)
    home.packages = with pkgs; [
      hyprpolkitagent
    ];

    wayland.windowManager.hyprland.settings = {
      exec-once = [
        "${pkgs.hyprpolkitagent}/libexec/hyprpolkitagent"
      ];

      windowrule = [
        "match:class (org.hyprland.polkitagent), float on"
        "match:class (org.hyprland.polkitagent), center on"
        "match:class (org.hyprland.polkitagent), dim_around on"
      ];
    };
  };
}
