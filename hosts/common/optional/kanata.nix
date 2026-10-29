{
  services.kanata = {
    enable = true;
    keyboards.internal = {
      devices = ["/dev/input/by-path/platform-i8042-serio-0-event-kbd"];

      extraDefCfg = ''
        process-unmapped-keys yes
        concurrent-tap-hold yes
      '';

      config = builtins.readFile ./kanata-homerow.kbd;
    };
  };
}
