{
  lib,
  config,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.which-key;
  defaults = config.features.defaults;
  caelestiaEnabled = config.features.desktop.bar.caelestia.enable or false;
  lockCmd =
    if caelestiaEnabled
    then "caelestia shell lock lock"
    else "${pkgs.hyprlock}/bin/hyprlock";
  yamlFormat = pkgs.formats.yaml {};

  whichKeyConfig = {
    font = "JetBrainsMono Nerd Font 12";
    background = "#1e1e2ed0";
    color = "#cdd6f4";
    border = "#89b4fa";
    separator = " → ";
    border_width = 2;
    corner_r = 12;
    padding = 16;
    anchor = "center";

    menu = [
      {
        key = "a";
        desc = "Apps";
        submenu = [
          {
            key = "b";
            desc = "Browser";
            cmd = defaults.browser.command;
          }
          {
            key = "t";
            desc = "Terminal";
            cmd = "${defaults.terminal.command} -e t";
          }
          {
            key = "T";
            desc = "Terminal (plain)";
            cmd = defaults.terminal.command;
          }
          {
            key = "f";
            desc = "File Manager";
            cmd = defaults.fileManager.command;
          }
          {
            key = "r";
            desc = "Launcher";
            cmd = defaults.launcher.command;
          }
        ];
      }
      {
        key = "w";
        desc = "Window";
        submenu = [
          {
            key = "s";
            desc = "Toggle Split";
            cmd = "hyprctl dispatch togglesplit";
          }
          {
            key = "f";
            desc = "Maximize";
            cmd = "hyprctl dispatch fullscreen 1";
          }
          {
            key = "F";
            desc = "Fullscreen";
            cmd = "hyprctl dispatch fullscreen 0";
          }
          {
            key = "g";
            desc = "Float";
            cmd = "hyprctl dispatch togglefloating";
          }
          {
            key = "q";
            desc = "Kill";
            cmd = "hyprctl dispatch killactive";
          }
        ];
      }
      {
        key = "s";
        desc = "Screenshot";
        submenu = [
          {
            key = "s";
            desc = "Copy region";
            cmd = "grim -g \"$(slurp)\" - | wl-copy";
          }
          {
            key = "a";
            desc = "Annotate";
            cmd = "grim -g \"$(slurp)\" - | satty -f -";
          }
          {
            key = "f";
            desc = "Full screen";
            cmd = "grim - | wl-copy";
          }
        ];
      }
      {
        key = "p";
        desc = "Power";
        submenu = [
          {
            key = "l";
            desc = "Lock";
            cmd = lockCmd;
          }
          {
            key = "s";
            desc = "Suspend";
            cmd = "systemctl suspend";
          }
          {
            key = "r";
            desc = "Reboot";
            cmd = "systemctl reboot";
          }
          {
            key = "p";
            desc = "Poweroff";
            cmd = "systemctl poweroff";
          }
          {
            key = "e";
            desc = "Logout";
            cmd = "hyprctl dispatch exit 0";
          }
        ];
      }
      {
        key = "c";
        desc = "Clipboard";
        submenu = [
          {
            key = "v";
            desc = "Paste history";
            cmd = "clipboard-menu";
          }
          {
            key = "c";
            desc = "Clear";
            cmd = "clipboard-clear";
          }
          {
            key = "d";
            desc = "Delete entry";
            cmd = "clipboard-delete";
          }
        ];
      }
      {
        key = "u";
        desc = "Utilities";
        submenu = [
          {
            key = "e";
            desc = "Emoji";
            cmd = "wofi-emoji fill";
          }
          {
            key = "b";
            desc = "Bitwarden";
            cmd = "wofi-bitwarden";
          }
          {
            key = "a";
            desc = "Audio select";
            cmd = "audio-select";
          }
        ];
      }
      {
        key = "t";
        desc = "Theme toggle";
        cmd = "darkman toggle";
      }
    ];
  };
in {
  options.features.desktop.which-key = {
    enable = mkEnableOption "wlr-which-key keybinding menu";
  };

  config = mkIf cfg.enable {
    home.packages = [pkgs.wlr-which-key];

    xdg.configFile."wlr-which-key/config.yaml".source =
      yamlFormat.generate "config.yaml" whichKeyConfig;

    wayland.windowManager.hyprland.settings.bind = [
      "SUPER, slash, exec, wlr-which-key"
    ];
  };
}
