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
      post-switch.lazygit = ''[ -n "$TMUX" ] && tmux new-window -d -n git lazygit'';
    };

    programs.tmux.extraConfig = lib.mkAfter ''
      ## WORKTRUNK
      bind-key "M" display-popup -E -w 80% -h 60% -d "#{pane_current_path}" "\
        MR=\$(glab mr list --per-page 50 \
          | fzf --ansi --prompt 'MR> ' --no-sort \
            --preview 'glab mr view \$(echo {1} | tr -d \"!\")' \
            --preview-window 'right:50%:wrap' \
          | awk '{print \$1}' | tr -d '!') \
        && [ -n \"\$MR\" ] \
        && BRANCH=\$(glab mr view \"\$MR\" --output json | jq -r '.source_branch') \
        && wt switch \"\$BRANCH\" --no-cd \
        && sesh connect \"\$(git worktree list | grep -F \"[\$BRANCH]\" | awk '{print \$1}')\""

      bind-key "B" display-popup -E -w 80% -h 60% -d "#{pane_current_path}" "\
        BRANCH=\$(wt list --branches --remotes \
          | fzf --ansi --prompt 'Branch> ' --no-sort \
          | awk '{print \$1}') \
        && [ -n \"\$BRANCH\" ] \
        && wt switch \"\$BRANCH\" --no-cd \
        && sesh connect \"\$(git worktree list | grep -F \"[\$BRANCH]\" | awk '{print \$1}')\""
      ## WORKTRUNK
    '';
  };
}
