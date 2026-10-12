# Dendritic migration design

Date: 2026-10-12. Branch: `dendritic`.

## Goal

Restructure the flake into the Dendritic pattern: every file under `modules/`
is a flake-parts module, auto-imported by `import-tree`. Configuration is
expressed as named *aspects* (`flake.modules.nixos.<name>`,
`flake.modules.homeManager.<name>`). A host enables an aspect by importing it.
The `features.*.enable` / `extraServices.*.enable` option layer is removed.

Behaviour must be preserved: `nixosConfigurations.{dellicious,virt-nix,iso,iso-minimal}`
and `homeConfigurations."klowdo@{dellicious,virt-nix}"` must evaluate to the
same effective configuration as on `main`. Home Manager stays both standalone
and integrated in NixOS (`home-manager.users.klowdo`).

## Target layout

```
flake.nix                      inputs + mkFlake { inherit inputs; } (import-tree ./modules)
modules/
  flake/                       flake-level plumbing (systems, pkgs, overlays, packages, checks, devshells, formatter, lib)
  nixos/<aspect>.nix           flake.modules.nixos.<aspect>       (from hosts/common/**)
  home/<category>/<aspect>.nix flake.modules.homeManager.<aspect> (from home/features/**, home/common/**)
  options/                     reusable option modules (from modules/nixos, modules/home-manager), exported as aspects
  users/klowdo/                flake.modules.nixos.user-klowdo, flake.modules.homeManager.klowdo (from hosts/common/users, home/klowdo/home.nix, dotfiles)
  hosts/<host>/                flake.nixosConfigurations.<host>, flake.homeConfigurations."klowdo@<host>", hardware/disko files
overlays/ pkgs/ lib/ devshells/   unchanged plain-nix directories, referenced from modules/flake/*
```

Old `hosts/`, `home/`, `modules/nixos`, `modules/home-manager` are deleted once
the hosts build.

## Conventions

1. Every `.nix` file under `modules/` is a flake-parts module:
   `{inputs, config, lib, ...}: { ... }`. `config` here is the *flake-parts*
   config. Files or directories whose name starts with `_` are skipped by
   import-tree (use for helper files that are not modules).
2. One aspect per file. Aspect name = file basename without `.nix`
   (`modules/nixos/docker.nix` -> `flake.modules.nixos.docker`). Names must be
   unique within their class. If two files would collide, prefix the less
   generic one with its category (`dev-tools`, `desktop-bluetooth`).
3. Inside an aspect the module is an ordinary NixOS / HM module:
   ```nix
   {inputs, ...}: {
     flake.modules.nixos.docker = {config, pkgs, lib, ...}: { ... };
   }
   ```
   `inputs` comes from the closure, never from `specialArgs`. Where the old
   code used `outputs.<x>` use `config.flake.<x>` from the outer closure
   (bind it in a `let` to avoid shadowing by the inner `config`).
4. Enable flags are gone. `options.features.x.enable` / `options.extraServices.x.enable`
   and the surrounding `mkIf cfg.enable` are removed; the body becomes the
   aspect's config. Importing the aspect enables it.
5. Non-boolean options (e.g. `docker.usePasta`, `wireguard-unifi.address`,
   `junie.apiKeySecret`, `kubernetes.kubeconfigSecret`, `auto-shell.*`,
   `music-assistant.url`, `defaults.launcher/browser/terminal`, `caelestia.useSessionMenu`,
   `claude-code.enableNotifications`, `vicinae.enableHyprlandSupport`) are kept
   as options under the same path minus `.enable`, declared in the aspect.
   Hosts set them. A value an aspect previously read from another aspect's
   `enable` flag (e.g. `config.features.desktop.hyprland.enable`) becomes an
   explicit option with a default, or the dependency is imported.
6. An aspect that depends on another aspect imports it:
   `imports = [config.flake.modules.nixos.audio];` (outer `config`).
   Importing the same aspect twice is fine; NixOS deduplicates by path only,
   so a shared aspect must be bound once in a `let` or referenced via
   `config.flake.modules.*`, never re-created inline.
7. Hosts compose aspects by name:
   ```nix
   {inputs, config, ...}: {
     flake.nixosConfigurations.dellicious = inputs.nixpkgs.lib.nixosSystem {
       modules = with config.flake.modules.nixos; [ base user-klowdo docker ... ];
     };
   }
   ```
   A host-specific HM composition is an aspect too
   (`flake.modules.homeManager.host-dellicious`), used by both the standalone
   `homeConfigurations` entry and `home-manager.users.klowdo`.
8. `pkgs`: NixOS hosts set `nixpkgs.overlays = builtins.attrValues flake.overlays`
   and `allowUnfree` in the `base` aspect. Standalone HM uses the perSystem
   `pkgs` (with overlays) from `modules/flake/pkgs.nix`. Integrated HM keeps
   `useGlobalPkgs = false` so the HM `base` aspect can set overlays itself.
9. Style: alejandra formatting, deadnix clean (no unused lambda args), no
   comments inside functions. Keep existing top-of-file comments that document
   *why* something exists; drop stale ones.
10. Package paths: aspects under `modules/` reference assets with relative
    paths that are correct for the *new* location (e.g. `../../../lib/felix_evolve.jpg`).

## Verification bar

- `nix flake check --no-build`
- `nix eval .#nixosConfigurations.<host>.config.system.build.toplevel.drvPath` for all four hosts
- `nix eval .#homeConfigurations."klowdo@dellicious".activationPackage.drvPath` and virt-nix
- `nix build .#nixosConfigurations.dellicious.config.system.build.toplevel`
- Diff `nix eval --json .#nixosConfigurations.dellicious.config.environment.systemPackages`
  (names) and HM `home.packages` names against `main` worktree at `../..`.
