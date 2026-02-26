{lib, ...}:
with lib; {
  xdg.desktopEntries.nm-connection-editor = {
    name = "Advanced Network Configuration";
    comment = "Manage and change your network connection settings";
    exec = "nm-connection-editor";
    icon = "network-wired";
    terminal = false;
    type = "Application";
    categories = ["GNOME" "GTK" "Settings"];
    startupNotify = true;
  };
}
