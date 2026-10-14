{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.herdr;
  plugins = with pkgs; [
    herdr-bar
    vim-herdr-navigation
    herdr-better-worktrees
    herdr-spreader
    herdr-annotate
    terminal-browser
  ];

  registryEntry = plugin: {
    plugin_id = plugin.herdrPlugin.id;
    inherit (plugin.herdrPlugin) name;
    inherit (plugin) version;
    min_herdr_version = plugin.herdrPlugin.minHerdrVersion;
    manifest_path = "${plugin}/herdr-plugin.toml";
    plugin_root = "${plugin}";
    enabled = true;
    source.kind = "local";
  };

  pluginAction = key: command: description: {
    inherit key command description;
    type = "plugin_action";
  };
in {
  options.features.cli.herdr.enable = mkEnableOption "enable herdr agent multiplexer";

  config = mkIf cfg.enable {
    home.packages = [
      pkgs.unstable.herdr
      (pkgs.runCommand "herdr-plugin-bins" {} "mkdir -p $out/bin && ln -s ${pkgs.herdr-spreader}/bin/* ${pkgs.terminal-browser}/bin/* $out/bin")
    ];

    xdg.configFile."herdr/plugins.json".text = builtins.toJSON (map registryEntry plugins);

    xdg.configFile."herdr/config.toml".source = (pkgs.formats.toml {}).generate "herdr-config.toml" {
      onboarding = false;
      keys = {
        previous_agent = "prefix+(";
        next_agent = "prefix+)";
        focus_agent = "ctrl+1..9";
        switch_workspace = "prefix+shift+1..9";
        navigate_workspace_up = "shift+k";
        navigate_workspace_down = "shift+j";
        command = [
          (pluginAction "prefix+space" "herdr-bar.open" "command bar")
          (pluginAction "prefix+t" "herdr-better-worktrees.manage" "manage worktrees")
          (pluginAction "prefix+alt+b" "zenbu-labs.terminal-browser.open-split" "open browser split")
          (pluginAction "ctrl+h" "vim-herdr-navigation.left" "navigate left (vim/herdr)")
          (pluginAction "ctrl+j" "vim-herdr-navigation.down" "navigate down (vim/herdr)")
          (pluginAction "ctrl+k" "vim-herdr-navigation.up" "navigate up (vim/herdr)")
          (pluginAction "ctrl+l" "vim-herdr-navigation.right" "navigate right (vim/herdr)")
          (pluginAction "prefix+a" "annotate.capture" "annotate text")
          (pluginAction "prefix+shift+a" "annotate.copy-context" "copy annotations as context")
          (pluginAction "prefix+ctrl+a" "annotate.copy-archive" "copy annotations and archive them")
          (pluginAction "prefix+ctrl+v" "annotate.paste-archive" "paste annotations into the agent prompt")
          (pluginAction "prefix+ctrl+s" "annotate.send-archive" "send annotations to the agent")
          (pluginAction "prefix+m" "annotate.manage" "manage annotations")
          (pluginAction "prefix+alt+o" "annotate.open" "review documents in this folder")
          (pluginAction "prefix+shift+o" "annotate.last" "review the agent's last reply")
          (pluginAction "prefix+ctrl+o" "annotate.last-newest" "review the agent's newest reply")
        ];
      };
    };
  };
}
