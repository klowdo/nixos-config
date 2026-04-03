{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.sesh;

  t-sesh-cmd = pkgs.writeShellScriptBin "t" ''
    sesh picker
  '';
in {
  options.features.cli.sesh.enable = mkEnableOption "enable sesh session manager";

  config = mkIf cfg.enable {
    home.packages = [
      t-sesh-cmd
    ];

    sops.secrets."sesh-work" = {};
    programs = {
      sesh = {
        enable = true;
        package = pkgs.sesh;
        enableAlias = true;
        enableTmuxIntegration = true;
        tmuxKey = "s";
        icons = true;

        settings = {
          cache = true;

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
            {
              name = "worktrees 🌲";
              path = "~/dev/github";
              startup_command = "sesh connect $(find . -maxdepth 2 -name .git -type d -exec dirname {} \\; | fzf --prompt='Pick a repo: ') && exit";
            }
          ];

          window = [
            {
              name = "git";
              startup_command = "lazygit";
            }
          ];
        };
      };

      tmux.extraConfig = lib.mkAfter ''
        ## SESH
        bind-key "R" display-popup -E -w 80% -h 80% "sesh connect \"\$(
          sesh list --icons --hide-duplicates | fzf --ansi \
            --no-sort --prompt '  ' \
            --header 'ctrl-a:all ctrl-t:tmux ctrl-g:config ctrl-x:zoxide ctrl-f:find ctrl-d:kill' \
            --bind 'tab:down,btab:up' \
            --bind 'ctrl-b:abort' \
            --bind 'ctrl-a:change-prompt(  )+reload(sesh list --icons)' \
            --bind 'ctrl-t:change-prompt(  )+reload(sesh list -t --icons)' \
            --bind 'ctrl-g:change-prompt(  )+reload(sesh list -c --icons)' \
            --bind 'ctrl-x:change-prompt(  )+reload(sesh list -z --icons)' \
            --bind 'ctrl-f:change-prompt(  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
            --bind 'ctrl-d:execute(tmux kill-session -t {2..})+change-prompt(  )+reload(sesh list --icons)' \
            --preview-window 'right:55%' \
            --preview 'sesh preview {}' \
        )\""
        bind -N "last-session (via sesh) " L run-shell "sesh last"
        bind -N "switch to root session (via sesh) " 9 run-shell "sesh connect --root \'$(pwd)\'"
        bind-key "K" display-popup -E -w 40% -h 60% "sesh picker"
        ## SESH
      '';

      zsh.initContent = ''
        function sesh-sessions() {
          {
            exec </dev/tty
            exec <&1
            sesh picker
            zle reset-prompt > /dev/null 2>&1 || true
          }
        }

        zle     -N             sesh-sessions
        bindkey -M emacs '\es' sesh-sessions
        bindkey -M vicmd '\es' sesh-sessions
        bindkey -M viins '\es' sesh-sessions
      '';
    };
  };
}
