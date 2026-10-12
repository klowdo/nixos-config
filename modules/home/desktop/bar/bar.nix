{...}: {
  flake.modules.homeManager.bar = {
    config,
    lib,
    ...
  }: let
    enabledBars = lib.filter (x: x) [
      (config.programs.hyprpanel.enable or false)
      (config.programs.ashell.enable or false)
      (config.programs.caelestia.enable or false)
    ];
  in {
    assertions = [
      {
        assertion = lib.length enabledBars <= 1;
        message = ''
          Cannot enable multiple status bars simultaneously.
          Please import only one of the hyprpanel, ashell and caelestia aspects.
        '';
      }
    ];
  };
}
