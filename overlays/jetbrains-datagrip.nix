# renovate: jetbrains-datagrip code=DG
final: prev: {
  jetbrains-datagrip = final.unstable.jetbrains.datagrip.overrideAttrs (_old: rec {
    version = "2026.1";
    src = prev.fetchurl {
      url = "https://download.jetbrains.com/datagrip/datagrip-${version}.tar.gz";
      hash = "sha256-s9Zw7SUhmAzjhTf52nEerXNaP0l7kO/6J35xFtKf6TQ=";
    };
    build_number = "261.22158.299";
  });
}
