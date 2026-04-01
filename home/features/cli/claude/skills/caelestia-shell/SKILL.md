---
name: caelestia-shell
description: Use when configuring, troubleshooting, or customizing Caelestia Shell for Hyprland. Triggers on bar, dashboard, launcher, notifications, lock screen, session menu, OSD, sidebar, control center, appearance, shell.json, or Quickshell desktop components.
---

# Caelestia Shell Reference

Quickshell-based desktop shell for Hyprland. User config: `~/.config/caelestia/shell.json`. In this dotfiles repo: `home/features/desktop/bar/caelestia.nix` under `programs.caelestia.settings`.

## Config Module Quick Reference

| Key | Controls | Key Properties |
|-----|----------|----------------|
| `appearance` | Fonts, rounding, spacing, transparency, animation | `font.family.{sans,mono,material,clock}`, `font.size.scale`, `rounding.scale`, `transparency.{enabled,base,layers}`, `anim.durations.scale` |
| `bar` | Top bar layout and widgets | `entries[]`, `persistent`, `workspaces.{shown,perMonitorWorkspaces}`, `status.{showAudio,showBattery,...}`, `clock.{showDate,showIcon}`, `tray.{recolour,compact,hiddenIcons}` |
| `background` | Wallpaper, clock overlay, audio visualiser | `wallpaperEnabled`, `desktopClock.{enabled,scale,position}`, `visualiser.{enabled,autoHide,blur}` |
| `border` | Window border decoration | `thickness`, `rounding` |
| `dashboard` | System dashboard panel | `enabled`, `showOnHover`, `performance.{showBattery,showGpu,showCpu,showMemory,showStorage,showNetwork}` |
| `launcher` | App launcher / command palette | `maxShown`, `vimKeybinds`, `favouriteApps[]`, `hiddenApps[]`, `specialPrefix`, `actionPrefix`, `actions[]` |
| `lock` | Lock screen | `recolourLogo`, `enableFprint`, `hideNotifs` |
| `notifs` | Notifications | `expire`, `fullscreen`, `defaultExpireTimeout`, `clearThreshold`, `groupPreviewNum` |
| `osd` | On-screen display (volume/brightness) | `enabled`, `hideDelay`, `enableBrightness`, `enableMicrophone` |
| `session` | Session/power menu | `enabled`, `vimKeybinds`, `commands.{logout,shutdown,hibernate,reboot}` |
| `sidebar` | Side panel | `enabled`, `dragThreshold` |
| `services` | System services | `gpuType`, `audioIncrement`, `brightnessIncrement`, `maxVolume`, `weatherLocation`, `defaultPlayer`, `showLyrics` |
| `utilities` | Toasts, VPN, quick toggles | `maxToasts`, `toasts.{configLoaded,...}`, `vpn.{enabled,provider[]}`, `quickToggles[]` |
| `general` | Global settings | `apps.{terminal,audio,explorer}`, `idle.{lockBeforeSleep,timeouts[]}`, `battery.{warnLevels[],criticalLevel}` |
| `paths` | Asset directories | `wallpaperDir`, `lyricsDir`, `sessionGif`, `mediaGif` |

## Bar Entries

`bar.entries` array controls widget order. Each: `{ id: string, enabled: bool }`.

IDs: `logo`, `workspaces`, `activeWindow`, `spacer`, `tray`, `clock`, `statusIcons`, `power`

## Quick Toggles

`utilities.quickToggles` array. Each: `{ id: string, enabled: bool }`.

IDs: `wifi`, `bluetooth`, `mic`, `settings`, `gameMode`, `dnd`, `vpn`

## CLI Commands

```
caelestia shell -d                         # Start shell daemon
caelestia shell drawers toggle launcher    # Toggle app launcher
caelestia shell drawers toggle session     # Toggle session menu
caelestia shell drawers showall            # Show all panels
caelestia shell controlCenter open         # Open control center
caelestia shell notifs clear               # Clear notifications
caelestia shell notifs toggleDnd           # Toggle do-not-disturb
caelestia shell mpris playPause            # Media play/pause
caelestia shell mpris next|previous|stop   # Media controls
caelestia shell brightness set +5%         # Adjust brightness
caelestia shell lock lock                  # Lock screen
caelestia shell picker open|openFreeze|openClip  # Color picker
caelestia shell gameMode toggle            # Toggle game mode
caelestia shell idleInhibitor toggle       # Toggle idle inhibitor
```

## Nix Integration

- **Nix module:** `home/features/desktop/bar/caelestia.nix`
- **Flake input:** `inputs.caelestia-shell`
- **HM module:** `inputs.caelestia-shell.homeManagerModules.default`
- **Package:** `inputs.caelestia-shell.packages.${system}.with-cli`
- **Settings:** `programs.caelestia.settings` (Nix attrset rendered to shell.json)
- **CLI settings:** `programs.caelestia.cli.settings` (enableHypr, enableGtk, enableQt, enableSpicetify, enableBtop)
- **Color scheme:** Stylix base16 colors mapped to Material Design tokens in `stylixColors`
- **Wallpaper:** pulled from `config.stylix.image`

Custom options under `features.desktop.bar.caelestia`:
- `enable` / `useLauncher` / `useLockScreen` / `useSessionMenu` / `useNotifications` / `settings`

## Upstream Config Reference

For full QML defaults and all sub-properties, fetch:
https://gitingest.com/caelestia-dots/shell/tree/main/config
