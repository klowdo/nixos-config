# renovate: jetbrains-rider code=RD
final: prev: {
  jetbrains-rider = (final.unstable.jetbrains.rider.override {forceWayland = true;})
    .overrideAttrs (_old: rec {
    version = "2026.1.0.1";
    src = prev.fetchurl {
      url = "https://download.jetbrains.com/rider/JetBrains.Rider-${version}.tar.gz";
      hash = "sha256-moIysTTsq7abpQfNh1Bc5Pk6VQgJIT6erbyHsUXf15Y=";
    };
    build_number = "261.22158.394";
  });
}
