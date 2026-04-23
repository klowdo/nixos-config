# renovate: jetbrains-datagrip code=DG
final: prev: {
  jetbrains-datagrip = final.unstable.jetbrains.datagrip.overrideAttrs (_old: rec {
    version = "2026.1.2";
    src = prev.fetchurl {
      url = "https://download.jetbrains.com/datagrip/datagrip-${version}.tar.gz";
      hash = "sha256-DaAqg6Xce1RkvEM6++7CxC72AvB1SHKFBWOzJD9RIuY=";
    };
    build_number = "261.23567.23";
  });
}
