# CI checks - builds all packages and NixOS configs (slow, CI only).
# Exposed as `ciChecks.<system>` so `nix flake check` stays fast.
{
  config,
  lib,
  withSystem,
  ...
}: {
  flake.ciChecks = lib.genAttrs config.systems (
    system:
      withSystem system ({pkgs, ...}: let
        nixosHosts =
          lib.filterAttrs
          (_: cfg: cfg.pkgs.stdenv.hostPlatform.system == system)
          (config.flake.nixosConfigurations or {});
      in {
        packages = pkgs.linkFarmFromDrvs "all-packages" (lib.attrValues config.flake.packages.${system});

        nixos-configs =
          pkgs.linkFarmFromDrvs "all-nixos-configs"
          (lib.mapAttrsToList (_: cfg: cfg.config.system.build.toplevel) nixosHosts);
      })
  );
}
