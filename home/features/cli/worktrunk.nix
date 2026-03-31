{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.worktrunk;
in {
  options.features.cli.worktrunk.enable = mkEnableOption "worktrunk git worktree management";

  config = mkIf cfg.enable {
    home.packages = [pkgs.unstable.worktrunk];

    programs.zsh.initContent = ''
      eval "$(wt config shell init zsh)"
    '';

    xdg.configFile."worktrunk/config.toml".text = ''
      [post-switch]
      tmux = '[ -n "$TMUX" ] && tmux rename-window {{ branch | sanitize }}'
    '';
  };
}
