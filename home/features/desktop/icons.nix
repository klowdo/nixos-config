{
  lib,
  pkgs,
  ...
}:
with lib; {
  xdg.desktopEntries = {
    nm-connection-editor = {
      name = "Advanced Network Configuration";
      comment = "Manage and change your network connection settings";
      exec = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
      icon = "preferences-system-network";
      terminal = false;
      type = "Application";
      categories = ["GNOME" "GTK" "Settings"];
      startupNotify = true;
    };

    qt5ct = {
      name = "Qt5 Settings";
      comment = "Qt5 Configuration Tool";
      exec = "qt5ct";
      icon = "preferences-desktop-theme";
      terminal = false;
      type = "Application";
      categories = ["Settings" "DesktopSettings" "Qt"];
    };

    qt6ct = {
      name = "Qt6 Settings";
      comment = "Qt6 Configuration Tool";
      exec = "qt6ct";
      icon = "preferences-desktop-theme";
      terminal = false;
      type = "Application";
      categories = ["Settings" "DesktopSettings" "Qt"];
    };

    uuctl = {
      name = "uuctl";
      genericName = "User unit manager";
      comment = "Select and perform actions on user systemd units";
      exec = "uuctl";
      icon = "preferences-system-session-services";
      terminal = false;
      type = "Application";
      categories = ["Utility" "Settings"];
    };

    "org.pulseaudio.pavucontrol" = {
      name = "Volume Control";
      comment = "Adjust the volume level";
      exec = "pavucontrol";
      icon = "pavucontrol";
      terminal = false;
      type = "Application";
      categories = ["AudioVideo" "Audio" "Mixer" "GTK" "Settings"];
      startupNotify = true;
    };
  };
}
