{
  inputs,
  config,
  lib,
  ...
}: let
  overlays = builtins.attrValues config.flake.overlays;
in {
  perSystem = {
    system,
    pkgs,
    ...
  }: {
    _module.args.pkgs = import inputs.nixpkgs {
      inherit system overlays;
      config.allowUnfree = true;
    };

    packages = let
      customPkgs = import ../../pkgs {inherit pkgs;};
      overlayPkgs =
        lib.genAttrs
        (builtins.filter (n: pkgs ? ${n} && lib.isDerivation pkgs.${n}) (builtins.attrNames config.flake.overlays))
        (name: pkgs.${name});
    in
      customPkgs // overlayPkgs;
  };
}
