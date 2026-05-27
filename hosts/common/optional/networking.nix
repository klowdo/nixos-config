{lib, ...}: {
  networking.networkmanager.enable = true;
  networking.networkmanager.wifi.powersave = true;

  systemd.services = {
    NetworkManager-wait-online.enable = lib.mkForce false;
    systemd-networkd-wait-online.enable = lib.mkForce false;
  };
}
