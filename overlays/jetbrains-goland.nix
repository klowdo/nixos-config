# renovate: jetbrains-goland code=GO
final: prev: {
  jetbrains-goland = (final.unstable.jetbrains.goland.override {forceWayland = true;})
    .overrideAttrs (_old: rec {
    version = "2026.1";
    src = prev.fetchurl {
      url = "https://download.jetbrains.com/go/goland-${version}.tar.gz";
      hash = "sha256-S8IRWe+viRxtLrnCgQPR0J8QrOSr5yvtcOpwsjkq9DY=";
    };
    build_number = "261.22158.291";
  });
}
