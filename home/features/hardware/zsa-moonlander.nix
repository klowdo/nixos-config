{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.hardware.zsa-moonlander;

  # ZSA Keymapp wrapper for better integration
  keymapp-launcher = pkgs.writeShellScriptBin "keymapp-launcher" ''
    # Ensure proper environment for GUI application
    export XDG_CURRENT_DESKTOP=hyprland
    export QT_QPA_PLATFORM=wayland
    export GDK_BACKEND=wayland
    
    # Check if Keymapp is already running
    if pgrep -x "keymapp" > /dev/null; then
      notify-send "Keymapp" "Already running" -t 2000
      # Bring existing window to front
      hyprctl dispatch focuswindow "class:keymapp"
    else
      notify-send "Keymapp" "Starting ZSA Keymapp..." -t 2000
      ${pkgs.keymapp}/bin/keymapp
    fi
  '';

  # QMK CLI wrapper for Moonlander operations
  moonlander-flash = pkgs.writeShellScriptBin "moonlander-flash" ''
    #!/usr/bin/env bash
    set -euo pipefail

    FIRMWARE_DIR="$HOME/.config/moonlander-firmware"
    mkdir -p "$FIRMWARE_DIR"

    show_help() {
      echo "Moonlander Firmware Flash Utility"
      echo ""
      echo "Usage: moonlander-flash [OPTIONS] [FIRMWARE_FILE]"
      echo ""
      echo "Options:"
      echo "  -h, --help     Show this help message"
      echo "  -l, --list     List available firmware files"
      echo "  -d, --download Download latest firmware from Oryx"
      echo "  -c, --compile  Compile local keymap"
      echo ""
      echo "If no firmware file is provided, will use interactive selection"
    }

    list_firmware() {
      echo "Available firmware files in $FIRMWARE_DIR:"
      if ls "$FIRMWARE_DIR"/*.bin 2>/dev/null | head -10; then
        echo ""
      else
        echo "No firmware files found."
        echo "You can:"
        echo "  1. Download from Oryx (moonlander-flash --download)"
        echo "  2. Place .bin files in $FIRMWARE_DIR"
        echo "  3. Use ZSA Keymapp to download/compile firmware"
      fi
    }

    download_firmware() {
      echo "Opening Oryx configurator in browser..."
      echo "Please compile and download your firmware from:"
      echo "https://configure.zsa.io/moonlander"
      ${pkgs.xdg-utils}/bin/xdg-open "https://configure.zsa.io/moonlander" || true
      
      echo ""
      echo "After downloading, move the .bin file to: $FIRMWARE_DIR"
    }

    flash_firmware() {
      local firmware_file="$1"
      
      if [[ ! -f "$firmware_file" ]]; then
        echo "Error: Firmware file not found: $firmware_file"
        exit 1
      fi

      echo "Flashing firmware: $firmware_file"
      echo "Please put your Moonlander in flash mode:"
      echo "  1. Hold the reset button"
      echo "  2. Press and release the Fn key"
      echo "  3. Release the reset button"
      echo ""
      echo "Press Enter when ready..."
      read -r

      if ${pkgs.qmk}/bin/qmk flash "$firmware_file"; then
        notify-send "Moonlander" "Firmware flashed successfully!" -t 3000
        echo "Firmware flashed successfully!"
      else
        notify-send "Moonlander" "Firmware flash failed!" -t 3000
        echo "Firmware flash failed!"
        exit 1
      fi
    }

    select_firmware() {
      local firmware_files
      firmware_files=($(find "$FIRMWARE_DIR" -name "*.bin" 2>/dev/null | sort -r))
      
      if [[ ''${#firmware_files[@]} -eq 0 ]]; then
        echo "No firmware files found in $FIRMWARE_DIR"
        echo "Use --download to get firmware from Oryx or place .bin files manually"
        exit 1
      fi

      echo "Select firmware file:"
      select firmware in "''${firmware_files[@]##*/}" "Cancel"; do
        case $firmware in
          "Cancel")
            echo "Cancelled."
            exit 0
            ;;
          "")
            echo "Invalid selection. Please try again."
            ;;
          *)
            flash_firmware "$FIRMWARE_DIR/$firmware"
            break
            ;;
        esac
      done
    }

    # Parse arguments
    case "''${1:-}" in
      -h|--help)
        show_help
        exit 0
        ;;
      -l|--list)
        list_firmware
        exit 0
        ;;
      -d|--download)
        download_firmware
        exit 0
        ;;
      -c|--compile)
        echo "Compiling requires a local QMK setup and keymap source."
        echo "For easier firmware management, consider using ZSA Keymapp or Oryx."
        exit 1
        ;;
      -*)
        echo "Unknown option: $1"
        show_help
        exit 1
        ;;
      "")
        # No arguments - interactive mode
        select_firmware
        ;;
      *)
        # Firmware file provided
        flash_firmware "$1"
        ;;
    esac
  '';

  # Moonlander configuration script
  moonlander-config = pkgs.writeShellScriptBin "moonlander-config" ''
    #!/usr/bin/env bash
    
    CONFIG_DIR="$HOME/.config/moonlander"
    mkdir -p "$CONFIG_DIR"

    show_menu() {
      echo "Moonlander Configuration Utility"
      echo ""
      echo "1. Open Keymapp (ZSA Official Tool)"
      echo "2. Open Via (Open Source Alternative)"
      echo "3. Open Vial (Open Source Alternative)"
      echo "4. Flash Firmware"
      echo "5. Open Oryx Configurator"
      echo "6. Show Device Info"
      echo "7. Exit"
      echo ""
      echo -n "Select option (1-7): "
    }

    show_device_info() {
      echo "Moonlander Device Information:"
      echo "============================="
      
      # Check if device is connected
      if lsusb | grep -i "ZSA Technology Labs"; then
        echo "✓ Moonlander detected via USB"
        lsusb | grep -i "ZSA Technology Labs" | head -1
        echo ""
      else
        echo "✗ Moonlander not detected"
        echo "  Make sure your keyboard is connected"
        echo ""
      fi

      # Check kernel recognition
      echo "Input devices:"
      ls /dev/input/by-id/ 2>/dev/null | grep -i moonlander || echo "  No moonlander devices found in /dev/input/by-id/"
      echo ""

      # Check udev rules
      if [[ -f /etc/udev/rules.d/50-qmk.rules ]] || [[ -f /etc/udev/rules.d/50-zsa.rules ]]; then
        echo "✓ QMK/ZSA udev rules installed"
      else
        echo "✗ QMK/ZSA udev rules may be missing"
      fi
    }

    while true; do
      show_menu
      read -r choice
      
      case $choice in
        1)
          echo "Starting Keymapp..."
          keymapp-launcher &
          ;;
        2)
          echo "Starting Via..."
          ${pkgs.via}/bin/via &
          ;;
        3)
          echo "Starting Vial..."
          ${pkgs.vial}/bin/vial &
          ;;
        4)
          moonlander-flash
          ;;
        5)
          echo "Opening Oryx configurator..."
          ${pkgs.xdg-utils}/bin/xdg-open "https://configure.zsa.io/moonlander"
          ;;
        6)
          show_device_info
          echo ""
          echo "Press Enter to continue..."
          read -r
          ;;
        7)
          echo "Goodbye!"
          exit 0
          ;;
        *)
          echo "Invalid option. Please select 1-7."
          sleep 1
          ;;
      esac
    done
  '';
