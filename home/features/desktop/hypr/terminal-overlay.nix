{
  wayland.windowManager.hyprland.settings = {
    workspace = [
      "special:terminal, on-created-empty:$terminal"
    ];

    windowrulev2 = [
      "float, onworkspace:special:terminal"
      "size 70% 70%, onworkspace:special:terminal"
      "center, onworkspace:special:terminal"
    ];

    bind = [
      "SUPER, o, togglespecialworkspace, terminal"
      "SUPER CTRL, 1, togglespecialworkspace, terminal"
    ];
  };
}
