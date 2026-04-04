{
  pkgs,
  inputs,
}: let
  zig-overlay = inputs.zig-overlay.packages.${pkgs.system};
in
  pkgs.mkShell {
    nativeBuildInputs = [
      zig-overlay."master-2026-03-12"
      pkgs.unstable.zls
    ];
  }
