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
    programs.sesh = {
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
        ];
      };
    };

    home.packages = [
      t-sesh-cmd
    ];

    sops.secrets."sesh-work" = {};

    programs.zsh.initContent = ''
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
}