in {
  options.features.hardware.zsa-moonlander = {
    enable = mkEnableOption "ZSA Moonlander keyboard support and configuration tools";
    
    enableKeymapp = mkOption {
      type = types.bool;
      default = true;
      description = "Enable ZSA Keymapp (official configuration tool)";
    };
    
    enableQmkTools = mkOption {
      type = types.bool;
      default = true;
      description = "Enable QMK CLI tools for firmware management";
    };
    
    enableDesktopIntegration = mkOption {
      type = types.bool;
      default = true;
      description = "Add desktop entries and key bindings";
    };
  };

  config = mkIf cfg.enable {
    # Install configuration packages
    home.packages = with pkgs; [
      moonlander-config
      moonlander-flash
      keymapp-launcher
    ] ++ optional cfg.enableKeymapp keymapp
      ++ optional cfg.enableQmkTools qmk;

    # Desktop integration
    xdg.desktopEntries = mkIf cfg.enableDesktopIntegration {
      moonlander-config = {
        name = "Moonlander Config";
        comment = "Configure ZSA Moonlander keyboard";
        exec = "${moonlander-config}/bin/moonlander-config";
        icon = "input-keyboard";
        categories = ["Utility" "System" "HardwareSettings"];
      };
      
      keymapp = mkIf cfg.enableKeymapp {
        name = "Keymapp";
        comment = "ZSA Keyboard Configuration";
        exec = "${keymapp-launcher}/bin/keymapp-launcher";
        icon = "input-keyboard";
        categories = ["Utility" "System" "HardwareSettings"];
      };
    };

    # Shell aliases for convenience
    home.shellAliases = {
      moonlander = "moonlander-config";
      keymapp = "keymapp-launcher";
      qmk-flash = "moonlander-flash";
    };

    # Environment variables for QMK
    home.sessionVariables = mkIf cfg.enableQmkTools {
      QMK_HOME = "$HOME/.config/qmk";
    };

    # Ensure config directories exist
    home.activation = {
      moonlanderSetup = lib.hm.dag.entryAfter ["writeBoundary"] ''
        mkdir -p $HOME/.config/moonlander
        mkdir -p $HOME/.config/moonlander-firmware
        mkdir -p $HOME/.config/qmk
      '';
    };
  };
}