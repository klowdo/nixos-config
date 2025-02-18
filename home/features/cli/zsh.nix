{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.zsh;
in {
  options.features.cli.zsh.enable = mkEnableOption "enable extended zsh configuration";

  config = mkIf cfg.enable {
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting.enable = true;
      shellAliases = {
        ll = "ls -l";
        update = "sudo nixos-rebuild switch";
        ls = "eza";
        grep = "rg";
        ps = "procs";
        lg = "lazygit";
        ndev = "nix run ~/dev/github/kixvim";
        e = "nvim";
        edit = "nvim";
        dive = "docker run -ti --rm  -v /run/user/1000/podman/podman.sock:/var/run/docker.sock wagoodman/dive";
      };
      history = {
        size = 10000;
        path = "${config.xdg.dataHome}/zsh/history";
      };

      plugins = [
        {
          name = "vi-mode";
          src = pkgs.zsh-vi-mode;
          file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
        }
      ];

      initExtra = ''
        function sesh-sessions() {
          {
            exec </dev/tty
            exec <&1
            local session
            session=$(sesh list -t -c | fzf --height 40% --reverse --border-label ' sesh ' --border --prompt '⚡  ')
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

      loginExtra = ''
          export NIX_LOG=info
          export TERMINAL=kitty

        if [[ $(tty) == "/dev/tty1" ]]; then
            exec Hyprland &> /dev/null
        fi
      '';

      oh-my-zsh = {
        enable = true;
        theme = "robbyrussell";
        plugins = ["git" "sudo" "dotnet"];
      };
    };
  };
}
