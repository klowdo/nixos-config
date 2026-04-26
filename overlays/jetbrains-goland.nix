# renovate: jetbrains-goland code=GO
final: prev: {
  jetbrains-goland = (final.unstable.jetbrains.goland.override {forceWayland = true;})
    .overrideAttrs (_old: rec {
    version = "2026.1.1";
    src = prev.fetchurl {
      url = "https://download.jetbrains.com/go/goland-${version}.tar.gz";
      hash = "sha256-+TORnDso307j+WwFspoQRZ8IN2TFyy5uUvLyjiNhHiY=";
    };
    build_number = "261.23567.143";
  });
}
