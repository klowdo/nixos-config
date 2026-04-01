{pkgs, ...}: let
  wrapElectronWayland = pkg:
    pkg.overrideAttrs (old: {
      nativeBuildInputs = (old.nativeBuildInputs or []) ++ [pkgs.makeWrapper];
      postFixup =
        (old.postFixup or "")
        + ''
          wrapProgram $out/bin/${pkg.pname} \
            --add-flags "--ozone-platform-hint=auto"
        '';
    });
in {
  home.packages = [
    (wrapElectronWayland pkgs.via)
    (wrapElectronWayland pkgs.vial)
  ];
}
