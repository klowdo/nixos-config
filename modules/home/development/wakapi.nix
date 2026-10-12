{config, ...}: let
  inherit (config) flake;
in {
  flake.modules.homeManager.wakapi = {
    imports = [flake.modules.homeManager.sops];

    sops.secrets."wakapi-config" = {
      sopsFile = ../../../secrets.yaml;
      mode = "0600";
      path = ".wakatime.cfg";
    };
  };
}
