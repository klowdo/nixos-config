{
  lib,
  config,
  ...
}: {
  options.features.development.wakapi.enable = lib.mkEnableOption "wakapi time tracking";

  config = lib.mkIf config.features.development.wakapi.enable {
    sops.secrets."wakapi-config" = {
      sopsFile = ../../../secrets.yaml;
      mode = "0600";
      path = ".wakatime.cfg";
    };
  };
}
