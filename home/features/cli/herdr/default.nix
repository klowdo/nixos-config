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
    herdr-sesh
    herdr-annotate
    terminal-browser
    herdr-projects
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

  toml = pkgs.formats.toml {};

  seshConfig = toml.generate "herdr-sesh-config.toml" {
    version = 1;
    list.cache = true;
    tab = [
      {
        name = "git";
        pane = [
          {
            name = "lazygit";
            startup = "lazygit";
          }
        ];
      }
    ];
    workspace = [
      {
        name = "home";
        path = "~";
      }
      {
        name = "dotfiles";
        path = "~/.dotfiles";
        startup = "nvim";
        tabs = ["git"];
      }
      {
        name = "todo dotfiles";
        path = "~/.dotfiles";
        startup = "nvim docs/todo.md";
      }
      {
        name = "kixvim";
        path = "~/dev/github/kixvim";
        startup = "nvim";
        tabs = ["git"];
      }
      {
        name = "downloads";
        path = "~/Downloads";
        startup = "yazi";
      }
    ];
    rule = [
      {
        path_glob = "~/dev/**";
        tabs = ["git"];
      }
    ];
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
      (pkgs.runCommand "herdr-plugin-bins" {} "mkdir -p $out/bin && ln -s ${pkgs.herdr-sesh}/bin/* ${pkgs.terminal-browser}/bin/* ${pkgs.herdr-projects}/bin/* $out/bin")
    ];

    programs.claude-code = {
      skills.autoproject = "${pkgs.herdr-projects}/skill/autoproject";
      settings.hooks = genAttrs ["SessionStart" "UserPromptSubmit" "PostToolUse"] (_: [
        {
          matcher = "*";
          hooks = [
            {
              type = "command";
              command = "${getExe pkgs.herdr-projects} --root ${config.home.homeDirectory}/.herdr-projects hook --agent claude 2>/dev/null || true";
              timeout = 10;
            }
          ];
        }
      ]);
    };

    xdg.configFile."herdr/plugins.json".text = builtins.toJSON (map registryEntry plugins);
    xdg.configFile."herdr/plugins/config/fullerzz.sesh/config.toml".source = seshConfig;

    xdg.configFile."herdr/config.toml".source = toml.generate "herdr-config.toml" {
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
          (pluginAction "prefix+shift+s" "fullerzz.sesh.open-picker" "sesh picker")
          (pluginAction "prefix+backtick" "fullerzz.sesh.last" "previous workspace")
          (pluginAction "prefix+t" "herdr-better-worktrees.manage" "manage worktrees")
          (pluginAction "prefix+shift+p" "herdr-projects.open-popup" "projects")
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
