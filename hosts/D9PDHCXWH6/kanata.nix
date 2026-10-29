# Homerow mods via kanata, sharing the layout with dellicious.
# nix-darwin has no kanata module, so this wires up the Karabiner
# DriverKit virtual HID device that kanata needs on macOS.
{pkgs, ...}: let
  driver = pkgs.kanata.darwinDriver;
  parentAppDir = "/Applications/.Nix-Karabiner-DK";
  manager = "${parentAppDir}/.Karabiner-VirtualHIDDevice-Manager.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Manager";
  vhidDaemon = "${driver}/Library/Application Support/org.pqrs/Karabiner-DriverKit-VirtualHIDDevice/Applications/Karabiner-VirtualHIDDevice-Daemon.app/Contents/MacOS/Karabiner-VirtualHIDDevice-Daemon";

  # Only grab the built-in keyboard (leaves YubiKey OTP and external boards alone)
  kanataConfig = pkgs.writeText "kanata.kbd" ''
    (defcfg
      process-unmapped-keys yes
      concurrent-tap-hold yes
      macos-dev-names-include ("Apple Internal Keyboard / Trackpad"))

    ${builtins.readFile ../common/optional/kanata-homerow.kbd}
  '';
in {
  environment.systemPackages = [pkgs.kanata];

  # System extensions must live in /Applications and cannot be symlinks
  system.activationScripts.preActivation.text = ''
    rm -rf ${parentAppDir}
    mkdir -p ${parentAppDir}
    cp -r ${driver}/Applications/.Karabiner-VirtualHIDDevice-Manager.app ${parentAppDir}
  '';

  launchd.daemons = {
    karabiner-dk-activate = {
      # Blocks until the system extension is approved in System Settings
      command = "${manager} activate";
      serviceConfig.RunAtLoad = true;
    };

    karabiner-vhid-daemon = {
      command = "\"${vhidDaemon}\"";
      serviceConfig = {
        ProcessType = "Interactive";
        KeepAlive = true;
        RunAtLoad = true;
      };
    };

    kanata = {
      command = "${pkgs.kanata}/bin/kanata --cfg ${kanataConfig}";
      serviceConfig = {
        ProcessType = "Interactive";
        KeepAlive = true;
        RunAtLoad = true;
        StandardOutPath = "/var/log/kanata.log";
        StandardErrorPath = "/var/log/kanata.log";
      };
    };
  };
}
