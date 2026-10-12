{
  flake.modules.nixos.power-profiles-daemon = {config, ...}: {
    assertions = [
      {
        assertion = !config.services.tlp.enable;
        message = ''
          Only one power manager daemon is allowed at the time: the tlp and power-profiles-daemon aspects are mutually exclusive.
        '';
      }
    ];
    services.power-profiles-daemon.enable = true;
    services.upower.enable = true;
  };
}
