# renovate: jetbrains-rider
final: prev: {
  jetbrains-rider = (final.unstable.jetbrains.rider.override {forceWayland = true;})
    .overrideAttrs (_old: rec {
    version = "2025.3.3";
    src = prev.fetchurl {
      url = "https://download.jetbrains.com/rider/JetBrains.Rider-${version}.tar.gz";
      hash = "sha256-sBF/XA52oSFD1dEmzhvo7cwf5EGTi0mx1x3PcobQVAs=";
    };
    build_number = "253.31033.136";
  });
}
