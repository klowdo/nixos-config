{...}: {
  flake.modules.homeManager.fzf = {
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
