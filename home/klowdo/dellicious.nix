{
  pkgs,
  config,
  ...
}: {
  imports = [
    ./home.nix
    ./dotfiles
    ./dellicious-monitors.nix
    ../features
    ../common
    ../common/optional/sops.nix
    ../common/optional/vial.nix
  ];

  features = {
    cli = {
      kitty.enable = true;
      zsh.enable = true;
      fastfetch.enable = true;
      fzf.enable = true;
      yazi.enable = true;
      password-store.enable = false;
      taskwarrior.enable = true;
      tmux.enable = true;
      sesh.enable = true;
      gh.enable = true;
      claude-code.enable = true;
      bitwarden-wofi.enable = false;
      ssh.enable = true;
      git-repo-manager.enable = true;
      zellij.enable = true;
      archives.enable = true;
      circumflex.enable = true;
      cool-retro-term.enable = true;
    };
    desktop = {
      wayland.enable = true;
      hyprland.enable = true;
      fonts.enable = true;
      tailscale-systray.enable = true;
      clipboard.enable = false;
      calculator.enable = true;
      todo.enable = true;
      nautilus.enable = true;
      darkman.enable = true;
      bitwarden.enable = true;
      which-key.enable = true;
      kando.enable = true;
      vicinae = {
        enable = true;
        enableHyprlandSupport = true;
      };
      bar = {
        # hyprpanel.enable = true;
        # ashell.enable = true;
        caelestia = {
          enable = true;
          useSessionMenu = true;
        };
      };
      # loginManager.enable = true;
      autoclaude.enable = false;
      monitor-webhook.enable = true;
      go-hass-agent.enable = true;
    };

    defaults = {
      enable = true;
      launcher = {
        command = "vicinae toggle";
        inherit (config.programs.vicinae) package;
        # "${pkgs.killall}/bin/killall wofi || wofi --show drun --allow-images"
        dmenuMode = "vicinae dmenu";
      };
      browser = {
        command = "firefox";
        package = config.programs.firefox.finalPackage;
      };
      terminal = {
        command = "kitty";
        package = pkgs.kitty;
      };
    };
    development = {
      wakapi.enable = true;
      tools = {
        rider.enable = false;
        goland.enable = true;
        libreoffice.enable = false;
      };
      languages = {
        dotnet.enable = true;
      };
      mcp-gateway.enable = true;
      cura.enable = false;
      orca.enable = true;
      super-slicer.enable = true;
      bambu-studio.enable = true;
      nix-flatpak.enable = true;
      freecad.enable = true;
      mongo-compass.enable = false;
    };
    media = {
      firefox.enable = true;
      spicetify.enable = true;
      spotify-player.enable = true;
      zathura.enable = true;
      deezer.enable = true;
      music-assistant = {
        enable = true;
        url = "https://music.home.flixen.se";
      };
      pinta.enable = true;
      brave.enable = true;
    };
    communication = {
      zoom.enable = false;
      vesktop.enable = true;
      neomutt.enable = false;
      slack.enable = true;
    };
    hardware = {
      zsa-moonlander.enable = true;
      bluetooth.enable = true;
    };
    gaming = {
      heroic.enable = true;
      steam-link.enable = true;
    };
    sync = {
      syncthing.enable = true;
    };
  };

  wayland.windowManager.hyprland = {
    settings = {
      input = {
        touchpad = {
          scroll_factor = 0.2;
          disable_while_typing = true;
        };
        kb_layout = "us,se";
        kb_options = "grp:win_space_toggle,ctrl:nocaps";
        follow_mouse = 1;
        float_switch_override_focus = 0;

        sensitivity = 0;
      };

      device = [
        {
          name = "beekeeb-piantor-keyboard";
          kb_layout = "us,se";
        }
        {
          name = "zsa-technology-labs-moonlander-mark-i-keyboard";
          kb_layout = "us,se";
        }
        {
          name = "zsa-technology-labs-moonlander-mark-i";
          kb_layout = "us,se";
        }
        {
          name = "mouse";
          sensitivity = -0.5;
        }
      ];
    };
  };
}
