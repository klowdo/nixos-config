# renovate: jetbrains-goland code=GO
final: prev: {
  jetbrains-goland = (final.unstable.jetbrains.goland.override {forceWayland = true;})
    .overrideAttrs (_old: rec {
    version = "2025.3.4";
    src = prev.fetchurl {
      url = "https://download.jetbrains.com/go/goland-${version}.tar.gz";
      hash = "sha256-hyQaZIn102YlXVIYgDu7DyofWkjj1svK7qDhC7hHqlY=";
    };
    build_number = "253.32098.60";
  });
}
