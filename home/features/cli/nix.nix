{
  pkgs,
  inputs,
  lib,
  ...
}: let
  flakeInputs = lib.filterAttrs (_: lib.isType "flake") inputs;
in {
  imports = [
    inputs.nix-index-database.homeModules.nix-index
  ];
  home.sessionVariables.NIX_PATH = lib.concatStringsSep ":" (lib.mapAttrsToList (n: _: "${n}=flake:${n}") flakeInputs);

  programs.direnv = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
  };

  home.packages = with pkgs;
    [
      nixfmt-rfc-style
      nixpkgs-fmt
      nixd
      deadnix
      statix
      nurl
      nix-search-cli
      nix-search-tv
    ]
    ++ (with inputs.nsearch.packages.${pkgs.stdenv.hostPlatform.system}; [nsearch nrun nshell]);
  programs.nix-index = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.nix-index-database.comma.enable = true;
  # programs.nix-your-shell.enable = true;
}
