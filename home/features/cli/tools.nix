{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.tools;
in {
  options.features.cli.tools.enable = mkEnableOption "handy CLI utilities";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      coreutils
      fd
      htop
      httpie
      jq
      procs
      ripgrep
      tldr
      zip
      unp
      wishlist
      unstable.witr
      unstable.isd
    ];
  };
}
