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
      unstable.herdr
    ];

    xdg.configFile."herdr/config.toml".source = (pkgs.formats.toml {}).generate "herdr-config.toml" {
      onboarding = false;
      keys = {
        previous_agent = "prefix+(";
        next_agent = "prefix+)";
        focus_agent = "ctrl+1..9";
        switch_workspace = "prefix+shift+1..9";
      };
    };
  };
}
