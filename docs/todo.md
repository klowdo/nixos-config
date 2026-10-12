# TODO

Found while migrating `home/features` to Dendritic aspects (2026-10-12).

## Module system

- [x] Give every `flake.modules.*` aspect a stable module `key` (done in `modules/flake/systems.nix`); importing an aspect from several places is now safe.
- [ ] Let `nh`, `email`, `git-repo-manager`, `junie` import the `option-*` aspect they use instead of relying on `base` to provide it.
- [ ] Move the remaining `features.<cat>.<name>.<opt>` knobs to `programs.<name>.*`-style paths: `auto-shell.*`, `junie.apiKeySecret`, `kubernetes.kubeconfigSecret`, `music-assistant.url`, `claude-code.enableNotifications`, `zsa-moonlander.enable*`, `syncthing.{guiAddress,tray}`.
- [ ] Split sops into a `secrets` aspect (only `sops.secrets` entries) and keep age/plugin setup in `sops`, so dependents import the smaller one.
- [ ] Drop the `options ? stylix` guards in `firefox` and `spicetify` once stylix is always imported.

## Stale or broken

- [ ] `datagrip` aspect references `pkgs.jetbrains-datagrip`, which does not exist (overlay line commented out). Delete the aspect or restore `overlays/jetbrains-datagrip.nix`.
- [ ] `password-store`: `services.gpg-agent.pinentryPackage` was renamed to `services.gpg-agent.pinentry.package`; also drop `xclip` (X11 only).
- [ ] `claudia` aspect is only `programs.claudia.enable = false`; remove it and `option-claudia`.
- [ ] Remove unreferenced `home/features/cli/docs.md` and `home/features/cli/claude-code-package-lock.json`.
- [ ] `zsh` aliases: `update = "sudo nixos-rebuild switch"` contradicts the `nh` workflow; `ndev`, `switch-nvidia`, `switch-default`, `reboot-nvidia` are dellicious-specific and belong in the host composition.
- [ ] `tmux`: `secureSocket = false` (WSL2 note) and the `tmux_version < 3.0` compat branch no longer apply.
- [ ] `sesh`: kixvim session has `':Telecope find_files'` (typo, should be `Telescope`).
- [ ] `nix` aspect installs both `nixfmt` and `nixpkgs-fmt` while the formatter is alejandra.

## Newer approaches to adopt

- [ ] `ssh`: keep the sops-backed `known_hosts.d` + `KnownHostsCommand` design (host keys stay hidden in secrets); only tidy the public github entries into `programs.ssh` and document why the command exists.
- [ ] `auto-shell`: generate `config.toml` with `pkgs.formats.toml {}` instead of string concatenation.
- [ ] Replace `home.activation` mkdir hooks (`email`, `neomutt`, `zsa-moonlander`) with `systemd.user.tmpfiles.rules` or let the programs create their directories.
- [ ] Use structured `wayland.windowManager.hyprland.settings`/`submaps` (as `steam-link` already does) instead of raw bind/windowrule strings in other aspects.
- [ ] Consider `services.flatpak.packages` (nix-flatpak) for Steam Link and Bambu Studio instead of custom AppImage wrappers.
