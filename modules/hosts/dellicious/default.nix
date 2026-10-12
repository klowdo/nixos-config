{
  inputs,
  config,
  withSystem,
  ...
}: let
  inherit (config) flake;
in {
  flake.modules.nixos.host-dellicious = {pkgs, ...}: {
    imports =
      [
        ./_hardware-configuration.nix
        inputs.disko.nixosModules.disko
        ./_disko.nix
        inputs.hardware.nixosModules.dell-xps-15-9530
        (import ./_hardware/dual-gpu.nix inputs)
        ./_hardware/default-disable-nvidia.nix
        ./_hardware/keychron.nix
        ./_hardware/fingerprint.nix
        ./_sops.nix
        ./_wifi.nix
      ]
      ++ (with flake.modules.nixos; [
        appimagetools
        gnome-keyring
        tpm
        thunderbolt
        resolved
        zsh
        audio
        printing
        keyboard
        kanata
        ld
        networking
        wifi-networks
        thunar
        openssh
        graphics
        hyprland
        plymouth
        bluetooth
        avahi
        tailscale-exit-node
        udev
        icu
        dotnet-dev-certs
        nix-access-tokens
        custom-ca-certs
        steam
        flatpak
        swaylock
        power-profiles-daemon
        powertop
        auto-upgrade
        systemd-notify
        thyx
        stylix
        logitech
        onepassword
        localsend
        docker
        virtualization
        wireguard-unifi
      ]);

    networking.hostName = "dellicious";

    powerManagement.enable = true;

    extraServices = {
      docker.usePasta = true;
      wireguard-unifi = {
        address = ["192.168.4.2/32"];
        dns = ["192.168.4.1"];
        peerPublicKey = "tvGo3Dl/21tBpQb3WT2qoeR+9aRxn/Ox0HXWAMHPCRM=";
      };
    };

    home-manager.users.klowdo = flake.modules.homeManager.host-dellicious;

    boot = {
      kernelPackages = pkgs.unstable.linuxPackages_latest;
      kernelModules = ["kvm-intel"];
      # aes_generic is built-in on linux 7.0+, remove from initrd module list
      # https://github.com/NixOS/nixpkgs/issues/511100
      initrd.luks.cryptoModules = [
        "aes"
        "blowfish"
        "twofish"
        "serpent"
        "cbc"
        "xts"
        "lrw"
        "sha1"
        "sha256"
        "sha512"
        "af_alg"
        "algif_skcipher"
        "cryptd"
        "input_leds"
      ];
      loader.systemd-boot.enable = true;
      loader.efi.canTouchEfiVariables = true;
      kernelParams = ["i915.force_probe=a7a0"];
    };
  };

  flake.modules.homeManager.host-dellicious = {
    config,
    pkgs,
    ...
  }: {
    imports =
      [(import ./_monitors.nix inputs)]
      ++ (with flake.modules.homeManager; [
        base
        sops
        vial
        klowdo
        klowdo-dotfiles
        cli
        lazygit
        nix
        docker
        development
        claudia
        kitty
        zsh
        fastfetch
        fzf
        yazi
        taskwarrior
        tmux
        sesh
        gh
        claude-code
        ssh
        git-repo-manager
        archives
        circumflex
        cool-retro-term
        worktrunk
        glab
        tools
        auto-shell
        claude-desktop
        wakapi
        rider
        junie
        dotnet
        rust
        mcp-gateway
        bambu-studio
        nix-flatpak
        freecad
        kubernetes
        firefox
        spicetify
        spotify-player
        zathura
        pinta
        brave
        vesktop
        slack
        zsa-moonlander
        bluetooth
        heroic
        steam-link
        syncthing
        wayland
        hyprland
        hypridle
        hyprland-binds
        animations
        hyprland-xdg-portal
        hyprlock
        hyprlock-music-script
        notes-overlay
        terminal-overlay
        wofi
        polkit
        wlogout
        fonts
        tailscale-systray
        calculator
        nautilus
        darkman
        which-key
        munder-difflin
        wayscriber
        vicinae
        caelestia
        monitor-webhook
        defaults
        icons
        notification
        stylix
      ]);

    features = {
      cli = {
        claude-code.enableNotifications = false;
        auto-shell = {
          availableShells = builtins.attrNames (import ../../../devshells {inherit pkgs inputs;});
          shells.zig.paths = ["~/dev/github/libsrapli"];
          includes = ["~/dev/github/autoshell.toml"];
        };
      };
      desktop = {
        vicinae.enableHyprlandSupport = true;
        bar.caelestia.useSessionMenu = true;
      };
      development = {
        tools.junie.apiKeySecret = "applications/jetbrains-junie/token";
        kubernetes.kubeconfigSecret = "kubernetes/kubeconfig";
      };
      defaults = {
        launcher = {
          command = "vicinae toggle";
          inherit (config.programs.vicinae) package;
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
    };

    wayland.windowManager.hyprland.settings = {
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

  flake.nixosConfigurations.dellicious = inputs.nixpkgs.lib.nixosSystem {
    modules = with flake.modules.nixos; [base user-klowdo host-dellicious];
  };

  flake.homeConfigurations."klowdo@dellicious" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = withSystem "x86_64-linux" ({pkgs, ...}: pkgs);
    modules = [inputs.stylix.homeModules.stylix flake.modules.homeManager.host-dellicious];
  };
}
