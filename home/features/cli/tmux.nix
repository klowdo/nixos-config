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
      shortcut = "b";
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
      keyMode = "vi";

      plugins = with pkgs; [
        tmuxPlugins.better-mouse-mode
        tmuxPlugins.vim-tmux-navigator
        tmuxPlugins.sensible
        tmux-super-fingers
        tmuxPlugins.resurrect
      ];

      tmuxinator.enable = true;

      extraConfig = ''
        # https://old.reddit.com/r/tmux/comments/mesrci/tmux_2_doesnt_seem_to_use_256_colors/
        set-option -g default-terminal "tmux-256color"
        set-option -ga terminal-overrides ",xterm-256color:Tc"
        set-environment -g COLORTERM "truecolor"

        # Enable Ctrl+Arrow and other extended key sequences for applications
        set-window-option -g xterm-keys on
        set -s extended-keys on
        set -as terminal-features 'xterm*:extkeys'

        set-option -g status-position top

        set -g detach-on-destroy off
        set -g focus-events on

        ## SESH
        bind-key "K" display-popup -E -w 40% "sesh connect \"$(
          sesh list -i | gum filter --limit 1 --placeholder 'Pick a sesh' --prompt='⚡'
        )\""

        bind-key "J" run-shell "sesh connect \"$(
          sesh list -i | fzf-tmux -p 55%,60% \
            --no-sort --border-label ' sesh ' --prompt '⚡  ' \
            --header '  ^a all ^t tmux ^x zoxide ^g config ^d tmux kill ^f find' \
            --bind 'tab:down,btab:up' \
            --bind 'ctrl-a:change-prompt(⚡  )+reload(sesh list -i)' \
            --bind 'ctrl-t:change-prompt(🪟  )+reload(sesh list -it)' \
            --bind 'ctrl-g:change-prompt(⚙️  )+reload(sesh list -ic)' \
            --bind 'ctrl-x:change-prompt(📁  )+reload(sesh list -iz)' \
            --bind 'ctrl-f:change-prompt(🔎  )+reload(fd -H -d 2 -t d -E .Trash . ~)' \
            --bind 'ctrl-d:execute(tmux kill-session -t {})+change-prompt(⚡  )+reload(sesh list)'
        )\""

        bind -N "last-session (via sesh) " L run-shell "sesh last"
        bind -N "switch to root session (via sesh) " 9 run-shell "sesh connect --root \'$(pwd)\'"
        bind-key "R" display-popup -E -w 40% "sesh connect \"$(
          sesh list -i -H | gum filter --valuf \"$(sesh root)\" --limit 1 --fuzzy --no-sort --placeholder 'Pick a sesh' --prompt='⚡'readme
        )\""
        ## SESH

        bind-key x kill-pane

        # for image.nvim
        set -g allow-passthrough on
        set -g visual-activity off

        set -g @scroll-without-changing-pane "on"
        set -g @emulate-scroll-for-no-mouse-alternate-buffer "on"

        bind -T copy-mode-vi v send -X begin-selection
        bind -T copy-mode-vi y send-keys -X copy-pipe-and-cancel
        bind P paste-buffer
        bind -T copy-mode-vi MouseDragEnd1Pane send-keys -X copy-pipe-and-cancel

        # easy-to-remember split pane commands
        bind | split-window -h -c "#{pane_current_path}"
        bind - split-window -v -c "#{pane_current_path}"
        bind c new-window -c "#{pane_current_path}"

        vim_pattern='(\S+/)?g?\.?(view|l?n?vim?x?|fzf|lazygit)(diff)?(-wrapped)?'
        is_vim="${pkgs.ps}/bin/ps -o state= -o comm= -t '#{pane_tty}' \
            | grep -iqE '^[^TXZ ]+ +''${vim_pattern}$'"
        is_lg="${pkgs.ps}/bin/ps -o state= -o comm= -t '#{pane_tty}' | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?lazygit$'"
        bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
        bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
        bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
        bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
        tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
        if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
            "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
        if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
            "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

        bind-key -T copy-mode-vi 'C-h' select-pane -L
        bind-key -T copy-mode-vi 'C-j' select-pane -D
        bind-key -T copy-mode-vi 'C-k' select-pane -U
        bind-key -T copy-mode-vi 'C-l' select-pane -R
        bind-key -T copy-mode-vi 'C-\' select-pane -l
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
