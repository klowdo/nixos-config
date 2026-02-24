# renovate: jetbrains-rider
final: prev: {
  jetbrains-rider = (final.unstable.jetbrains.rider.override {forceWayland = true;})
    .overrideAttrs (_old: rec {
    version = "2025.3.1";
    src = prev.fetchurl {
      url = "https://download.jetbrains.com/rider/JetBrains.Rider-${version}.tar.gz";
      hash = "sha256-uoQPfEjafxGM9Xqowi3zASDRbxdfvOO+xqZVkO2H8ug=";
    };
    build_number = "253.29346.144";
  });
}
