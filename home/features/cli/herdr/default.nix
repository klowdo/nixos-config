{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.herdr;
  herdrPlugins = pkgs.callPackage ./plugins.nix {};

  plugins = with herdrPlugins; [bar vimNavigation betterWorktrees spreader annotate];

  registryEntry = plugin: {
    plugin_id = plugin.pluginId;
    name = plugin.pluginName;
    inherit (plugin) version;
    min_herdr_version = plugin.minHerdrVersion;
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
    home.packages = [pkgs.unstable.herdr herdrPlugins.spreader];

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
