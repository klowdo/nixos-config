{
  config,
  lib,
  ...
}:
with lib; let
  cfg = config.features.cli.yazi;
  # yazi-plugins = pkgs.fetchFromGitHub {
  #   owner = "yazi-rs";
  #   repo = "plugins";
  #   rev = "";
  #   hash = "";
  # };
in {
  options.features.cli.yazi.enable = mkEnableOption "enable yazi file manger";

  config = mkIf cfg.enable {
    programs.yazi = {
      enable = true;

      enableBashIntegration = true; # see note on other shells below
      enableZshIntegration = true;
      # plugins = {
      #   chmod = "${yazi-plugins}/chmod.yazi";
      #   full-border = "${yazi-plugins}/full-border.yazi";
      #   max-preview = "${yazi-plugins}/max-preview.yazi";
      #   git = "${yazi-plugins}/git.yazi";
      # };
      # initLua = ''
      #   require("full-border"):setup()
      #   require("git"):setup()
      # '';
      # keymap = {
      #   manager.prepend_keymap = [
      #     {
      #       on = "T";
      #       run = "plugin --sync max-preview";
      #       desc = "Maximize or restore the preview pane";
      #     }
      #     {
      #       on = ["c" "m"];
      #       run = "plugin chmod";
      #       desc = "Chmod on selected files";
      #     }
      #   ];
      # };
    };
  };
}
