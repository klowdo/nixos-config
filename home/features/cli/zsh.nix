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

      loginExtra = ''
          set -x NIX_PATH nixpkgs=channel:nixos-stable
          set -x NIX_LOG info
          set -x TERMINAL kitty

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
