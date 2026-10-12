{config, ...}: let
  inherit (config) flake;
in {
  flake.modules.homeManager.base = {
    lib,
    pkgs,
    ...
  }: {
    imports = with flake.modules.homeManager; [
      option-user-config
      option-way-displays
      option-claudia
      option-junie
      option-vcstool
      option-vicinae
      option-hyprmoncfg
      option-git-repo-manager
    ];

    nixpkgs = {
      overlays = builtins.attrValues flake.overlays;
      config = {
        allowUnfree = true;
        # Workaround for https://github.com/nix-community/home-manager/issues/2942
        allowUnfreePredicate = _: true;
      };
    };

    nix = {
      package = lib.mkDefault pkgs.nix;
      settings = {
        experimental-features = ["nix-command" "flakes"];
        warn-dirty = false;
      };
    };
  };
}
