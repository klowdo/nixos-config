{config, ...}: let
  inherit (config) flake;
in {
  flake.modules.homeManager.kubernetes = {
    config,
    lib,
    pkgs,
    ...
  }:
    with lib; let
      cfg = config.features.development.kubernetes;
      inherit (config.home) homeDirectory;
    in {
      imports = [flake.modules.homeManager.sops];

      options.features.development.kubernetes = {
        kubeconfigSecret = mkOption {
          type = types.nullOr types.str;
          default = null;
          description = "SOPS secret key for kubeconfig";
        };
      };

      config = {
        home.packages = with pkgs; [
          kubectl
          k9s
        ];

        sops.secrets = mkIf (cfg.kubeconfigSecret != null) {
          ${cfg.kubeconfigSecret} = {
            path = "${homeDirectory}/.kube/config";
            mode = "0600";
          };
        };
      };
    };
}
