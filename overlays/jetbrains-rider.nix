# renovate: jetbrains-rider code=RD
final: prev: {
  jetbrains-rider = (final.unstable.jetbrains.rider.override {forceWayland = true;})
    .overrideAttrs (_old: rec {
    version = "2026.1.2";
    src = prev.fetchurl {
      url = "https://download.jetbrains.com/rider/JetBrains.Rider-${version}.tar.gz";
      hash = "sha256-OmysaGXGMxxAAa2qrHvX8yXIwJLU7tKG8/EBGhr55EA=";
    };
    build_number = "261.24374.190";
  });
}
