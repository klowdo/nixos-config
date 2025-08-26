{
  inputs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.features.cli.superclaude;
in {
  options.features.cli.superclaude.enable = mkEnableOption "enablesuperclaude config files";
  imports = [
    inputs.superclaude-nix.homeManagerModules.default
  ];

  config = mkIf cfg.enable {
    programs.superclaude = {
      enable = true;
      installMode = "symlink"; # Deterministic symlinks to Nix store
      installProfile = "default";
      autoInstall = true;
    };
  };
}
