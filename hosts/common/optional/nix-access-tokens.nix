{config, ...}: {
  sops.secrets."nix/access-tokens" = {
    mode = "0400";
    restartUnits = ["nix-daemon.service"];
  };

  nix.extraOptions = ''
    !include ${config.sops.secrets."nix/access-tokens".path}
  '';
}
