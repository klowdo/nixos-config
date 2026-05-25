# renovate: jetbrains-datagrip code=DG
final: prev: {
  jetbrains-datagrip = final.unstable.jetbrains.datagrip.overrideAttrs (_old: rec {
    version = "2026.1.3";
    src = prev.fetchurl {
      url = "https://download.jetbrains.com/datagrip/datagrip-${version}.tar.gz";
      hash = "sha256-XxwvXiaWAfK318BjbzKPLVDeMBlOr5BFuD2bqU8+12o=";
    };
    build_number = "261.24374.56";
  });
}
