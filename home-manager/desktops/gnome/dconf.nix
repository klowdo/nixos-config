# Generated via dconf2nix: https://github.com/gvolpe/dconf2nix
{ lib, ... }:

with lib.hm.gvariant;

{
  dconf.settings = {
    "com/github/amezin/ddterm" = {
      custom-font = "FiraCode Nerd Font Medium 11";
      detect-urls-voip = true;
      palette = [ "rgb(23,20,33)" "rgb(192,28,40)" "rgb(38,162,105)" "rgb(162,115,76)" "rgb(18,72,139)" "rgb(163,71,186)" "rgb(42,161,179)" "rgb(208,207,204)" "rgb(94,92,100)" "rgb(246,97,81)" "rgb(51,218,122)" "rgb(233,173,12)" "rgb(42,123,222)" "rgb(192,97,203)" "rgb(51,199,222)" "rgb(255,255,255)" ];
      panel-icon-type = "none";
      use-system-font = false;
      window-maximize = false;
      window-size = 0.5499999999999996;
    };

    "com/github/donadigo/eddy" = {
      mime-types = [ "application/vnd.debian.binary-package" "application/x-deb" ];
      window-x = 0;
      window-y = 32;
    };

    "com/system76/hidpi" = {
      enable = false;
      mode = "hidpi";
    };

    "io/elementary/appcenter/settings" = {
      cached-drivers = [ "nvidia-driver-550-open" "nvidia-driver-535-open" "nvidia-driver-550" "nvidia-driver-535-server-open" "nvidia-driver-545-open" "nvidia-driver-535-server" ];
      last-refresh-time = mkInt64 1718256758;
      window-height = 692;
      window-maximized = false;
      window-position = mkTuple [ 1156 740 ];
      window-size = mkTuple [ 1270 2112 ];
      window-width = 1140;
    };

    "net/flyingpimonster/Camera" = {
      capture-mode = "picture";
    };

    "org/gnome/Connections" = {
      first-run = false;
    };

    "org/gnome/Geary" = {
      migrated-config = true;
      window-height = 1392;
      window-maximize = false;
      window-width = 1140;
    };

    "org/gnome/Totem" = {
      active-plugins = [ "recent" "autoload-subtitles" "apple-trailers" "vimeo" "open-directory" "movie-properties" "skipto" "screenshot" "variable-rate" "screensaver" "save-file" "mpris" "rotation" ];
      subtitle-encoding = "UTF-8";
    };

    "org/gnome/baobab/ui" = {
      active-chart = "rings";
      window-size = mkTuple [ 2548 1052 ];
      window-state = 87168;
    };

    "org/gnome/boxes" = {
      first-run = false;
      view = "icon-view";
      window-maximized = false;
      window-position = [ 1156 40 ];
      window-size = [ 1140 1392 ];
    };

    "org/gnome/calculator" = {
      accuracy = 9;
      angle-units = "degrees";
      base = 10;
      button-mode = "basic";
      number-format = "automatic";
      show-thousands = false;
      show-zeroes = false;
      source-currency = "";
      source-units = "degree";
      target-currency = "";
      target-units = "radian";
      window-position = mkTuple [ 1924 40 ];
      word-size = 64;
    };

    "org/gnome/calendar" = {
      active-view = "month";
      window-maximized = false;
      window-position = mkTuple [ 1286 40 ];
      window-size = mkTuple [ 1270 2112 ];
    };

    "org/gnome/cheese" = {
      burst-delay = 1000;
      camera = "HP Display Camera (V4L2)";
      photo-x-resolution = 3840;
      photo-y-resolution = 2160;
      video-x-resolution = 3840;
      video-y-resolution = 2160;
    };

    "org/gnome/control-center" = {
      last-panel = "bluetooth";
    };

    "org/gnome/desktop/app-folders/folders/Pop-Office" = {
      apps = [ "libreoffice-calc.desktop" "libreoffice-draw.desktop" "libreoffice-impress.desktop" "libreoffice-math.desktop" "libreoffice-startcenter.desktop" "libreoffice-writer.desktop" ];
      name = "Office";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/Pop-System" = {
      apps = [ "gnome-language-selector.desktop" "gnome-session-properties.desktop" "gnome-system-monitor.desktop" "im-config.desktop" "nm-connection-editor.desktop" "nvidia-settings.desktop" "org.gnome.baobab.desktop" "org.gnome.DiskUtility.desktop" "org.gnome.PowerStats.desktop" "org.gnome.seahorse.Application.desktop" "software-properties-gnome.desktop" "system76-driver.desktop" "system76-firmware.desktop" ];
      name = "System";
      translate = true;
    };

    "org/gnome/desktop/app-folders/folders/Pop-Utility" = {
      apps = [ "com.github.donadigo.eddy.desktop" "com.system76.Popsicle.desktop" "gucharmap.desktop" "info.desktop" "org.gnome.eog.desktop" "org.gnome.Evince.desktop" "org.gnome.Extensions.desktop" "org.gnome.FileRoller.desktop" "org.gnome.font-viewer.desktop" "org.gnome.Screenshot.desktop" "org.gnome.Totem.desktop" "pop-cosmic-applications.desktop" "pop-cosmic-launcher.desktop" "pop-cosmic-workspaces.desktop" "simple-scan.desktop" "yelp.desktop" ];
      name = "Utilities";
      translate = true;
    };

    "org/gnome/desktop/background" = {
      color-shading-type = "solid";
      picture-options = "zoom";
      picture-uri = "file:///home/klowdo/Pictures/Wallpapers/car.jpeg";
      picture-uri-dark = "file:///home/klowdo/Pictures/Wallpapers/car.jpeg";
      primary-color = "#000000";
      secondary-color = "#000000";
    };

    "org/gnome/desktop/calendar" = {
      show-weekdate = false;
    };

    "org/gnome/desktop/input-sources" = {
      current = mkUint32 0;
      mru-sources = [ (mkTuple [ "xkb" "us" ]) (mkTuple [ "xkb" "se" ]) ];
      per-window = false;
      sources = [ (mkTuple [ "xkb" "us" ]) (mkTuple [ "xkb" "se" ]) ];
      xkb-options = [ "caps:none" ];
    };

    "org/gnome/desktop/interface" = {
      clock-format = "24h";
      color-scheme = "prefer-dark";
      font-antialiasing = "grayscale";
      font-hinting = "slight";
      gtk-theme = "Pop-dark";
      show-battery-percentage = true;
    };

    "org/gnome/desktop/notifications" = {
      application-children = [ "org-gnome-nautilus" "org-gnome-fileroller" "jetbrains-toolbox" "firefox" "gnome-power-panel" "io-elementary-appcenter" "gnome-control-center" "flatpak-installer" "org-gnome-networkdisplays" "io-github-mrvladus-list" "com-spotify-client" "org-gnome-geary" "org-telegram-desktop" "org-gnome-font-viewer" "org-gnome-fontmanager" "jetbrains-rider" "code" "org-gnome-shell-extensions-gsconnect" "org-gnome-eog" "org-gnome-gedit" "xdg-desktop-portal-gnome" "com-slack-slack" "com-github-donadigo-eddy" "postman-postman" "org-gnome-totem" "com-ozmartians-vidcutter" "vlc" "org-gnome-calendar" "jetbrains-rider-1" "com-google-chrome" "org-gnome-chromegnomeshell" "org-gnome-extensions-desktop" "org-gnome-terminal" "org-gnome-calculator" "gnome-network-panel" "io-snapcraft-sessionagent" "jetbrains-fleet" "org-gnome-diskutility" "org-gnome-baobab" "mqtt-explorer-mqtt-explorer" "virt-manager" "solaar" "jetbrains-datagrip" "org-gnome-tweaks" "org-kicad-pcbnew" "dev-k8slens-openlens" "webcamoid" "rider-2aff1f2a-983e-41a3-9fd8-d2b96098bec1" "jetbrains-rider-6202c539-6fd8-45b8-9de6-d0e2c024b3a5" "org-gnome-shell-portalhelper" "1password" "org-gnome-shell-extensions" "com-alacritty-alacritty" "org-gnome-boxes" "com-discordapp-discord" "jetbrains-rider-18faf9d9-8e34-472a-9000-9da4581d2a5b" "org-gnome-evince" "jetbrains-rider-b2653b50-dd82-477c-aacc-84af85e435d5" ];
    };

    "org/gnome/desktop/notifications/application/1password" = {
      application-id = "1password.desktop";
    };

    "org/gnome/desktop/notifications/application/code" = {
      application-id = "code.desktop";
    };

    "org/gnome/desktop/notifications/application/com-alacritty-alacritty" = {
      application-id = "com.alacritty.Alacritty.desktop";
    };

    "org/gnome/desktop/notifications/application/com-discordapp-discord" = {
      application-id = "com.discordapp.Discord.desktop";
    };

    "org/gnome/desktop/notifications/application/com-github-donadigo-eddy" = {
      application-id = "com.github.donadigo.eddy.desktop";
    };

    "org/gnome/desktop/notifications/application/com-google-chrome" = {
      application-id = "com.google.Chrome.desktop";
    };

    "org/gnome/desktop/notifications/application/com-ozmartians-vidcutter" = {
      application-id = "com.ozmartians.VidCutter.desktop";
    };

    "org/gnome/desktop/notifications/application/com-slack-slack" = {
      application-id = "com.slack.Slack.desktop";
    };

    "org/gnome/desktop/notifications/application/com-spotify-client" = {
      application-id = "com.spotify.Client.desktop";
    };

    "org/gnome/desktop/notifications/application/dev-k8slens-openlens" = {
      application-id = "dev.k8slens.OpenLens.desktop";
    };

    "org/gnome/desktop/notifications/application/firefox" = {
      application-id = "firefox.desktop";
    };

    "org/gnome/desktop/notifications/application/flatpak-installer" = {
      application-id = "flatpak-installer.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-control-center" = {
      application-id = "gnome-control-center.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-network-panel" = {
      application-id = "gnome-network-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/gnome-power-panel" = {
      application-id = "gnome-power-panel.desktop";
    };

    "org/gnome/desktop/notifications/application/io-elementary-appcenter" = {
      application-id = "io.elementary.appcenter.desktop";
    };

    "org/gnome/desktop/notifications/application/io-github-mrvladus-list" = {
      application-id = "io.github.mrvladus.List.desktop";
    };

    "org/gnome/desktop/notifications/application/io-snapcraft-sessionagent" = {
      application-id = "io.snapcraft.SessionAgent.desktop";
    };

    "org/gnome/desktop/notifications/application/jetbrains-datagrip" = {
      application-id = "jetbrains-datagrip.desktop";
    };

    "org/gnome/desktop/notifications/application/jetbrains-fleet" = {
      application-id = "jetbrains-fleet.desktop";
    };

    "org/gnome/desktop/notifications/application/jetbrains-rider-1" = {
      application-id = "jetbrains-rider-1.desktop";
    };

    "org/gnome/desktop/notifications/application/jetbrains-rider-18faf9d9-8e34-472a-9000-9da4581d2a5b" = {
      application-id = "jetbrains-rider-18faf9d9-8e34-472a-9000-9da4581d2a5b.desktop";
    };

    "org/gnome/desktop/notifications/application/jetbrains-rider-6202c539-6fd8-45b8-9de6-d0e2c024b3a5" = {
      application-id = "jetbrains-rider-6202c539-6fd8-45b8-9de6-d0e2c024b3a5.desktop";
    };

    "org/gnome/desktop/notifications/application/jetbrains-rider-b2653b50-dd82-477c-aacc-84af85e435d5" = {
      application-id = "jetbrains-rider-b2653b50-dd82-477c-aacc-84af85e435d5.desktop";
    };

    "org/gnome/desktop/notifications/application/jetbrains-rider" = {
      application-id = "jetbrains-rider.desktop";
    };

    "org/gnome/desktop/notifications/application/jetbrains-toolbox" = {
      application-id = "jetbrains-toolbox.desktop";
    };

    "org/gnome/desktop/notifications/application/mqtt-explorer-mqtt-explorer" = {
      application-id = "mqtt-explorer_mqtt-explorer.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-baobab" = {
      application-id = "org.gnome.baobab.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-boxes" = {
      application-id = "org.gnome.Boxes.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-calculator" = {
      application-id = "org.gnome.Calculator.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-calendar" = {
      application-id = "org.gnome.Calendar.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-chromegnomeshell" = {
      application-id = "org.gnome.ChromeGnomeShell.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-diskutility" = {
      application-id = "org.gnome.DiskUtility.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-eog" = {
      application-id = "org.gnome.eog.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-evince" = {
      application-id = "org.gnome.Evince.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-extensions-desktop" = {
      application-id = "org.gnome.Extensions.desktop.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-fileroller" = {
      application-id = "org.gnome.FileRoller.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-font-viewer" = {
      application-id = "org.gnome.font-viewer.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-fontmanager" = {
      application-id = "org.gnome.FontManager.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-geary" = {
      application-id = "org.gnome.Geary.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-gedit" = {
      application-id = "org.gnome.gedit.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-nautilus" = {
      application-id = "org.gnome.Nautilus.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-networkdisplays" = {
      application-id = "org.gnome.NetworkDisplays.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-shell-extensions-gsconnect" = {
      application-id = "org.gnome.Shell.Extensions.GSConnect.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-shell-extensions" = {
      application-id = "org.gnome.Shell.Extensions.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-shell-portalhelper" = {
      application-id = "org.gnome.Shell.PortalHelper.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-terminal" = {
      application-id = "org.gnome.Terminal.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-totem" = {
      application-id = "org.gnome.Totem.desktop";
    };

    "org/gnome/desktop/notifications/application/org-gnome-tweaks" = {
      application-id = "org.gnome.tweaks.desktop";
    };

    "org/gnome/desktop/notifications/application/org-kicad-pcbnew" = {
      application-id = "org.kicad.pcbnew.desktop";
    };

    "org/gnome/desktop/notifications/application/org-telegram-desktop" = {
      application-id = "org.telegram.desktop.desktop";
    };

    "org/gnome/desktop/notifications/application/postman-postman" = {
      application-id = "postman_postman.desktop";
    };

    "org/gnome/desktop/notifications/application/rider-2aff1f2a-983e-41a3-9fd8-d2b96098bec1" = {
      application-id = "Rider-2aff1f2a-983e-41a3-9fd8-d2b96098bec1.desktop";
    };

    "org/gnome/desktop/notifications/application/solaar" = {
      application-id = "solaar.desktop";
    };

    "org/gnome/desktop/notifications/application/virt-manager" = {
      application-id = "virt-manager.desktop";
    };

    "org/gnome/desktop/notifications/application/vlc" = {
      application-id = "vlc.desktop";
    };

    "org/gnome/desktop/notifications/application/webcamoid" = {
      application-id = "webcamoid.desktop";
    };

    "org/gnome/desktop/notifications/application/xdg-desktop-portal-gnome" = {
      application-id = "xdg-desktop-portal-gnome.desktop";
    };

    "org/gnome/desktop/peripherals/keyboard" = {
      numlock-state = true;
    };

    "org/gnome/desktop/peripherals/mouse" = {
      accel-profile = "adaptive";
      speed = 0.25;
    };

    "org/gnome/desktop/peripherals/touchpad" = {
      natural-scroll = false;
      speed = 0.125;
      two-finger-scrolling-enabled = true;
    };

    "org/gnome/desktop/privacy" = {
      remove-old-trash-files = true;
      report-technical-problems = false;
    };

    "org/gnome/desktop/remote-desktop/rdp" = {
      enable = true;
      screen-share-mode = "extend";
      tls-cert = "/home/klowdo/certificates/server.crt";
      tls-key = "/home/klowdo/certificates/server.key";
      view-only = false;
    };

    "org/gnome/desktop/remote-desktop/vnc" = {
      auth-method = "prompt";
      enable = true;
      view-only = false;
    };

    "org/gnome/desktop/screensaver" = {
      lock-delay = mkUint32 0;
    };

    "org/gnome/desktop/session" = {
      idle-delay = mkUint32 300;
    };

    "org/gnome/desktop/sound" = {
      event-sounds = false;
    };

    "org/gnome/desktop/wm/preferences" = {
      button-layout = "appmenu:minimize,close";
      workspace-names = [ "1" ];
    };

    "org/gnome/eog/ui" = {
      sidebar = false;
    };

    "org/gnome/eog/view" = {
      background-color = "rgb(0,0,0)";
      use-background-color = true;
    };

    "org/gnome/evince/default" = {
      window-ratio = mkTuple [ 1.9150651794113691 1.6534226561664827 ];
    };

    "org/gnome/evolution-data-server" = {
      migrated = true;
      network-monitor-gio-name = "";
    };

    "org/gnome/file-roller/dialogs/add" = {
      current-folder = "file:///home/klowdo/Downloads";
      exclude-files = "";
      exclude-folders = "";
      include-files = "*";
      no-symlinks = true;
      selected-files = [];
      update = false;
    };

    "org/gnome/file-roller/dialogs/extract" = {
      recreate-folders = true;
      skip-newer = false;
    };

    "org/gnome/file-roller/file-selector" = {
      show-hidden = false;
      sidebar-size = 156;
      window-size = mkTuple [ 780 734 ];
    };

    "org/gnome/file-roller/listing" = {
      list-mode = "as-folder";
      name-column-width = 377;
      show-path = false;
      sort-method = "name";
      sort-type = "descending";
    };

    "org/gnome/file-roller/ui" = {
      sidebar-width = 200;
      window-height = 1005;
      window-width = 790;
    };

    "org/gnome/font-manager" = {
      compare-background-color = "rgb(255,255,255)";
      compare-foreground-color = "rgb(0,0,0)";
      compare-list = [];
      content-pane-position = 186;
      google-fonts-background-color = "rgb(255,255,255)";
      google-fonts-foreground-color = "rgb(0,0,0)";
      is-maximized = false;
      language-filter-list = [];
      selected-category = "0";
      window-position = mkTuple [ 8 560 ];
      window-size = mkTuple [ 852 465 ];
    };

    "org/gnome/gedit/plugins" = {
      active-plugins = [ "filebrowser" "docinfo" "modelines" "openlinks" "spell" "sort" ];
    };

    "org/gnome/gedit/plugins/filebrowser" = {
      root = "file:///";
      tree-view = true;
      virtual-root = "file:///home/klowdo/dev/volvocars/ESL.HEMS/VolvoWallbox.Customer.Api/VolvoWallbox.Customer.Infrastructure";
    };

    "org/gnome/gedit/preferences/editor" = {
      scheme = "pop-dark";
    };

    "org/gnome/gedit/preferences/ui" = {
      show-tabs-mode = "auto";
    };

    "org/gnome/gedit/state/window" = {
      bottom-panel-size = 140;
      side-panel-active-page = "GeditWindowDocumentsPanel";
      side-panel-size = 200;
      size = mkTuple [ 1494 2065 ];
      state = 87168;
    };

    "org/gnome/gnome-system-monitor" = {
      cpu-colors = [ (mkTuple [ (mkUint32 0) "#e6194B" ]) (mkTuple [ 1 "#f58231" ]) (mkTuple [ 2 "#ffe119" ]) (mkTuple [ 3 "#bfef45" ]) (mkTuple [ 4 "#3cb44b" ]) (mkTuple [ 5 "#42d4f4" ]) (mkTuple [ 6 "#4363d8" ]) (mkTuple [ 7 "#911eb4" ]) (mkTuple [ 8 "#f032e6" ]) (mkTuple [ 9 "#fabebe" ]) (mkTuple [ 10 "#ffd8b1" ]) (mkTuple [ 11 "#fffac8" ]) (mkTuple [ 12 "#aaffc3" ]) (mkTuple [ 13 "#469990" ]) (mkTuple [ 14 "#000075" ]) (mkTuple [ 15 "#e6beff" ]) (mkTuple [ 16 "#a4fe7999f332" ]) (mkTuple [ 17 "#7999f3328182" ]) (mkTuple [ 18 "#f3327999952a" ]) (mkTuple [ 19 "#7999b8a6f332" ]) ];
      current-tab = "processes";
      maximized = false;
      network-total-in-bits = false;
      show-dependencies = true;
      show-whose-processes = "user";
      window-state = mkTuple [ 1270 2112 1286 40 ];
    };

    "org/gnome/gnome-system-monitor/disktreenew" = {
      col-6-visible = true;
      col-6-width = 0;
    };

    "org/gnome/mutter" = {
      edge-tiling = false;
      experimental-features = [ "x11-randr-fractional-scaling" ];
    };

    "org/gnome/nautilus/list-view" = {
      default-zoom-level = "small";
    };

    "org/gnome/nautilus/preferences" = {
      default-folder-viewer = "list-view";
      search-filter-time-type = "last_modified";
      search-view = "list-view";
    };

    "org/gnome/nautilus/window-state" = {
      initial-size = mkTuple [ 1750 2112 ];
      maximized = false;
      sidebar-width = 219;
      start-with-sidebar = true;
    };

    "org/gnome/nm-applet/eap/1e5015f6-8ae6-44ac-bb60-d0f6d953e76d" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };

    "org/gnome/nm-applet/eap/51554e24-aeb3-449f-8bfc-49fe9c4dd23a" = {
      ignore-ca-cert = false;
      ignore-phase2-ca-cert = false;
    };

    "org/gnome/power-manager" = {
      info-history-type = "charge";
      info-last-device = "/org/freedesktop/UPower/devices/battery_BAT0";
      info-stats-type = "discharge-accuracy";
    };

    "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/PopLaunch1" = {
      binding = "Launch1";
      command = "gnome-control-center wifi";
      name = "WiFi";
    };

    "org/gnome/settings-daemon/plugins/power" = {
      ambient-enabled = false;
      sleep-inactive-ac-timeout = 1800;
      sleep-inactive-ac-type = "suspend";
      sleep-inactive-battery-timeout = 1800;
      sleep-inactive-battery-type = "suspend";
    };

    "org/gnome/settings-daemon/plugins/sharing/rygel" = {
      enabled-connections = [];
    };

    "org/gnome/shell" = {
      command-history = [ "r" ];
      disabled-extensions = [ "freon@UshakovVasilii_Github.yahoo.com" "cosmic-dock@system76.com" "dell-command-configure-menu@vsimkus.github.io" ];
      enabled-extensions = [ "ding@rastersoft.com" "pop-cosmic@system76.com" "pop-shell@system76.com" "system76-power@system76.com" "ubuntu-appindicators@ubuntu.com" "cosmic-workspaces@system76.com" "popx11gestures@system76.com" "ddterm@amezin.github.com" "clipboard-indicator@tudmotu.com" "caffeine@patapon.info" "gsconnect@andyholmes.github.io" "extension-list@tu.berry" "places-menu@gnome-shell-extensions.gcampax.github.com" "display-scale-switcher@knokelmaat.gitlab.com" "bluetooth-quick-connect@bjarosze.gmail.com" "space-bar@luchrioh" "user-theme@gnome-shell-extensions.gcampax.github.com" "wireguard-indicator@atareao.es" "draw-on-your-screen2@zhrexl.github.com" "sound-output-device-chooser@kgshank.net" "mediacontrols@cliffniff.github.com" "tailscale-status@maxgallup.github.com" ];
      favorite-apps = [ "pop-cosmic-launcher.desktop" "firefox.desktop" "org.gnome.Nautilus.desktop" "org.gnome.Terminal.desktop" "io.elementary.appcenter.desktop" "io.elementary.installer.desktop" "gnome-control-center.desktop" ];
      had-bluetooth-devices-setup = true;
      # welcome-dialog-last-shown-version = "42.5";
    };

    "org/gnome/shell/extensions/atareao/wireguard-indicator" = {
      nmcli = true;
      services = [ "home|wg-quick@home" ];
      sudo = true;
    };

    "org/gnome/shell/extensions/caffeine" = {
      user-enabled = true;
    };

    "org/gnome/shell/extensions/cpufreq" = {
      profile-id = "user";
      save-settings = true;
      user-profile = ''
        {"name":"Saved settings","minf":8,"maxf":86,"turbo":false,"cpu":20,"acpi":false,"guid":"user","core":[{"g":"powersave","a":400000,"b":5200000},{"g":"powersave","a":400000,"b":5200000},{"g":"powersave","a":400000,"b":5200000},{"g":"powersave","a":400000,"b":5200000},{"g":"powersave","a":400000,"b":5200000},{"g":"powersave","a":400000,"b":5200000},{"g":"powersave","a":400000,"b":5200000},{"g":"powersave","a":400000,"b":5200000},{"g":"powersave","a":400000,"b":5200000},{"g":"powersave","a":400000,"b":5200000},{"g":"powersave","a":400000,"b":5200000},{"g":"powersave","a":400000,"b":5200000},{"g":"powersave","a":400000,"b":4100000},{"g":"powersave","a":400000,"b":4100000},{"g":"powersave","a":400000,"b":4100000},{"g":"powersave","a":400000,"b":4100000},{"g":"powersave","a":400000,"b":4100000},{"g":"powersave","a":400000,"b":4100000},{"g":"powersave","a":400000,"b":4100000},{"g":"powersave","a":400000,"b":4100000}]}
      '';
      window-height = 646;
      window-maximized = false;
      window-width = 1140;
      window-x = -18;
      window-y = 717;
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      dock-fixed = false;
      extend-height = false;
      intellihide = false;
      manualhide = false;
    };

    "org/gnome/shell/extensions/draw-on-your-screen" = {
      drawing-on-desktop = true;
    };

    "org/gnome/shell/extensions/extension-list" = {
      hide-disabled = false;
      unpin-button = false;
      unpin-list = [];
    };

    "org/gnome/shell/extensions/freon" = {
      use-gpu-nvidia = false;
    };

    "org/gnome/shell/extensions/gsconnect" = {
      devices = [ "dcdc55ee_7f94_4e46_9535_b4c363a33659" ];
      enabled = true;
      id = "5182ea21-69ab-48e2-a80f-23e24aadb1f6";
      name = "pop-os-dell";
    };

    "org/gnome/shell/extensions/gsconnect/device/_f796356c_424b_415c_9fb3_9ee7c7a0815f_" = {
      incoming-capabilities = [ "kdeconnect.battery" "kdeconnect.battery.request" "kdeconnect.bigscreen.stt" "kdeconnect.clipboard" "kdeconnect.clipboard.connect" "kdeconnect.connectivity_report" "kdeconnect.contacts.response_uids_timestamps" "kdeconnect.contacts.response_vcards" "kdeconnect.findmyphone.request" "kdeconnect.lock" "kdeconnect.lock.request" "kdeconnect.mousepad.echo" "kdeconnect.mousepad.keyboardstate" "kdeconnect.mousepad.request" "kdeconnect.mpris" "kdeconnect.mpris.request" "kdeconnect.notification" "kdeconnect.notification.request" "kdeconnect.photo" "kdeconnect.ping" "kdeconnect.presenter" "kdeconnect.runcommand" "kdeconnect.runcommand.request" "kdeconnect.sftp" "kdeconnect.share.request" "kdeconnect.sms.attachment_file" "kdeconnect.sms.messages" "kdeconnect.systemvolume" "kdeconnect.systemvolume.request" "kdeconnect.telephony" ];
      last-connection = "lan://10.101.5.95:1716";
      name = "dhultqvist-spotify";
      outgoing-capabilities = [ "kdeconnect.battery" "kdeconnect.battery.request" "kdeconnect.bigscreen.stt" "kdeconnect.clipboard" "kdeconnect.clipboard.connect" "kdeconnect.connectivity_report.request" "kdeconnect.contacts.request_all_uids_timestamps" "kdeconnect.contacts.request_vcards_by_uid" "kdeconnect.findmyphone.request" "kdeconnect.lock" "kdeconnect.lock.request" "kdeconnect.mousepad.keyboardstate" "kdeconnect.mousepad.request" "kdeconnect.mpris" "kdeconnect.mpris.request" "kdeconnect.notification" "kdeconnect.notification.action" "kdeconnect.notification.reply" "kdeconnect.notification.request" "kdeconnect.photo.request" "kdeconnect.ping" "kdeconnect.runcommand" "kdeconnect.runcommand.request" "kdeconnect.sftp.request" "kdeconnect.share.request" "kdeconnect.share.request.update" "kdeconnect.sms.request" "kdeconnect.sms.request_attachment" "kdeconnect.sms.request_conversation" "kdeconnect.sms.request_conversations" "kdeconnect.systemvolume" "kdeconnect.systemvolume.request" "kdeconnect.telephony.request_mute" ];
      supported-plugins = [ "battery" "clipboard" "findmyphone" "mousepad" "mpris" "notification" "photo" "ping" "runcommand" "share" "systemvolume" ];
      type = "desktop";
    };

    "org/gnome/shell/extensions/gsconnect/device/_f796356c_424b_415c_9fb3_9ee7c7a0815f_/plugin/battery" = {
      custom-battery-notification-value = mkUint32 80;
    };

    "org/gnome/shell/extensions/gsconnect/device/_f796356c_424b_415c_9fb3_9ee7c7a0815f_/plugin/notification" = {
      applications = ''
        {"Printers":{"iconName":"printer","enabled":true},"Evolution Alarm Notify":{"iconName":"appointment-soon","enabled":true},"Solaar":{"iconName":"solaar","enabled":true},"Telegram Desktop":{"iconName":"org.telegram.desktop","enabled":true},"Support":{"iconName":"pop-support","enabled":true},"Snapd User Session Agent":{"iconName":"application-x-executable","enabled":true},"Date & Time":{"iconName":"preferences-system-time","enabled":true},"Network":{"iconName":"nm-device-wireless","enabled":true},"Disk Usage Analyzer":{"iconName":"org.gnome.baobab","enabled":true},"Geary":{"iconName":"org.gnome.Geary","enabled":true},"Power":{"iconName":"gnome-power-manager","enabled":true},"Color":{"iconName":"preferences-color","enabled":true},"Spotify":{"iconName":"com.spotify.Client","enabled":true},"Pop!_Shop":{"iconName":"io.elementary.appcenter","enabled":true},"Files":{"iconName":"org.gnome.Nautilus","enabled":true},"Firmware":{"iconName":"firmware-manager","enabled":true},"Archive Manager":{"iconName":"org.gnome.ArchiveManager","enabled":true},"Eddy":{"iconName":"com.github.donadigo.eddy","enabled":true},"OS Upgrade & Recovery":{"iconName":"software-update-available-symbolic","enabled":true}}
      '';
    };

    "org/gnome/shell/extensions/gsconnect/device/_f796356c_424b_415c_9fb3_9ee7c7a0815f_/plugin/share" = {
      receive-directory = "/home/klowdo/Downloads";
    };

    "org/gnome/shell/extensions/gsconnect/device/dcdc55ee_7f94_4e46_9535_b4c363a33659" = {
      certificate-pem = "-----BEGIN CERTIFICATE-----nMIIDHzCCAgegAwIBAgIBATANBgkqhkiG9w0BAQsFADBTMS0wKwYDVQQDDCRkY2RjnNTVlZV83Zjk0XzRlNDZfOTUzNV9iNGMzNjNhMzM2NTkxFDASBgNVBAsMC0tERSBDnb25uZWN0MQwwCgYDVQQKDANLREUwHhcNMjIwNTE1MjIwMDAwWhcNMzIwNTE1MjIwnMDAwWjBTMS0wKwYDVQQDDCRkY2RjNTVlZV83Zjk0XzRlNDZfOTUzNV9iNGMzNjNhnMzM2NTkxFDASBgNVBAsMC0tERSBDb25uZWN0MQwwCgYDVQQKDANLREUwggEiMA0GnCSqGSIb3DQEBAQUAA4IBDwAwggEKAoIBAQClMeXsEpN1uRuRVnIPAkSSKGzJHVl8nmpWXeIMXcwgr94/X9LJT8EauraKOo2XiPyH3OFiBXMeYvvE3U3XR3amiIrRqOXnbnpFts+/iIodDJAbGgJVXu2e2/MYeurZnMfzzngSquy8GBXH4mQvli6ZicBB7MhDG7nNbJIONi8xzwFIfcqDgAEsVH7ReW6ebplQuwZjbKsxLA2A3FqOdoSXppEjK4DYSPRn5V7loT/7xh1wxXXMTiP0bsxi4BN+yLXhSfaOt9OfDYOCJL+o2IbNnPRuis9cwnW1ndrXz4raNmPNQGt+TuYFenV2jAVRE2rheMciTaHNHgpUYQRYOutjmw12fAgMBAAEwnDQYJKoZIhvcNAQELBQADggEBAIhTrenRmV8fxZtoqrRGi2ntQPQTt4YJizADRavRnC2bncs9cb5fZdCJwoW5avdhzHpTXOziQ3TO8okZlFJFzSFgxpW7Ov5udGrvkin3GnKWKWRkIFSDZoX/nmxSX1HrmRs6Gi41GGARzJwicVlv2hM72NWbrMJ88iUdDBbGuGnF1LQRv0RGrlYhlQUk15LjeQjmrIS/YiB5wdIJzWWY5/IT8+1C5Ao+GXqk5ptV6GLnI5KlZ99w6Xep5sMD/L835xMPI8QcB7ZSvtI5e2eIumKM/EQn/AfH2IQNGLwWIKTlnZXwVkGcLMMsURXOzSUt4KmATSPvewqOsXOufAsyCUixL7s8=n-----END CERTIFICATE-----n";
      incoming-capabilities = [ "kdeconnect.battery" "kdeconnect.bigscreen.stt" "kdeconnect.clipboard" "kdeconnect.clipboard.connect" "kdeconnect.contacts.request_all_uids_timestamps" "kdeconnect.contacts.request_vcards_by_uid" "kdeconnect.findmyphone.request" "kdeconnect.mousepad.keyboardstate" "kdeconnect.mousepad.request" "kdeconnect.mpris" "kdeconnect.mpris.request" "kdeconnect.notification" "kdeconnect.notification.action" "kdeconnect.notification.reply" "kdeconnect.notification.request" "kdeconnect.photo.request" "kdeconnect.ping" "kdeconnect.runcommand" "kdeconnect.sftp.request" "kdeconnect.share.request" "kdeconnect.share.request.update" "kdeconnect.sms.request" "kdeconnect.sms.request_attachment" "kdeconnect.sms.request_conversation" "kdeconnect.sms.request_conversations" "kdeconnect.systemvolume" "kdeconnect.telephony.request" "kdeconnect.telephony.request_mute" ];
      last-connection = "lan://192.168.1.214:1716";
      name = "SM-G998B";
      outgoing-capabilities = [ "kdeconnect.battery" "kdeconnect.bigscreen.stt" "kdeconnect.clipboard" "kdeconnect.clipboard.connect" "kdeconnect.connectivity_report" "kdeconnect.contacts.response_uids_timestamps" "kdeconnect.contacts.response_vcards" "kdeconnect.findmyphone.request" "kdeconnect.mousepad.echo" "kdeconnect.mousepad.keyboardstate" "kdeconnect.mousepad.request" "kdeconnect.mpris" "kdeconnect.mpris.request" "kdeconnect.notification" "kdeconnect.notification.request" "kdeconnect.photo" "kdeconnect.ping" "kdeconnect.presenter" "kdeconnect.runcommand.request" "kdeconnect.sftp" "kdeconnect.share.request" "kdeconnect.sms.attachment_file" "kdeconnect.sms.messages" "kdeconnect.systemvolume.request" "kdeconnect.telephony" ];
      paired = true;
      supported-plugins = [ "battery" "clipboard" "connectivity_report" "contacts" "findmyphone" "mousepad" "mpris" "notification" "photo" "ping" "presenter" "runcommand" "sftp" "share" "sms" "systemvolume" "telephony" ];
      type = "phone";
    };

    "org/gnome/shell/extensions/gsconnect/device/dcdc55ee_7f94_4e46_9535_b4c363a33659/plugin/battery" = {
      custom-battery-notification-value = mkUint32 80;
    };

    "org/gnome/shell/extensions/gsconnect/device/dcdc55ee_7f94_4e46_9535_b4c363a33659/plugin/clipboard" = {
      receive-content = true;
      send-content = true;
    };

    "org/gnome/shell/extensions/gsconnect/device/dcdc55ee_7f94_4e46_9535_b4c363a33659/plugin/notification" = {
      applications = ''
        {"Printers":{"iconName":"printer","enabled":true},"Evolution Alarm Notify":{"iconName":"appointment-soon","enabled":true},"Solaar":{"iconName":"solaar","enabled":true},"Telegram Desktop":{"iconName":"org.telegram.desktop","enabled":true},"Support":{"iconName":"pop-support","enabled":true},"Snapd User Session Agent":{"iconName":"application-x-executable","enabled":true},"Date & Time":{"iconName":"preferences-system-time","enabled":true},"Network":{"iconName":"nm-device-wireless","enabled":true},"Disk Usage Analyzer":{"iconName":"org.gnome.baobab","enabled":true},"Geary":{"iconName":"org.gnome.Geary","enabled":true},"Power":{"iconName":"gnome-power-manager","enabled":true},"Color":{"iconName":"preferences-color","enabled":true},"Spotify":{"iconName":"com.spotify.Client","enabled":true},"Pop!_Shop":{"iconName":"io.elementary.appcenter","enabled":true},"Files":{"iconName":"org.gnome.Nautilus","enabled":true},"Firmware":{"iconName":"firmware-manager","enabled":true},"Archive Manager":{"iconName":"org.gnome.ArchiveManager","enabled":true},"Eddy":{"iconName":"com.github.donadigo.eddy","enabled":true},"OS Upgrade & Recovery":{"iconName":"software-update-available-symbolic","enabled":true},"System76 HiDPI Scaling":{"iconName":"preferences-desktop-display","enabled":true},"Slack":{"iconName":"","enabled":true},"Rider":{"iconName":"/home/klowdo/.local/share/JetBrains/Toolbox/apps/Rider/ch-0/231.8770.54/bin/rider.svg","enabled":true},"GNOME Shell integration":{"iconName":"org.gnome.ChromeGnomeShell","enabled":true},"GNOME Remote Desktop":{"iconName":"preferences-desktop-remote-desktop","enabled":true},"Disk Space":{"iconName":"drive-harddisk-symbolic","enabled":true},"Flatpak Installer":{"iconName":"repoman","enabled":true},"DataGrip":{"iconName":"/home/klowdo/.local/share/JetBrains/Toolbox/apps/datagrip/ch-0/232.9559.28/bin/datagrip.svg","enabled":true},"Boxes":{"iconName":"org.gnome.Boxes","enabled":true}}
      '';
    };

    "org/gnome/shell/extensions/gsconnect/device/dcdc55ee_7f94_4e46_9535_b4c363a33659/plugin/share" = {
      receive-directory = "/home/klowdo/Downloads";
    };

    "org/gnome/shell/extensions/gsconnect/device/dcdc55ee_7f94_4e46_9535_b4c363a33659/plugin/telephony" = {
      ringing-pause = true;
    };

    "org/gnome/shell/extensions/gsconnect/messaging" = {
      window-maximized = false;
      window-size = mkTuple [ 484 465 ];
    };

    "org/gnome/shell/extensions/gsconnect/preferences" = {
      window-maximized = false;
      window-size = mkTuple [ 734 465 ];
    };

    "org/gnome/shell/extensions/mediacontrols" = {
      backlist-apps = [ "chrome" "youtube" ];
      extension-position = "center";
      mouse-actions = [ "toggle_play" "toggle_menu" "none" "none" "none" "none" "none" "none" ];
      seperator-chars = [ "|" "|" ];
      track-label = [ "track" "-" "artist" ];
    };

    "org/gnome/shell/extensions/pop-cosmic" = {
      show-applications-button = false;
      show-workspaces-button = false;
    };

    "org/gnome/shell/extensions/pop-shell" = {
      active-hint = true;
      gap-inner = mkUint32 2;
      gap-outer = mkUint32 2;
      show-title = false;
      tile-by-default = true;
    };

    "org/gnome/shell/extensions/sound-output-device-chooser" = {
      expand-volume-menu = true;
      icon-theme = "monochrome";
      integrate-with-slider = false;
      omit-device-origins = false;
      ports-settings = ''
        {"version":3,"ports":[{"human_name":"Digital Output (S/PDIF)","name":"iec958-stereo-output","display_option":2,"card_name":"alsa_card.usb-C-Media_Electronics_Inc._USB_PnP_Sound_Device-00","card_description":"CM108 Audio Controller","display_name":"Digital Output (S/PDIF) - CM108 Audio Controller"},{"human_name":"Digital Output (S/PDIF)","name":"iec958-stereo-output","display_option":2,"card_name":"alsa_card.usb-Generic_HP_Z40c_G3_USB_Audio-00","card_description":"HP Z40c G3 USB Audio","display_name":"Digital Output (S/PDIF) - HP Z40c G3 USB Audio"},{"human_name":"Digital Output (S/PDIF)","name":"iec958-stereo-output","display_option":2,"card_name":"alsa_card.usb-KTMicro_KT_USB_Audio_2021-06-07-0000-0000-0000--00","card_description":"KT USB Audio","display_name":"Digital Output (S/PDIF) - KT USB Audio"},{"human_name":"HDMI / DisplayPort 1 Output","name":"[Out] HDMI1","display_option":2,"card_name":"alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic","card_description":"sof-hda-dsp","display_name":"HDMI / DisplayPort 1 Output - sof-hda-dsp"},{"human_name":"HDMI / DisplayPort 2 Output","name":"[Out] HDMI2","display_option":2,"card_name":"alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic","card_description":"sof-hda-dsp","display_name":"HDMI / DisplayPort 2 Output - sof-hda-dsp"},{"human_name":"HDMI / DisplayPort 3 Output","name":"[Out] HDMI3","display_option":2,"card_name":"alsa_card.pci-0000_00_1f.3-platform-skl_hda_dsp_generic","card_description":"sof-hda-dsp","display_name":"HDMI / DisplayPort 3 Output - sof-hda-dsp"},{"human_name":"Speakers","name":"analog-output-speaker","display_option":2,"card_name":"alsa_card.usb-C-Media_Electronics_Inc._USB_PnP_Sound_Device-00","card_description":"CM108 Audio Controller","display_name":"Speakers - CM108 Audio Controller"},{"human_name":"Digital Input (S/PDIF)","name":"iec958-stereo-input","display_option":2,"card_name":"alsa_card.usb-Generic_HP_Z40c_G3_USB_Audio-00","card_description":"HP Z40c G3 USB Audio","display_name":"Digital Input (S/PDIF) - HP Z40c G3 USB Audio"}]}
      '';
    };

    "org/gnome/shell/extensions/space-bar/behavior" = {
      smart-workspace-names = true;
    };

    "org/gnome/shell/extensions/space-bar/shortcuts" = {
      enable-move-to-workspace-shortcuts = false;
    };

    "org/gnome/shell/extensions/space-bar/state" = {
      workspace-names-map = ''
        {"jetbrains-rider":["2","w"],"Google-chrome":["1","2","3","~"],"Spotify":["2"],"Org.gnome.Nautilus":["ssss"],"Slack":["w","qq"],"Virt-manager":["wwjkj"],"Gnome-terminal":["2123","qqq"],"1Password":["2123"],"Soffice":["qqq"],"jetbrains-datagrip":["qqq"],"obsidian":["qqq"],"Alacritty":["3"],"Code":["qq"]}
      '';
    };

    "org/gnome/system/location" = {
      enabled = false;
    };

    "org/gnome/terminal/legacy/profiles:/:b1dcc9dd-5262-4d8d-a863-c897e6d979b9" = {
      background-transparency-percent = 16;
      font = "FiraCode Nerd Font 12";
      use-theme-colors = false;
      use-theme-transparency = false;
      use-transparent-background = true;
    };

    "org/gtk/gtk4/settings/file-chooser" = {
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = false;
      show-type-column = true;
      sidebar-width = 162;
      sort-column = "modified";
      sort-directories-first = false;
      sort-order = "descending";
      type-format = "category";
      window-size = mkTuple [ 1200 1052 ];
    };

    "org/gtk/settings/color-chooser" = {
      selected-color = mkTuple [ true 1.0 1.0 1.0 1.0 ];
    };

    "org/gtk/settings/file-chooser" = {
      clock-format = "24h";
      date-format = "regular";
      location-mode = "path-bar";
      show-hidden = false;
      show-size-column = true;
      show-type-column = true;
      sidebar-width = 262;
      sort-column = "size";
      sort-directories-first = true;
      sort-order = "descending";
      type-format = "category";
      window-position = mkTuple [ 1216 596 ];
      window-size = mkTuple [ 1407 953 ];
    };

    "org/virt-manager/virt-manager" = {
      manager-window-height = 1392;
      manager-window-width = 566;
    };

    "org/virt-manager/virt-manager/confirm" = {
      delete-storage = true;
      forcepoweroff = true;
      unapplied-dev = true;
    };

    "org/virt-manager/virt-manager/connections" = {
      autoconnect = [ "qemu:///system" ];
      uris = [ "qemu:///system" ];
    };

    "org/virt-manager/virt-manager/conns/qemu:system" = {
      window-size = mkTuple [ 1270 2112 ];
    };

    "org/virt-manager/virt-manager/details" = {
      show-toolbar = true;
    };

    "org/virt-manager/virt-manager/paths" = {
      image-default = "/home/klowdo/Vms";
      media-default = "/home/klowdo/Downloads";
    };

    "org/virt-manager/virt-manager/urls" = {
      isos = [ "/home/klowdo/Vms/archlinux.qcow2" "/home/klowdo/Downloads/Arch-Linux-x86_64-basic-20240215.214390.qcow2" "/home/klowdo/Downloads/pop-os_22.04_amd64_intel_37.iso" "/home/klowdo/Downloads/nixos-gnome-23.11.2596.c1be43e8e837-x86_64-linux.iso" "/home/klowdo/Downloads/Parrot-htb-5.3_amd64.iso" "/home/klowdo/Downloads/manjaro-sway-22.1.2-231001-linux61.iso" "/home/klowdo/Downloads/ubuntu-23.04-desktop-amd64.iso" "/home/klowdo/Downloads/debian-12.1.0-amd64-netinst.iso" "/home/klowdo/Documents/arcolinuxb-hyprland-v23.03.01-x86_64.iso" "/home/klowdo/Documents/archcraft-2023.01.20-x86_64.iso" ];
      urls = [ "https://iso.pop-os.org/22.04/amd64/intel/37/pop-os_22.04_amd64_intel_37.iso" ];
    };

    "org/virt-manager/virt-manager/vmlist-fields" = {
      disk-usage = false;
      network-traffic = false;
    };

    "org/virt-manager/virt-manager/vms/073ed75485d74f18a45dec0c6871f59d" = {
      autoconnect = 1;
      scaling = 1;
      vm-window-size = mkTuple [ 1270 1052 ];
    };

    "org/virt-manager/virt-manager/vms/1789b6a177ab4a7cae079eadd25fd8be" = {
      autoconnect = 1;
      scaling = 1;
      vm-window-size = mkTuple [ 2548 2112 ];
    };

    "org/virt-manager/virt-manager/vms/2271bdb84bcf466db9d9de24b4af5b6f" = {
      autoconnect = 1;
      scaling = 1;
      vm-window-size = mkTuple [ 1270 1052 ];
    };

    "org/virt-manager/virt-manager/vms/25e6e760e6ba4f04934751ef801724b7" = {
      autoconnect = 1;
      scaling = 1;
      vm-window-size = mkTuple [ 1140 692 ];
    };

    "org/virt-manager/virt-manager/vms/277061c36cae4b78a24cd36cb000094d" = {
      autoconnect = 1;
      scaling = 1;
      vm-window-size = mkTuple [ 1270 1052 ];
    };

    "org/virt-manager/virt-manager/vms/2820c5b48f3d41d0a1f840483b03c14c" = {
      autoconnect = 1;
      scaling = 1;
      vm-window-size = mkTuple [ 566 692 ];
    };

    "org/virt-manager/virt-manager/vms/36ddaa0ee1fb476b90a13395bb901658" = {
      autoconnect = 1;
      scaling = 1;
      vm-window-size = mkTuple [ 948 572 ];
    };

    "org/virt-manager/virt-manager/vms/4a9c8bbbd7474ccea6f8df88a1a4a295" = {
      autoconnect = 1;
      scaling = 1;
      vm-window-size = mkTuple [ 2548 1052 ];
    };

    "org/virt-manager/virt-manager/vms/77542286771b4b7297441e2374a5edfd" = {
      autoconnect = 1;
      scaling = 1;
      vm-window-size = mkTuple [ 948 572 ];
    };

    "org/virt-manager/virt-manager/vms/8ba926c9b5074fa8a0aa8ec3919471a1" = {
      autoconnect = 1;
      scaling = 1;
      vm-window-size = mkTuple [ 2548 1052 ];
    };

    "org/virt-manager/virt-manager/vms/bed6c3af87e04db39e9b732e7c2ea689" = {
      autoconnect = 1;
      scaling = 1;
      vm-window-size = mkTuple [ 1920 1168 ];
    };

    "org/virt-manager/virt-manager/vms/c2ad65ce4cdd4e2ca497c580d73949a4" = {
      autoconnect = 1;
      scaling = 1;
      vm-window-size = mkTuple [ 948 572 ];
    };

    "org/virt-manager/virt-manager/vms/dcbba66847384d3badf1f34086425e3d" = {
      autoconnect = 1;
      scaling = 1;
      vm-window-size = mkTuple [ 1270 1052 ];
    };

    "org/virt-manager/virt-manager/vms/e087627aa3664e72ab146a2512c473e8" = {
      autoconnect = 1;
      scaling = 1;
      vm-window-size = mkTuple [ 631 1052 ];
    };

    "org/virt-manager/virt-manager/vms/f78aa234aaca4d61b1fba22b5bfb8de1" = {
      autoconnect = 1;
      scaling = 1;
      vm-window-size = mkTuple [ 2548 2112 ];
    };

    "org/virt-manager/virt-manager/vms/f9493a3f039a4251934ab1b113e5a815" = {
      autoconnect = 1;
      scaling = 1;
      vm-window-size = mkTuple [ 631 1052 ];
    };

  };
}
