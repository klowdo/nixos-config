{
  lib,
  pkgs,
  ...
}:
with lib; {
  xdg.desktopEntries.nm-connection-editor = {
    name = "Advanced Network Configuration";
    comment = "Manage and change your network connection settings";
    exec = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
    icon = "network-wired-symbolic";
    terminal = false;
    type = "Application";
    categories = ["GNOME" "GTK" "Settings"];
    startupNotify = true;
  };
}
