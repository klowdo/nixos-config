# renovate: jetbrains-datagrip
final: prev: {
  jetbrains-datagrip = final.unstable.jetbrains.datagrip.overrideAttrs (_old: rec {
    version = "2025.2.4";
    src = prev.fetchurl {
      url = "https://download.jetbrains.com/datagrip/datagrip-${version}.tar.gz";
      hash = "sha256-N9CvTsMLlMcdNQf+NbOwvdOJkD234vGo7XM1OyJxhHY=";
    };
    build_number = "252.28238.33";
  });
}
