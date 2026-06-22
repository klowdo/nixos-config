{
  lib,
  pkgs,
  inputs,
  ...
}: let
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
in {
  imports = [
    inputs.catppuccin.homeModules.catppuccin
  ];

  userConfig = {
    username = "klowdo";
    fullName = "Felix Svensson";
    email = "klowdo.fs@gmail.com";
  };

  catppuccin.flavor = "macchiato";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    vim
    coreutils
    fd
    htop
    jq
    ripgrep
    unzip
    pciutils

    # YubiKey & key management
    yubikey-agent
    yubico-pam
    yubikey-manager
    pcsclite
  ];

  home.sessionVariables = {
    EDITOR = "vim";
    NIX_PATH = lib.concatStringsSep ":" (lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs);
  };

  programs = {
    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };
    bash.enable = true;
    btop.enable = true;
  };

  systemd.user.startServices = "sd-switch";
  programs.home-manager.enable = true;
}
