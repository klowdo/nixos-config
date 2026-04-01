{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.worktrunk;
  toml = pkgs.formats.toml {};
in {
  options.features.cli.worktrunk.enable = mkEnableOption "worktrunk git worktree management";

  config = mkIf cfg.enable {
    home.packages = [pkgs.unstable.worktrunk];

    programs.zsh.initContent = ''
      eval "$(wt config shell init zsh)"
    '';

    xdg.configFile."worktrunk/config.toml".source = toml.generate "config.toml" {
      worktree-path = ".worktrees/{{ branch | sanitize }}";
      commit.generation.command = "CLAUDECODE= MAX_THINKING_TOKENS=0 claude -p --no-session-persistence --model=haiku --tools='' --disable-slash-commands --setting-sources='' --system-prompt=''";

      post-switch.tmux = ''[ -n "$TMUX" ] && tmux rename-window {{ branch | sanitize }}'';
    };
  };
}
