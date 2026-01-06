{
  lib,
  config,
  pkgs,
  ...
}:
# Example showing how to reference default applications in your config

{
  # Example 1: Using defaults in Hyprland keybindings
  wayland.windowManager.hyprland.settings.bind = [
    # Reference the browser from defaults
    "SUPER, B, exec, ${config.features.defaults.browser.command}"

    # Reference the terminal from defaults
    "SUPER, T, exec, ${config.features.defaults.terminal.command}"

    # Reference the file manager from defaults
    "SUPER, E, exec, ${config.features.defaults.fileManager.command}"

    # Use the launcher package path
    "SUPER, R, exec, ${config.features.defaults.launcher.package}/bin/${config.features.defaults.launcher.command} --show drun"
  ];

  # Example 2: Creating a script that uses defaults
  home.packages = [
    (pkgs.writeShellScriptBin "open-browser" ''
      ${config.features.defaults.browser.command} "$@"
    '')

    (pkgs.writeShellScriptBin "my-dmenu-script" ''
      selection=$(echo -e "Option 1\nOption 2\nOption 3" | ${config.features.defaults.launcher.dmenuMode})
      echo "You selected: $selection"
    '')
  ];

  # Example 3: Conditionally enable features based on defaults
  programs.something.enable = lib.mkIf
    (config.features.defaults.browser.command == "firefox")
    true;

  # Example 4: Using in custom systemd services
  systemd.user.services.my-service = {
    Service = {
      ExecStart = "${config.features.defaults.browser.command} --app=https://example.com";
      Environment = [
        "BROWSER=${config.features.defaults.browser.command}"
        "TERMINAL=${config.features.defaults.terminal.command}"
      ];
    };
  };
}
