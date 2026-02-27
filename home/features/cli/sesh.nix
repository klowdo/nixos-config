{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.sesh;

  t-sesh-cmd = pkgs.writeShellScriptBin "t" ''
    sesh connect $(sesh list -i | gum filter  --limit 1 --no-sort --fuzzy --placeholder 'Pick a sesh' --height 50 --prompt='⚡')
  '';
in {
  options.features.cli.sesh.enable = mkEnableOption "enable sesh session manager";

  config = mkIf cfg.enable {
    programs.sesh = {
      enable = true;
      package = pkgs.unstable.sesh;
      enableAlias = true;
      enableTmuxIntegration = true;
      tmuxKey = "s";
      icons = true;

      settings = {
        import = [
          config.sops.secrets."sesh-work".path
        ];

        session = [
          {
            name = "home 🏠";
            path = "~";
          }
          {
            name = "github 😸";
            path = "~/dev/github/";
          }
          {
            name = "code 💻";
            path = "~/dev";
          }
          {
            name = "dotfiles ❄️";
            path = "~/.dotfiles";
            startup_command = "nvim";
          }
          {
            name = "todo dotfiles ✅";
            path = "~/.dotfiles";
            startup_command = "nvim docs/todo.md";
          }
          {
            name = "kixvim 👨‍💻";
            path = "~/dev/github/kixvim/";
            startup_command = "nvim --cmd ':Telecope find_files'";
          }
          {
            name = "downloads 📂";
            path = "~/Downloads";
            startup_command = "yazi";
          }
        ];
      };
    };

    home.packages = [
      pkgs.unstable.gum
      t-sesh-cmd
    ];

    sops.secrets."sesh-work" = {};

    # Zsh integration for Alt+s keybinding
    programs.zsh.initContent = ''
      function sesh-sessions() {
        {
          exec </dev/tty
          exec <&1
          local session
          session=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ' --preview-window 'right:50%' --preview 'sesh preview {}')
          zle reset-prompt > /dev/null 2>&1 || true
          [[ -z "$session" ]] && return
          sesh connect $session
        }
      }

      zle     -N             sesh-sessions
      bindkey -M emacs '\es' sesh-sessions
      bindkey -M vicmd '\es' sesh-sessions
      bindkey -M viins '\es' sesh-sessions
    '';
  };
}
