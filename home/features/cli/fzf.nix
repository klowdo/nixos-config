{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.cli.fzf;
in {
  options.features.cli.fzf.enable = mkEnableOption "enable fuzzy finder";

  config = mkIf cfg.enable {
    programs.fzf = {
      enable = true;
      enableZshIntegration = true;
      tmux.enableShellIntegration = true;

      defaultOptions = [
        "--bind 'ctrl-/:toggle-preview'"
      ];
      defaultCommand = "fd --type f --exclude .git --follow --hidden";
      fileWidgetOptions = [
        "--preview='bat --color=always -n {}'"
      ];
      changeDirWidgetCommand = "fd --type d --exclude .git --follow --hidden";
      changeDirWidgetOptions = [
        "--preview='eza --tree --color=always {} | head -200'"
      ];
    };
  };
}
