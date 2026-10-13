{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.cli.herdr;
in {
  options.features.cli.herdr.enable = mkEnableOption "enable herdr agent multiplexer";

  config = mkIf cfg.enable {
    home.packages = [pkgs.unstable.herdr];

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
