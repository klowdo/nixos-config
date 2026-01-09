{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.autoclaude;
in {
  options.features.desktop.autoclaude.enable =
    mkEnableOption "auto claude desktop application";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      auto-claude-appimage
    ];

    services.ollama = {
      enable = true;
      package = pkgs.ollama-cpu;
    };

    specialisation = {
      nvidia.configuration = {
        services.ollama = {
          package = lib.mkDefault pkgs.ollama-cuda;
          acceleration = lib.mkDefault "cuda";
        };
      };
    };
  };
}
