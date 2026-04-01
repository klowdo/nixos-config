---
name: caelestia-shell
description: Use when configuring, troubleshooting, or customizing Caelestia Shell for Hyprland. Triggers on bar, dashboard, launcher, notifications, lock screen, session menu, OSD, sidebar, control center, appearance, shell.json, or Quickshell desktop components.
---

# Caelestia Shell Reference

Quickshell-based desktop shell for Hyprland. User config: `~/.config/caelestia/shell.json`. In this dotfiles repo: `home/features/desktop/bar/caelestia.nix` under `programs.caelestia.settings`.

## Config Module Quick Reference

| Key | Controls | Key Properties |
|-----|----------|----------------|
| `appearance` | Fonts, rounding, spacing, transparency, animation | `font.family.{sans,mono,material,clock}`, `font.size.scale`, `rounding.scale`, `spacing.scale`, `padding.scale`, `transparency.{enabled,base,layers}`, `anim.durations.scale` |
| `bar` | Top bar layout and widgets | `entries[]`, `persistent`, `showOnHover`, `dragThreshold`, `scrollActions.{workspaces,volume,brightness}`, `popouts.{activeWindow,tray,statusIcons}`, `workspaces.*`, `activeWindow.*`, `tray.*`, `status.*`, `clock.*`, `sizes.*`, `excludedScreens[]` |
| `background` | Wallpaper, clock overlay, audio visualiser | `enabled`, `wallpaperEnabled`, `desktopClock.{enabled,scale,position,invertColors,background,shadow}`, `visualiser.{enabled,autoHide,blur,rounding,spacing}` |
| `border` | Window border decoration | `thickness`, `rounding` |
| `controlCenter` | Control center panel | `sizes.{heightMult,ratio}` |
| `dashboard` | System dashboard panel | `enabled`, `showOnHover`, `mediaUpdateInterval`, `resourceUpdateInterval`, `dragThreshold`, `showDashboard`, `showMedia`, `showPerformance`, `showWeather`, `performance.{showBattery,showGpu,showCpu,showMemory,showStorage,showNetwork}` |
| `launcher` | App launcher / command palette | `enabled`, `showOnHover`, `maxShown`, `maxWallpapers`, `specialPrefix`, `actionPrefix`, `enableDangerousActions`, `dragThreshold`, `vimKeybinds`, `favouriteApps[]`, `hiddenApps[]`, `useFuzzy.{apps,actions,schemes,variants,wallpapers}`, `actions[]` |
| `lock` | Lock screen | `recolourLogo`, `enableFprint`, `maxFprintTries`, `hideNotifs`, `sizes.{heightMult,ratio,centerWidth}` |
| `notifs` | Notifications | `expire`, `fullscreen`, `defaultExpireTimeout`, `clearThreshold`, `expandThreshold`, `actionOnClick`, `groupPreviewNum`, `openExpanded` |
| `osd` | On-screen display (volume/brightness) | `enabled`, `hideDelay`, `enableBrightness`, `enableMicrophone` |
| `session` | Session/power menu | `enabled`, `dragThreshold`, `vimKeybinds`, `icons.{logout,shutdown,hibernate,reboot}`, `commands.{logout,shutdown,hibernate,reboot}` |
| `sidebar` | Side panel | `enabled`, `dragThreshold` |
| `winfo` | Window info panel | `sizes.{heightMult,detailsWidth}` |
| `services` | System services | `weatherLocation`, `useFahrenheit`, `useFahrenheitPerformance`, `useTwelveHourClock`, `gpuType`, `visualiserBars`, `audioIncrement`, `brightnessIncrement`, `maxVolume`, `smartScheme`, `defaultPlayer`, `playerAliases[]`, `showLyrics`, `lyricsBackend` |
| `utilities` | Toasts, VPN, quick toggles | `enabled`, `maxToasts`, `toasts.*`, `vpn.{enabled,provider[]}`, `quickToggles[]` |
| `general` | Global settings | `logo`, `excludedScreens[]`, `apps.{terminal,audio,playback,explorer}`, `idle.{lockBeforeSleep,inhibitWhenAudio,timeouts[]}`, `battery.{warnLevels[],criticalLevel}` |
| `paths` | Asset paths | `wallpaperDir`, `lyricsDir`, `sessionGif`, `mediaGif`, `noNotifsPic`, `lockNoNotifsPic` |

## Bar Entries

`bar.entries` array controls widget order. Each: `{ id: string, enabled: bool }`.

IDs: `logo`, `workspaces`, `activeWindow`, `spacer`, `tray`, `clock`, `statusIcons`, `power`

## Quick Toggles

`utilities.quickToggles` array. Each: `{ id: string, enabled: bool }`.

IDs: `wifi`, `bluetooth`, `mic`, `settings`, `gameMode`, `dnd`, `vpn`

## Launcher Actions

`launcher.actions` array. Built-in IDs: `Calculator`, `Scheme`, `Wallpaper`, `Variant`, `Transparency`, `Random`, `Light`, `Dark`, `Shutdown`, `Reboot`, `Logout`, `Lock`, `Sleep`, `Settings`

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
- **Wallpaper:** pulled from `config.stylix.image` via `xdg.stateFile."caelestia/wallpaper/path-temp.txt"`

Custom options under `features.desktop.bar.caelestia`:
- `enable` / `useLauncher` / `useLockScreen` / `useSessionMenu` / `useNotifications` / `settings`

## Upstream Config Reference

For full QML defaults and all sub-properties, fetch:
https://gitingest.com/caelestia-dots/shell/tree/main/config
