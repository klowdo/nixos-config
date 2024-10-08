{
  config,
  pkgs,
  lib,
  home-manager,
  ...
}: {
  imports = [./dconf.nix];
  home.packages = with pkgs; [
    gnome.dconf-editor
    # gnome.gnome-terminal
    gnome.gnome-tweaks
    gnomeExtensions.caffeine
    # gnomeExtensions.gsconnect
    gnomeExtensions.just-perfection
    gnomeExtensions.pop-shell
    gnomeExtensions.tray-icons-reloaded
  ];

  home.file.".config/pop-shell/config.json" = {
    enable = true;
    text = ''
      {
        "float": [
          {
            "class": "1Password"
          }
        ],
        "skiptaskbarhidden": [],
        "log_on_focus": false
      }
    '';
  };

  # dconf.settings = { };

  dconf.settings = {
    #   "org/gnome/desktop/input-sources" = {
    #     xkb-options = [ "caps:super" ];
    #   };
    #   "apps/guake/general" = {
    #     abbreviate-tab-names = false;
    #     compat-delete = "delete-sequence";
    #     default-shell = "/home/heywoodlh/.nix-profile/bin/tmux";
    #     display-n = 0;
    #     display-tab-names = 0;
    #     gtk-prefer-dark-theme = true;
    #     gtk-theme-name = "Adwaita-dark";
    #     gtk-use-system-default-theme = true;
    #     hide-tabs-if-one-tab = false;
    #     history-size = 1000;
    #     load-guake-yml = true;
    #     max-tab-name-length = 100;
    #     mouse-display = true;
    #     open-tab-cwd = true;
    #     prompt-on-quit = true;
    #     quick-open-command-line = "code %(file_path)s";
    #     restore-tabs-notify = false;
    #     restore-tabs-startup = false;
    #     save-tabs-when-changed = false;
    #     schema-version = "3.9.0";
    #     scroll-keystroke = true;
    #     start-at-login = true;
    #     use-default-font = false;
    #     use-login-shell = false;
    #     use-popup = false;
    #     use-scrollbar = false;
    #     use-trayicon = false;
    #     window-halignment = 0;
    #     window-height = 50;
    #     window-losefocus = false;
    #     window-refocus = false;
    #     window-tabbar = false;
    #     window-width = 100;
    #   };
    #   "apps/guake/keybindings/local" = {
    #     focus-terminal-left = "<Primary>braceleft";
    #     focus-terminal-right = "<Primary>braceright";
    #     split-tab-horizontal = "<Primary>underscore";
    #     split-tab-vertical = "<Primary>bar";
    #   };
    #   "apps/guake/style" = {
    #     cursor-shape = 1;
    #   };
    #   "apps/guake/style/background" = {
    #     transparency = 100;
    #   };
    #   "apps/guake/style/font" = {
    #     allow-bold = true;
    #     palette = "#3B3B42425252:#BFBF61616A6A:#A3A3BEBE8C8C:#EBEBCBCB8B8B:#8181A1A1C1C1:#B4B48E8EADAD:#8888C0C0D0D0:#E5E5E9E9F0F0:#4C4C56566A6A:#BFBF61616A6A:#A3A3BEBE8C8C:#EBEBCBCB8B8B:#8181A1A1C1C1:#B4B48E8EADAD:#8F8FBCBCBBBB:#ECECEFEFF4F4:#D8D8DEDEE9E9:#2E2E34344040";
    #     palette-name = "Nord";
    #     style = "JetBrainsMono Nerd Font 14";
    #   };
    "org/gnome/shell" = {
      disable-user-extensions = false;
      disabled-extensions = [
        "disabled"
        "ubuntu-dock@ubuntu.com"
        "ding@rastersoft.com"
      ];
      enabled-extensions = [
        "caffeine@patapon.info"
        "gsconnect@andyholmes.github.io"
        "just-perfection-desktop@just-perfection"
        "native-window-placement@gnome-shell-extensions.gcampax.github.com"
        "pop-shell@system76.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
      ];
      favorite-apps = ["firefox.desktop" "alacritty.desktop"];
      had-bluetooth-devices-setup = true;
      remember-mount-password = false;
      # welcome-dialog-last-shown-version = "42.4";
    };
    #   "org/gnome/shell/keybindings" = {
    #     switch-to-application-1 = "disabled";
    #     switch-to-application-2 = "disabled";
    #     switch-to-application-3 = "disabled";
    #     switch-to-application-4 = "disabled";
    #   };
    #   "org/gnome/mutter" = {
    #     dynamic-workspaces = false;
    #   };
    #   "org/gnome/shell/extensions/user-theme" = {
    #     name = "Nordic-darker";
    #   };
    #   "org/gnome/shell/extensions/just-perfection" = {
    #     accessibility-menu = true;
    #     app-menu = true;
    #     app-menu-icon = true;
    #     background-menu = true;
    #     controls-manager-spacing-size = 22;
    #     dash = true;
    #     dash-icon-size = 0;
    #     double-super-to-appgrid = true;
    #     gesture = true;
    #     hot-corner = false;
    #     osd = false;
    #     panel = false;
    #     panel-arrow = true;
    #     panel-corner-size = 1;
    #     panel-in-overview = true;
    #     ripple-box = false;
    #     search = false;
    #     show-apps-button = true;
    #     startup-status = 0;
    #     theme = true;
    #     window-demands-attention-focus = true;
    #     window-picker-icon = false;
    #     window-preview-caption = true;
    #     window-preview-close-button = true;
    #     workspace = true;
    #     workspace-background-corner-size = 15;
    #     workspace-popup = false;
    #     workspaces-in-app-grid = true;
    #   };
    "org/gnome/desktop/interface" = {
      clock-show-seconds = false;
      clock-show-weekday = true;
      color-scheme = "prefer-dark";
      enable-hot-corners = false;
      # font-antialiasing = "grayscale";
      font-hinting = "slight";
      # gtk-theme = "Nordic";
      toolkit-accessibility = true;
    };
    "org/gnome/desktop/wm/keybindings" = {
      #     activate-window-menu = [ "disabled" ];
      #     toggle-message-tray = [ "disabled" ];
      #     close = [ "<Super>q" ];
      maximize = ["<Super>m"];
      minimize = ["disabled"];
      #     # move-to-monitor-down = [ "disabled" ];
      #     # move-to-monitor-left = [ "disabled" ];
      #     # move-to-monitor-right = [ "disabled" ];
      #     move-to-monitor-up = [ "disabled" ];
      #     move-to-workspace-1 = [ "<Shift><Super>1" ];
      #     move-to-workspace-2 = [ "<Shift><Super>2" ];
      #     move-to-workspace-3 = [ "<Shift><Super>3" ];
      #     move-to-workspace-4 = [ "<Shift><Super>4" ];
      #     move-to-workspace-down = [ "disabled" ];
      #     move-to-workspace-up = [ "disabled" ];
      #     # switch-to-workspace-1 = [ "<Super>1" ];
      #     # switch-to-workspace-2 = [ "<Super>2" ];
      #     # switch-to-workspace-3 = [ "<Super>3" ];
      #     # switch-to-workspace-4 = [ "<Super>4" ];
      #     switch-to-workspace-left = [ "<Super>bracketleft" ];
      #     switch-to-workspace-right = [ "<Super>bracketright" ];
      #     # switch-input-source = [ "disabled" ];
      #     # switch-input-source-backward = [ "disabled" ];
      toggle-maximized = ["<Super>Up"];
      unmaximize = ["<Super>m"];
    };
    #   "org/gnome/desktop/wm/preferences" = {
    #     button-layout = "close,minimize,maximize:appmenu";
    #     num-workspaces = 10;
    #   };
    #   "org/gnome/shell/extensions/pop-shell" = {
    #     focus-right = [ "disabled" ];
    #     tile-by-default = true;
    #     tile-enter = [ "disabled" ];
    #   };
    #   "org/gnome/desktop/notifications" = {
    #     show-in-lock-screen = false;
    #   };
    #   "org/gnome/desktop/peripherals/touchpad" = {
    #     tap-to-click = true;
    #     two-finger-scrolling-enabled = true;
    #   };
    #   "org/gnome/terminal/legacy" = {
    #     default-show-menubar = false;
    #     headerbar = "@mb false";
    #   };
    #   "org/gnome/terminal/legacy/profiles:" = {
    #     default = "3797f158-f495-4609-995f-286da69c8d86";
    #     list = [
    #       "3797f158-f495-4609-995f-286da69c8d86"
    #     ];
    #   };
    #   "org/gnome/terminal/legacy/profiles:/:3797f158-f495-4609-995f-286da69c8d86" = {
    #     background-color = "#2E3440";
    #     bold-color = "#D8DEE9";
    #     bold-color-same-as-fg = true;
    #     cursor-background-color = "rgb(216,222,233)";
    #     cursor-colors-set = true;
    #     cursor-foreground-color = "rgb(59,66,82)";
    #     cursor-shape = "ibeam";
    #     custom-command = "/home/heywoodlh/.nix-profile/bin/tmux";
    #     font = "JetBrainsMonoNL Nerd Font 12";
    #     foreground-color = "#D8DEE9";
    #     highlight-background-color = "rgb(136,192,208)";
    #     highlight-colors-set = true;
    #     highlight-foreground-color = "rgb(46,52,64)";
    #     nord-gnome-terminal-version = "0.1.0";
    #     use-custom-command = true;
    #     use-system-font = false;
    #     use-theme-background = false;
    #     use-theme-colors = false;
    #     use-theme-transparency = false;
    #     use-transparent-background = false;
    #     visible-name = "Nord";
    #     scrollbar-policy = "never";
    #     palette = [
    #       "#3B4252"
    #       "#BF616A"
    #       "#A3BE8C"
    #       "#EBCB8B"
    #       "#81A1C1"
    #       "#B48EAD"
    #       "#88C0D0"
    #       "#E5E9F0"
    #       "#4C566A"
    #       "#BF616A"
    #       "#A3BE8C"
    #       "#EBCB8B"
    #       "#81A1C1"
    #       "#B48EAD"
    #       "#8FBCBB"
    #       "#ECEFF4"
    #     ];
    #   };
    #   "org/gnome/tweaks" = {
    #     show-extensions-notice = false;
    #   };
    #   "org/gnome/settings-daemon/plugins/media-keys" = {
    #     next = [ "<Shift><Control>n" ];
    #     previous = [ "<Shift><Control>p" ];
    #     play = [ "<Shift><Control>space" ];
    #     screensaver = [ "<super>esc" ];
    #     terminal = "disabled";
    #     custom-keybindings = [
    #       "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
    #       "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
    #       #"/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
    #       "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
    #       "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4/"
    #       "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5/"
    #       "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6/"
    #       "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7/"
    #       "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8/"
    #     ];
    #   };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
      name = "terminal super";
      command = "alacritty";
      binding = "<Super>t";
    };
    #   "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
    #     name = "terminal ctrl_alt";
    #     command = "alacritty";
    #     binding = "<Ctrl><Alt>t";
    #   };
    #   #"org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
    #   #  name = "rofi-1pass";
    #   #  command = "/home/heywoodlh/bin/rofi-1pass";
    #   #  binding = "<Ctrl><Super>s";
    #   #};
    #   "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
    #     name = "launcher";
    #     command = "rofi -theme nord -show run -display-run 'run: '";
    #     binding = "<Super>Space";
    #   };
    #   "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom4" = {
    #     binding = "<Super><Shift>s";
    #     command = "bash -c 'gnome-screenshot -a -f /tmp/screenshot.png && xclip -in -selection clipboard -target image/png /tmp/screenshot.png'";
    #     name = "screenshot";
    #   };
    #   "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom5" = {
    #     binding = "<Shift><Control>e";
    #     command = "/home/heywoodlh/bin/vim-ime.py --cmd 'gnome-terminal --geometry=60x8 -- vim' --outfile '/home/heywoodlh/tmp/vim-ime.txt'";
    #     name = "vim-ime";
    #   };
    #   "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom6" = {
    #     binding = "<Shift><Control>b";
    #     command = "bash -c 'notify-send $(acpi -b | grep -Eo [0-9]+%)'";
    #     name = "battpop";
    #   };
    #   "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom7" = {
    #     binding = "<Control>grave";
    #     command = "guake";
    #     name = "guake";
    #   };
    #   "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom8" = {
    #     binding = "<Shift><Control>d";
    #     command = "bash -c 'notify-send \"$(date \"+%T\")\"'";
    #     name = "datepop";
    #   };
    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom9" = {
      binding = "<Super>b";
      command = "chrome";
      name = "chrome";
    };

    # "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom10" = {
    #   binding = "<Shift><Control>d";
    #   command = "bash -c 'notify-send \"$(date \"+%T\")\"'";
    #   name = "datepop";
    # };
  };
  # End dconf.settings
}
