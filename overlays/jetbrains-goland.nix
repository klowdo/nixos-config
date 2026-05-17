# renovate: jetbrains-goland code=GO
final: prev: {
  jetbrains-goland = (final.unstable.jetbrains.goland.override {forceWayland = true;})
    .overrideAttrs (_old: rec {
    version = "2026.1.2";
    src = prev.fetchurl {
      url = "https://download.jetbrains.com/go/goland-${version}.tar.gz";
      hash = "sha256-ASzqw8xuRaSAwzoiBsL+6PRyuSvBh43tnF4mEmkur9s=";
    };
    build_number = "261.24374.154";
  });
}
