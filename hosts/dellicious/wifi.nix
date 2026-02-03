{
  imports = [../common/optional/wifi-networks.nix];

  wifi = {
    enable = true;
    networks = {
      "home" = {
        ssid = "Napolitana Felix";
        sopsKey = "wifi/home-felix";
      };
      "work" = {
        ssid = "Pelagia";
        sopsKey = "wifi/work-pelagia";
        autoconnect = false;
      };
    };
  };
}
