{
  inputs,
  config,
  withSystem,
  ...
}: let
  inherit (config) flake;
in {
  flake.modules.nixos.host-virt-nix = {
    imports =
      [
        ./_hardware-configuration.nix
        inputs.disko.nixosModules.disko
        ./_disko.nix
        ./_configuration.nix
        ./_services
      ]
      ++ (with flake.modules.nixos; [
        appimagetools
        gnome-keyring
        podman
        stylix
      ]);

    home-manager.users.klowdo = flake.modules.homeManager.host-virt-nix;
  };

  flake.modules.homeManager.host-virt-nix = {
    imports = with flake.modules.homeManager; [
      base
      sops
      klowdo
      klowdo-dotfiles
      cli
      lazygit
      nix
      docker
      development
      claudia
      zsh
      fastfetch
      fzf
      wayland
      hyprland
      fonts
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
      icons
      notification
      stylix
    ];

    wayland.windowManager.hyprland.settings = {
      device = [
        {
          name = "keyboard";
          kb_layout = "us";
        }
        {
          name = "mouse";
          sensitivity = -0.5;
        }
      ];
      monitor = [
        "DP-1,1920x1080@60,0x0,1"
      ];
      workspace = [
        "1, monitor:DP-1, default:true"
        "2, monitor:DP-1"
        "3, monitor:DP-1"
        "4, monitor:DP-2"
        "5, monitor:DP-1"
        "6, monitor:DP-2"
        "7, monitor:DP-2"
      ];
    };
  };

  flake.nixosConfigurations.virt-nix = inputs.nixpkgs.lib.nixosSystem {
    modules = with flake.modules.nixos; [base user-klowdo host-virt-nix];
  };

  flake.homeConfigurations."klowdo@virt-nix" = inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = withSystem "x86_64-linux" ({pkgs, ...}: pkgs);
    modules = [inputs.stylix.homeModules.stylix flake.modules.homeManager.host-virt-nix];
  };
}
