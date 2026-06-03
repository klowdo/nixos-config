# nix-update: lens
final: prev: {
  lens = prev.lens.overrideAttrs (_old: rec {
    version = "2026.5.250609";
    src = prev.fetchurl {
      url = "https://api.k8slens.dev/binaries/Lens-${version}-latest.x86_64.AppImage";
      hash = "sha256-cd+m3vqC2NMqEQ43yh8mSd6vfeWjQYU3T6szhc/myVc=";
    };
  });
}
