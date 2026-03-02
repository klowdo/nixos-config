{
  wayland.windowManager.hyprland.settings = {
    workspace = [
      "special:terminal, on-created-empty:$terminal"
    ];

    windowrule = [
      "match:workspace name:special:terminal, float on"
      "match:workspace name:special:terminal, size (monitor_w*0.7) (monitor_h*0.7)"
      "match:workspace name:special:terminal, center on"
    ];

    bind = [
      "SUPER, o, togglespecialworkspace, terminal"
      "SUPER CTRL, 1, togglespecialworkspace, terminal"
    ];
  };
}
