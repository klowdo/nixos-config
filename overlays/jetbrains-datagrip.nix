# renovate: jetbrains-datagrip
final: prev: {
  jetbrains-datagrip = final.unstable.jetbrains.datagrip.overrideAttrs (_old: rec {
    version = "2025.3.5";
    src = prev.fetchurl {
      url = "https://download.jetbrains.com/datagrip/datagrip-${version}.tar.gz";
      hash = "sha256-s9Zw7SUhmAzjhTf52nEerXNaP0l7kO/6J35xFtKf6TQ=";
    };
    build_number = "253.31033.21";
  });
}
