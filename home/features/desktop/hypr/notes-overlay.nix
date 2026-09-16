{config, ...}: let
  terminal = config.features.defaults.terminal.command;
  notesDir = "${config.home.homeDirectory}/notes";
in {
  wayland.windowManager.hyprland.settings = {
    workspace = [
      "special:notes, on-created-empty:${terminal} -d ${notesDir} nvim index.md"
    ];

    windowrule = [
      "match:workspace name:special:notes, float on"
      "match:workspace name:special:notes, size (monitor_w*0.6) (monitor_h*0.7)"
      "match:workspace name:special:notes, center on"
    ];

    bind = [
      "SUPERSHIFT, N, togglespecialworkspace, notes"
    ];
  };

  features.desktop.which-key.extraMenu = [
    {
      key = "n";
      desc = "Notes";
      submenu = [
        {
          key = "n";
          desc = "Scratchpad (index)";
          cmd = "hyprctl dispatch togglespecialworkspace notes";
        }
        {
          key = "d";
          desc = "Daily note";
          cmd = "${terminal} -d ${notesDir} nvim index.md +'Obsidian today'";
        }
        {
          key = "s";
          desc = "Search notes";
          cmd = "${terminal} -d ${notesDir} nvim index.md +'Obsidian search'";
        }
      ];
    }
  ];
}
