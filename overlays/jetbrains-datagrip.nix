# renovate: jetbrains-datagrip
final: prev: {
  jetbrains-datagrip = final.unstable.jetbrains.datagrip.overrideAttrs (_old: rec {
    version = "2025.3.5";
    src = prev.fetchurl {
      url = "https://download.jetbrains.com/datagrip/datagrip-${version}.tar.gz";
      hash = "sha256-N9CvTsMLlMcdNQf+NbOwvdOJkD234vGo7XM1OyJxhHY=";
    };
    build_number = "253.31033.21";
  });
}
