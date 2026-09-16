{config, ...}: {
  wayland.windowManager.hyprland.settings = {
    workspace = [
      "special:notes, on-created-empty:${config.features.defaults.terminal.command} -d ${config.home.homeDirectory}/notes nvim index.md"
    ];

    windowrule = [
      "match:workspace name:special:notes, float on"
      "match:workspace name:special:notes, size (monitor_w*0.6) (monitor_h*0.7)"
      "match:workspace name:special:notes, center on"
    ];

    bind = [
      "SUPER, N, togglespecialworkspace, notes"
    ];
  };
}
