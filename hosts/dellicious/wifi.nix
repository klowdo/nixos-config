{
  imports = [../common/optional/wifi-networks.nix];

  wifi = {
    enable = true;
    networks = {
      "home" = {
        ssid = "Napolitana Felix";
        sopsKey = "wifi/home-felix";
      };

      "phone" = {
        ssid = "Felix green phone";
        sopsKey = "wifi/phone-felix";
      };
      "work" = {
        ssid = "Pelagia";
        sopsKey = "wifi/work-pelagia";
      };
    };
  };
}
