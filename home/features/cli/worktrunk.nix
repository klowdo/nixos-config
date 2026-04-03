{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.worktrunk;
  toml = pkgs.formats.toml {};

  wtm = pkgs.writeShellScriptBin "wtm" ''
    MR=$(glab mr list --per-page 50 \
      | ${lib.getExe pkgs.fzf} --ansi --prompt 'MR> ' --no-sort \
        --preview 'glab mr view $(echo {1} | tr -d "!")' \
        --preview-window 'right:50%:wrap' \
      | awk '{print $1}' | tr -d '!') \
      && [ -n "$MR" ] \
      && BRANCH=$(glab mr view "$MR" --output json | ${lib.getExe pkgs.jq} -r '.source_branch') \
      && wt switch "$BRANCH"
  '';

  wtb = pkgs.writeShellScriptBin "wtb" ''
    BRANCH=$(wt list --format=json --branches --remotes \
      | ${lib.getExe pkgs.jq} -r '.[].branch // empty' \
      | sort -u \
      | ${lib.getExe pkgs.fzf} --prompt 'Branch> ') \
      && [ -n "$BRANCH" ] \
      && wt switch "$BRANCH"
  '';
in {
  options.features.cli.worktrunk.enable = mkEnableOption "worktrunk git worktree management";

  config = mkIf cfg.enable {
    home.packages = [pkgs.unstable.worktrunk wtm wtb];

    programs.zsh.initContent = ''
      eval "$(wt config shell init zsh)"
    '';

    xdg.configFile."worktrunk/config.toml".source = toml.generate "config.toml" {
      worktree-path = ".worktrees/{{ branch | sanitize }}";
      commit.generation.command = "CLAUDECODE= MAX_THINKING_TOKENS=0 claude -p --no-session-persistence --model=haiku --tools='' --disable-slash-commands --setting-sources='' --system-prompt=''";

      switch.no-cd = true;
      post-switch = {
        tmux = ''[ -n "$TMUX" ] && tmux rename-window {{ branch | sanitize }}'';
        lazygit = ''[ -n "$TMUX" ] && tmux new-window -d -n git lazygit'';
        sesh = ''[ -n "$TMUX" ] && sesh connect {{ worktree_path }}'';
      };
    };

    programs.tmux.extraConfig = lib.mkAfter ''
      ## WORKTRUNK
      bind-key "M" display-popup -E -w 80% -h 60% -d "#{pane_current_path}" "wtm"
      bind-key "B" display-popup -E -w 80% -h 60% -d "#{pane_current_path}" "wtb"
      ## WORKTRUNK
    '';
  };
}
