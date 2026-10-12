{...}: {
  flake.modules.homeManager.calculator = {pkgs, ...}: {
    home.packages = with pkgs; [
      qalculate-gtk
      numara-calculator
    ];

    wayland.windowManager.hyprland.settings = {
      windowrule = [
        "match:class (qalculate-gtk), float on"
        "match:class (qalculate-gtk), size 800 600"
        "match:class (qalculate-gtk), center on"
        "match:class (qalculate-gtk), opacity 0.95"
      ];

      bind = [
        "SUPER, C, exec, qalculate-gtk"
      ];
    };
  };
}
