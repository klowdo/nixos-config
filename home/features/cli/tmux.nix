{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.tmux;
  tmux-super-fingers =
    pkgs.tmuxPlugins.mkTmuxPlugin
    {
      pluginName = "tmux-super-fingers";
      version = "unstable-2023-01-06";
      src = pkgs.fetchFromGitHub {
        owner = "artemave";
        repo = "tmux_super_fingers";
        rev = "2c12044984124e74e21a5a87d00f844083e4bdf7";
        sha256 = "sha256-cPZCV8xk9QpU49/7H8iGhQYK6JwWjviL29eWabuqruc=";
      };
    };
in {
  options.features.cli.tmux.enable = mkEnableOption "enable tmux tool";

  config = mkIf cfg.enable {
    catppuccin.tmux = {
      enable = true;
      extraConfig = ''
        set -g @catppuccin_flavour 'macchiato' # or latte, frappe, macchiato, mocha
        set -g @catppuccin_window_right_separator ""
        # set -g @catppuccin_window_right_separator "█"
        set -g @catppuccin_window_left_separator ""
        # set -g @catppuccin_window_left_separator ""
        set -g @catppuccin_window_number_position "left"
        set -g @catppuccin_window_middle_separator " "
        set -g @catppuccin_window_default_text "#W"
        set -g @catppuccin_window_default_fill "none"
        set -g @catppuccin_window_current_fill "all"
        set -g @catppuccin_window_current_text "#W"
        set -g @catppuccin_status_modules_right "user host session"
        set -g @catppuccin_status_left_separator  " "
        # set -g @catppuccin_status_left_separator "█"
        set -g @catppuccin_status_right_separator ""
        # set -g @catppuccin_status_right_separator "█"
        set -g @catppuccin_status_right_separator_inverse "no"
        set -g @catppuccin_status_fill "all"
        set -g @catppuccin_status_connect_separator "no"
        set -g @catppuccin_directory_text "#{pane_current_path}"
      '';
    };
    programs.tmux = {
      enable = true;
      shortcut = "a";
      shell = "${pkgs.zsh}/bin/zsh";
      mouse = true;
      # shell = "${pkgs.fish}/bin/fish";
      # aggressiveResize = true; -- Disabled to be iTerm-friendly
      baseIndex = 1;
      newSession = true;
      # Stop tmux+escape craziness.
      escapeTime = 0;
      # Force tmux to use /tmp for sockets (WSL2 compat)
      secureSocket = false;

      plugins = with pkgs; [
        tmuxPlugins.better-mouse-mode
        tmuxPlugins.vim-tmux-navigator
        tmuxPlugins.sensible
        tmux-super-fingers
      ];

      tmuxinator.enable = true;

      extraConfig = ''
        # https://old.reddit.com/r/tmux/comments/mesrci/tmux_2_doesnt_seem_to_use_256_colors/
        set -g default-terminal "xterm-256color"
        set -ga terminal-overrides ",*256col*:Tc"
        set -ga terminal-overrides '*:Ss=\E[%p1%d q:Se=\E[ q'
        set-environment -g COLORTERM "truecolor"

        set-option -g status-position top

        # easy-to-remember split pane commands
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"
        set -g prefix C-a
      '';
    };
    # programs.tmate = {
    #   enable = true;
    #   # FIXME: This causes tmate to hang.
    #   # extraConfig = config.xdg.configFile."tmux/tmux.conf".text;
    # };

    home.packages = [
      # Open tmux for current project.
      (pkgs.writeShellApplication {
        name = "pux";
        runtimeInputs = [pkgs.tmux];
        text = ''
          PRJ="''$(zoxide query -i)"
          echo "Launching tmux for ''$PRJ"
          set -x
          cd "''$PRJ" && \
            exec tmux -S "''$PRJ".tmux attach
        '';
      })
    ];
  };
}
