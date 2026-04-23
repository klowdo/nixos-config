{
  inputs,
  pkgs,
  lib,
  self,
  ...
}: let
  system = pkgs.stdenv.hostPlatform.system;

  customPkgs = import ./pkgs {inherit pkgs;};

  overlayPkgs =
    lib.filterAttrs (_: lib.isDerivation)
    (lib.genAttrs
      (builtins.filter (n: pkgs ? ${n}) (builtins.attrNames (import ./overlays {inherit inputs;})))
      (name: pkgs.${name}));

  allPkgs = customPkgs // overlayPkgs;

  nixosHosts =
    lib.filterAttrs
    (_: cfg: cfg.pkgs.stdenv.hostPlatform.system == system)
    (self.nixosConfigurations or {});
in {
  packages = pkgs.linkFarmFromDrvs "all-packages" (lib.attrValues allPkgs);

  nixos-configs =
    pkgs.linkFarmFromDrvs "all-nixos-configs"
    (lib.mapAttrsToList (_: cfg: cfg.config.system.build.toplevel) nixosHosts);
}
