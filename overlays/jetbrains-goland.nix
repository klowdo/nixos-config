# renovate: jetbrains-goland code=GO
final: prev: {
  jetbrains-goland = (final.unstable.jetbrains.goland.override {forceWayland = true;})
    .overrideAttrs (_old: rec {
    version = "2026.1.3";
    src = prev.fetchurl {
      url = "https://download.jetbrains.com/go/goland-${version}.tar.gz";
      hash = "sha256-1FkDEaapyDbTPe4soOdyCHLkp/UT3rZ6siGyGyjmGJo=";
    };
    build_number = "261.25134.147";
  });
}
