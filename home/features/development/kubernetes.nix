{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.development.kubernetes;
  inherit (config.home) homeDirectory;
in {
  options.features.development.kubernetes = {
    enable = mkEnableOption "Kubernetes development tools";

    kubeconfigSecret = mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "SOPS secret key for kubeconfig";
    };
  };

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      kubectl
      k9s
      lens
    ];

    sops.secrets = mkIf (cfg.kubeconfigSecret != null) {
      ${cfg.kubeconfigSecret} = {
        path = "${homeDirectory}/.kube/config";
        mode = "0600";
      };
    };
  };
}
