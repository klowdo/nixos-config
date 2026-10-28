{
  config,
  pkgs,
  lib,
  ...
}:
with lib; let
  cfg = config.features.development.copilot-cli;
in {
  options.features.development.copilot-cli.enable = mkEnableOption "enable GitHub Copilot CLI";

  config = mkIf cfg.enable {
    home.packages = [
      (pkgs.symlinkJoin {
        name = "github-copilot-cli";
        paths = [pkgs.unstable.github-copilot-cli];
        nativeBuildInputs = [pkgs.makeWrapper];
        postBuild = "wrapProgram $out/bin/copilot --suffix PATH : ${pkgs.python3}/bin";
      })
    ];
  };
}
