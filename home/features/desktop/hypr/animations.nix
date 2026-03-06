{
  config,
  lib,
  pkgs,
  ...
}:
with lib; let
  cfg = config.features.desktop.hyprland;

  animations = {
    classic = {
      enabled = true;
      bezier = ["myBezier, 0.05, 0.9, 0.1, 1.05"];
      animation = [
        "windows, 1, 7, myBezier"
        "windowsOut, 1, 7, default, popin 80%"
        "border, 1, 10, default"
        "borderangle, 1, 8, default"
        "fade, 1, 7, default"
        "workspaces, 1, 6, default"
        "specialWorkspace, 1, 6, default, slidevert"
      ];
    };

    fast = {
      enabled = true;
      bezier = [
        "md3_decel, 0.2, 0, 0, 1"
        "crazyshot, 0.1, 1.5, 0.76, 0.92"
      ];
      animation = [
        "windows, 1, 4, md3_decel, popin 60%"
        "border, 1, 10, default"
        "fade, 1, 2.5, md3_decel"
        "workspaces, 1, 3.5, crazyshot, slide"
        "specialWorkspace, 1, 3, md3_decel, slidevert"
      ];
    };

    dynamic = {
      enabled = true;
      bezier = [
        "wind, 0.05, 0.9, 0.1, 1.05"
        "winIn, 0.1, 1.1, 0.1, 1.1"
        "winOut, 0.3, -0.3, 0, 1"
        "liner, 1, 1, 1, 1"
      ];
      animation = [
        "windows, 1, 6, wind, slide"
        "windowsIn, 1, 6, winIn, slide"
        "windowsOut, 1, 5, winOut, slide"
        "windowsMove, 1, 5, wind, slide"
        "border, 1, 1, liner"
        "borderangle, 1, 30, liner, loop"
        "fade, 1, 10, default"
        "workspaces, 1, 5, wind"
        "specialWorkspace, 1, 5, wind, slidevert"
      ];
    };

    minimal = {
      enabled = true;
      bezier = [
        "wind, 0.05, 0.9, 0.1, 1.05"
        "winIn, 0.1, 1.1, 0.1, 1.1"
        "winOut, 0.3, -0.3, 0, 1"
        "liner, 1, 1, 1, 1"
      ];
      animation = [
        "windows, 1, 6, wind, slide"
        "windowsIn, 1, 6, winIn, slide"
        "windowsOut, 1, 5, winOut, slide"
        "windowsMove, 1, 5, wind, slide"
        "border, 1, 1, liner"
        "borderangle, 1, 30, liner, loop"
        "fade, 1, 10, default"
        "workspaces, 1, 5, wind"
      ];
    };

    high = {
      enabled = true;
      bezier = [
        "wind, 0.05, 0.9, 0.1, 1.05"
        "winIn, 0.1, 1.1, 0.1, 1.1"
        "winOut, 0.3, -0.3, 0, 1"
        "liner, 1, 1, 1, 1"
      ];
      animation = [
        "windows, 1, 6, wind, slide"
        "windowsIn, 1, 6, winIn, slide"
        "windowsOut, 1, 5, winOut, slide"
        "windowsMove, 1, 5, wind, slide"
        "border, 1, 1, liner"
        "borderangle, 1, 30, liner, loop"
        "fade, 1, 10, default"
        "workspaces, 1, 5, wind"
      ];
    };

    disable = {
      enabled = false;
      bezier = [];
      animation = [];
    };
  };

  animationConfigFiles =
    mapAttrs (
      name: preset:
        pkgs.writeText "animations-${name}.conf" ''
          animations {
            enabled=${
            if preset.enabled
            then "true"
            else "false"
          }
            ${concatMapStringsSep "\n  " (b: "bezier=${b}") preset.bezier}
            ${concatMapStringsSep "\n  " (a: "animation=${a}") preset.animation}
          }
        ''
    )
    animations;

  animationToggle = pkgs.writeShellScriptBin "hypr-animation-toggle" ''
    CONFIG_DIR="$HOME/.config/hypr/config.d"
    ANIMATIONS_DIR="${pkgs.linkFarm "hypr-animations" (
      mapAttrsToList (name: path: {
        name = "animations-${name}.conf";
        inherit path;
      })
      animationConfigFiles
    )}"
    CURRENT_LINK="$CONFIG_DIR/animations.conf"
    CURRENT_FILE="$CONFIG_DIR/current_animation"
    ANIMATIONS=(classic fast dynamic minimal high disable)

    if [ ! -f "$CURRENT_FILE" ]; then
      echo "classic" > "$CURRENT_FILE"
    fi

    CURRENT=$(cat "$CURRENT_FILE")

    for i in "''${!ANIMATIONS[@]}"; do
      if [ "''${ANIMATIONS[$i]}" = "$CURRENT" ]; then
        NEXT_INDEX=$(( (i + 1) % ''${#ANIMATIONS[@]} ))
        NEXT="''${ANIMATIONS[$NEXT_INDEX]}"
        echo "$NEXT" > "$CURRENT_FILE"

        ln -sf "$ANIMATIONS_DIR/animations-$NEXT.conf" "$CURRENT_LINK"

        hyprctl reload

        ${pkgs.libnotify}/bin/notify-send "Hyprland Animations" "Switched to ''${NEXT^}"
        exit 0
      fi
    done
  '';

  setupAnimationLink = pkgs.writeShellScriptBin "hypr-animation-setup" ''
    CONFIG_DIR="$HOME/.config/hypr/config.d"
    ANIMATIONS_DIR="${pkgs.linkFarm "hypr-animations" (
      mapAttrsToList (name: path: {
        name = "animations-${name}.conf";
        inherit path;
      })
      animationConfigFiles
    )}"
    CURRENT_LINK="$CONFIG_DIR/animations.conf"
    CURRENT_FILE="$CONFIG_DIR/current_animation"

    mkdir -p "$CONFIG_DIR"

    if [ ! -f "$CURRENT_FILE" ]; then
      echo "classic" > "$CURRENT_FILE"
    fi

    CURRENT=$(cat "$CURRENT_FILE")
    ln -sf "$ANIMATIONS_DIR/animations-$CURRENT.conf" "$CURRENT_LINK"
  '';
in {
  config = mkIf cfg.enable {
    home.packages = [animationToggle setupAnimationLink];

    home.activation.setupAnimations = lib.hm.dag.entryAfter ["writeBoundary"] ''
      ${setupAnimationLink}/bin/hypr-animation-setup
    '';

    wayland.windowManager.hyprland.settings.bind = [
      "$hyper, SEMICOLON, exec, ${animationToggle}/bin/hypr-animation-toggle"
    ];
  };
}
