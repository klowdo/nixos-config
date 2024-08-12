# This is your home-manager configuration file
# Use this to configure your home environment (it replaces ~/.config/nixpkgs/home.nix)
{
  inputs,
  outputs,
  lib,
  config,
  pkgs,
  ...
}: {
  # You can import other home-manager modules here
  imports = [
    # If you want to use modules your own flake exports (from modules/home-manager):
    # outputs.homeManagerModules.example

    # Or modules exported from other flakes (such as nix-colors):
    # inputs.nix-colors.homeManagerModules.default

    # You can also split up your configuration and import pieces of it here:
    ./nvim/default.nix
    ./kitty.nix
    ./fonts.nix
    ./direnv.nix
    ./zoxide.nix
    ./bat.nix
    ./zsh/default.nix
    ./desktops
    ./wlogout/default.nix
  ];

  nixpkgs = {
    # You can add overlays here
    overlays = [
      # Add overlays your own flake exports (from overlays and pkgs dir):
      outputs.overlays.additions
      outputs.overlays.modifications
      outputs.overlays.unstable-packages

      # You can also add overlays exported from other flakes:
      # neovim-nightly-overlay.overlays.default

      # Or define it inline, for example:
      # (final: prev: {
      #   hi = final.hello.overrideAttrs (oldAttrs: {
      #     patches = [ ./change-hello-to-hi.patch ];
      #   });
      # })
    ];
    # Configure your nixpkgs instance
    config = {
      # Disable if you don't want unfree packages
      allowUnfree = true;
      # Workaround for https://github.com/nix-community/home-manager/issues/2942
      allowUnfreePredicate = _: true;
    };
  };

  home = {
    username = "klowdo";
    homeDirectory = "/home/klowdo";
    sessionVariables = {
      SHELL = "zsh";
    };

    shellAliases = {
      swich-home = "home-manager switch --flake .#klowdo@dellicious";
      switch-config = "sudo nixos-rebuild switch --flake .#dellicious";
    };
  };

  # {
  #   wayland.windowManager.hyprland.settings = {
  #     "$mod" = "SUPER";
  #     bind =
  #       [
  #         "$mod, F, exec, firefox"
  #         ", Print, exec, grimblast copy area"
  #       ]
  #       ++ (
  #         # workspaces
  #         # binds $mod + [shift +] {1..10} to [move to] workspace {1..10}
  #         builtins.concatLists (builtins.genList (
  #             x: let
  #               ws = let
  #                 c = (x + 1) / 10;
  #               in
  #                 builtins.toString (x + 1 - (c * 10));
  #             in [
  #               "$mod, ${ws}, workspace, ${toString (x + 1)}"
  #               "$mod SHIFT, ${ws}, movetoworkspace, ${toString (x + 1)}"
  #             ]
  #           )
  #           10)
  #       );
  #   };
  # }
  #
  # Add stuff for your user as you see fit:
  # programs.neovim.enable = true;
  home.packages = with pkgs; [
    dotnet-sdk_8
    jetbrains.rider
    google-chrome
    alacritty
    spotify
    lazygit
    ranger
    rustc
    cargo
    #  rustup
    #
    #   # Packages that don't have custom configs go here

    # TODO: spaces before comment are removed by nixpkgs-fmt
    # See: https://github.com/nix-community/nixpkgs-fmt/issues/305
    # borgbackup # backups
    btop # resource monitor
    coreutils # basic gnu utils
    # curl
    eza # ls replacement
    fd # tree style ls
    findutils # find
    fzf # fuzzy search
    jq # JSON pretty printer and manipulator
    nix-tree # nix package tree viewer
    ncdu # TUI disk usage
    pciutils
    pfetch # system info
    pre-commit # git hooks
    p7zip # compression & encryption
    ripgrep # better grep
    usbutils
    tree # cli dir tree viewer
    unzip # zip extraction
    unrar # rar extraction
    wget # downloader
    zip # zip compressio
    unzip
    slack
    nodejs_22
    (pkgs.python3.withPackages (python-pkgs: [
      # select Python packages here
      python-pkgs.pandas
      python-pkgs.requests
      (pkgs.callPackage ./toolz.nix)
    ]))
  ];
  programs.kitty.enable = true;
  # Enable home-manager and git
  programs.home-manager.enable = true;
  programs.git = {
    enable = true;
    userName = "Felix Svensson";
    userEmail = "klowdo.fs@gmail.com";
    aliases = {
      ci = "commit";
      co = "checkout";
      st = "status";
    };
  };

  # Nicely reload system units when changing configs
  systemd.user.startServices = "sd-switch";

  # https://nixos.wgit branch -M mainiki/wiki/FAQ/When_do_I_update_stateVersion
  home.stateVersion = "24.05";
}
