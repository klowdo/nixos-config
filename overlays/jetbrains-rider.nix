# renovate: jetbrains-rider code=RD
final: prev: {
  jetbrains-rider = (final.unstable.jetbrains.rider.override {forceWayland = true;})
    .overrideAttrs (_old: rec {
    version = "2026.1.0.1";
    src = prev.fetchurl {
      url = "https://download.jetbrains.com/rider/JetBrains.Rider-${version}.tar.gz";
      hash = "sha256-sBF/XA52oSFD1dEmzhvo7cwf5EGTi0mx1x3PcobQVAs=";
    };
    build_number = "261.22158.394";
  });
}
